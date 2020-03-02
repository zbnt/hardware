/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop_extract #(parameter C_NUM_SCRIPTS = 4, parameter C_NUM_SCRIPTS_CEIL = 8, parameter C_AXIS_LOG_WIDTH = 64, parameter C_EXTRACT_FIFO_SIZE = 2048)
(
	input logic clk,
	input logic rst_n,
	input logic srst,
	input logic enable,

	input logic clk_log,
	input logic [63:0] current_time,
	output logic [63:0] overflow_count,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic [17*C_NUM_SCRIPTS:0] s_axis_tuser,  // {C_NUM_SCRIPTS * {PARAM_B, INSTR_B, MATCHED}, FCS_INVALID}
	input logic s_axis_tlast,
	input logic s_axis_tvalid,

	// M_AXIS_FRAME

	output logic [C_AXIS_LOG_WIDTH-1:0] m_axis_frame_tdata,
	output logic m_axis_frame_tvalid,
	input logic m_axis_frame_tready,

	// M_AXIS_CTL

	output logic [C_NUM_SCRIPTS_CEIL+79:0] m_axis_ctl_tdata, // {C_NUM_SCRIPTS * {MATCHED}, SIZE, TIMESTAMP}
	output logic m_axis_ctl_tvalid,
	input logic m_axis_ctl_tready
);
	// Flags

	logic [C_NUM_SCRIPTS-1:0] extract_byte, script_match;

	for(genvar i = 0; i < C_NUM_SCRIPTS; ++i) begin
		always_comb begin
			script_match[i] = s_axis_tuser[17*i+1];
			extract_byte[i] = &s_axis_tuser[17*i+2:17*i+1];
		end
	end

	// CDC

	logic [63:0] current_time_cdc, overflow_count_cdc;

	bus_cdc #(64, 2) U0
	(
		.clk_src(clk_log),
		.clk_dst(clk),
		.data_in(current_time),
		.data_out(current_time_cdc)
	);

	bus_cdc #(64, 2) U1
	(
		.clk_src(clk),
		.clk_dst(clk_log),
		.data_in(overflow_count_cdc),
		.data_out(overflow_count)
	);

	// Push values to FIFO

	enum logic [1:0] {ST_WAIT_FIFO, ST_WRITE_FRAME, ST_WRITE_CTL, ST_OVERFLOW} state;
	logic [C_AXIS_LOG_WIDTH-9:0] byte_sr;
	logic [15:0] count;
	logic in_frame;

	logic [C_AXIS_LOG_WIDTH-1:0] s_axis_frame_tdata;
	logic s_axis_frame_tvalid, s_axis_frame_tready;

	logic [C_NUM_SCRIPTS_CEIL+79:0] s_axis_ctl_tdata;
	logic s_axis_ctl_tvalid, s_axis_ctl_tready;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_FIFO;
			in_frame <= 1'b0;
			count <= 16'd0;
			byte_sr <= '0;

			overflow_count_cdc <= 64'd0;

			s_axis_frame_tdata <= '0;
			s_axis_frame_tvalid <= 1'b0;

			s_axis_ctl_tdata <= '0;
			s_axis_ctl_tvalid <= 1'b0;
		end else begin
			if(s_axis_frame_tvalid & s_axis_frame_tready) begin
				s_axis_frame_tvalid <= 1'b0;
			end

			if(s_axis_ctl_tvalid & s_axis_ctl_tready) begin
				s_axis_ctl_tvalid <= 1'b0;
			end

			if(s_axis_tvalid) begin
				in_frame <= ~s_axis_tlast;
			end

			case(state)
				ST_WAIT_FIFO: begin
					count <= 16'd0;

					if(s_axis_frame_tready & s_axis_ctl_tready & ~in_frame & enable) begin
						state <= ST_WRITE_FRAME;
					end
				end

				ST_WRITE_FRAME: begin
					if(s_axis_tvalid) begin
						if(extract_byte != 'd0) begin
							if(count[$clog2(C_AXIS_LOG_WIDTH/8)-1:0] == '1 || s_axis_tlast) begin
								if(s_axis_frame_tready) begin
									if(s_axis_tlast) begin
										state <= ST_WRITE_CTL;
										s_axis_ctl_tdata <= {'0, script_match, count + 16'd1, current_time};
										s_axis_ctl_tvalid <= 1'b1;
									end

									s_axis_frame_tdata <= {s_axis_tdata, byte_sr};
								end else begin
									state <= ST_OVERFLOW;
									s_axis_frame_tdata <= {s_axis_tdata, byte_sr};
									s_axis_ctl_tdata <= {'0, count + 16'd1, current_time};

									if(s_axis_tlast) begin
										overflow_count_cdc <= overflow_count_cdc + 64'd1;
									end
								end

								byte_sr <= '0;
								s_axis_frame_tvalid <= 1'b1;
							end else begin
								byte_sr <= {s_axis_tdata, byte_sr[C_AXIS_LOG_WIDTH-9:8]};
							end

							count <= count + 16'd1;
						end else if(s_axis_tlast) begin
							state <= ST_WRITE_CTL;
							s_axis_ctl_tdata <= {'0, script_match, count, current_time};
							s_axis_ctl_tvalid <= 1'b1;
						end
					end else if(~in_frame & ~enable) begin
						state <= ST_WAIT_FIFO;
					end
				end

				ST_WRITE_CTL: begin
					if(s_axis_ctl_tvalid & s_axis_ctl_tready) begin
						state <= ST_WAIT_FIFO;
					end
				end

				ST_OVERFLOW: begin
					if(s_axis_frame_tready & s_axis_frame_tvalid) begin
						state <= ST_WAIT_FIFO;
						s_axis_ctl_tvalid <= 1'b1;
					end
				end
			endcase

			if(srst) begin
				overflow_count_cdc <= 64'd0;
			end else if(state != ST_WRITE_FRAME && s_axis_tvalid && s_axis_tlast) begin
				overflow_count_cdc <= overflow_count_cdc + 64'd1;
			end
		end
	end

	// FIFO instances

	xpm_fifo_axis
	#(
		.CDC_SYNC_STAGES(2),
		.CLOCKING_MODE("independent_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(C_EXTRACT_FIFO_SIZE / (C_AXIS_LOG_WIDTH/8)),
		.FIFO_MEMORY_TYPE("block"),
		.PACKET_FIFO("false"),
		.PROG_EMPTY_THRESH(10),
		.PROG_FULL_THRESH(10),
		.RD_DATA_COUNT_WIDTH(1),
		.RELATED_CLOCKS(0),
		.TDATA_WIDTH(C_AXIS_LOG_WIDTH),
		.TDEST_WIDTH(1),
		.TID_WIDTH(1),
		.TUSER_WIDTH(1),
		.USE_ADV_FEATURES("1000"),
		.WR_DATA_COUNT_WIDTH(1)
	)
	U2
	(
		.m_aclk(clk_log),
		.s_aclk(clk),
		.s_aresetn(rst_n),

		.prog_full_axis(),
		.prog_empty_axis(),

		.s_axis_tdata(s_axis_frame_tdata),
		.s_axis_tvalid(s_axis_frame_tvalid),
		.s_axis_tready(s_axis_frame_tready),

		.m_axis_tdata(m_axis_frame_tdata),
		.m_axis_tvalid(m_axis_frame_tvalid),
		.m_axis_tready(m_axis_frame_tready),

		.s_axis_tlast(1'b0),
		.s_axis_tuser(1'b0),
		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tstrb(1'b1),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);

	xpm_fifo_axis
	#(
		.CDC_SYNC_STAGES(2),
		.CLOCKING_MODE("independent_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(C_EXTRACT_FIFO_SIZE / 32),
		.FIFO_MEMORY_TYPE("block"),
		.PACKET_FIFO("false"),
		.PROG_EMPTY_THRESH(10),
		.PROG_FULL_THRESH(10),
		.RD_DATA_COUNT_WIDTH(1),
		.RELATED_CLOCKS(0),
		.TDATA_WIDTH(80 + C_NUM_SCRIPTS_CEIL),
		.TDEST_WIDTH(1),
		.TID_WIDTH(1),
		.TUSER_WIDTH(1),
		.USE_ADV_FEATURES("1000"),
		.WR_DATA_COUNT_WIDTH(1)
	)
	U3
	(
		.m_aclk(clk_log),
		.s_aclk(clk),
		.s_aresetn(rst_n),

		.prog_full_axis(),
		.prog_empty_axis(),

		.s_axis_tdata(s_axis_ctl_tdata),
		.s_axis_tvalid(s_axis_ctl_tvalid),
		.s_axis_tready(s_axis_ctl_tready),

		.m_axis_tdata(m_axis_ctl_tdata),
		.m_axis_tvalid(m_axis_ctl_tvalid),
		.m_axis_tready(m_axis_ctl_tready),

		.s_axis_tlast(1'b0),
		.s_axis_tuser(1'b0),
		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tstrb(1'b1),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);
endmodule

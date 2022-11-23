/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop_extract #(parameter C_NUM_SCRIPTS = 4, parameter C_AXIS_LOG_WIDTH = 64, parameter C_EXTRACT_FIFO_SIZE = 2048)
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
	input logic [17*C_NUM_SCRIPTS+2:0] s_axis_tuser,  // {C_NUM_SCRIPTS * {PARAM_B, INSTR_B, MATCHED}, FCS_ACTIVE, FCS_INCORRECT, FRAME_BAD}
	input logic s_axis_tlast,
	input logic s_axis_tvalid,

	// M_AXIS_FRAME

	output logic [C_AXIS_LOG_WIDTH-1:0] m_axis_frame_tdata,
	output logic m_axis_frame_tvalid,
	input logic m_axis_frame_tready,

	// M_AXIS_CTL

	output logic [121:0] m_axis_ctl_tdata, // {8 * {MATCHED}, FCS_INCORRECT, FRAME_BAD, SIZE, NUMBER, TIMESTAMP}
	output logic m_axis_ctl_tvalid,
	input logic m_axis_ctl_tready
);
	// Flags

	logic [C_NUM_SCRIPTS-1:0] extract_byte, script_match;

	for(genvar i = 0; i < C_NUM_SCRIPTS; ++i) begin
		always_comb begin
			script_match[i] = s_axis_tuser[17*i+3];
			extract_byte[i] = &s_axis_tuser[17*i+4:17*i+3];
		end
	end

	// CDC

	logic [63:0] current_time_cdc, overflow_count_cdc;

	gray_cdc #(64, 4) U0
	(
		.clk_src(clk_log),
		.clk_dst(clk),
		.data_in(current_time),
		.data_out(current_time_cdc)
	);

	bus_cdc #(64, 4) U1
	(
		.clk_src(clk),
		.clk_dst(clk_log),
		.data_in(overflow_count_cdc),
		.data_out(overflow_count)
	);

	// Stage 1: Filter input stream

	logic [7:0] axis_s1_tdata;
	logic [C_NUM_SCRIPTS+65:0] axis_s1_tuser;
	logic axis_s1_tkeep, axis_s1_tlast, axis_s1_tvalid;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			axis_s1_tdata <= '0;
			axis_s1_tuser <= '0;
			axis_s1_tkeep <= 1'b0;
			axis_s1_tlast <= 1'b0;
			axis_s1_tvalid <= 1'b0;
		end else begin
			axis_s1_tdata <= s_axis_tdata;
			axis_s1_tuser <= {script_match, s_axis_tuser[1:0], current_time_cdc};
			axis_s1_tkeep <= |extract_byte;
			axis_s1_tlast <= s_axis_tlast;
			axis_s1_tvalid <= s_axis_tvalid & |{extract_byte, s_axis_tlast};
		end
	end

	// Stage 2: Resize stream

	logic [C_AXIS_LOG_WIDTH-1:0] axis_s2_tdata;
	logic [C_NUM_SCRIPTS+113:0] axis_s2_tuser;
	logic axis_s2_tkeep, axis_s2_tlast, axis_s2_tvalid;

	logic [C_AXIS_LOG_WIDTH/8-1:0] count_1h;
	logic [15:0] count_bytes;
	logic [31:0] count_frames;
	logic frame_begin;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			axis_s2_tuser[95:0] <= '0;
			axis_s2_tuser[C_NUM_SCRIPTS+113:112] <= '0;
			axis_s2_tkeep <= 1'b0;
			axis_s2_tlast <= 1'b0;
			axis_s2_tvalid <= 1'b0;

			count_1h <= 'd1;
			count_bytes <= 16'd0;
			count_frames <= 32'd0;
			frame_begin <= 1'b1;
		end else begin
			axis_s2_tuser[95:0] <= {count_frames, axis_s1_tuser[63:0]};
			axis_s2_tuser[C_NUM_SCRIPTS+113:112] <= axis_s1_tuser[C_NUM_SCRIPTS+65:64];
			axis_s2_tlast <= axis_s1_tlast;
			axis_s2_tvalid <= axis_s1_tvalid & (axis_s1_tlast | count_1h[C_AXIS_LOG_WIDTH/8-1]);

			if(axis_s1_tvalid) begin
				if(axis_s1_tlast) begin
					count_1h <= 'd1;
					count_frames <= count_frames + 32'd1;
				end else if(axis_s1_tkeep) begin
					count_1h <= {count_1h[C_AXIS_LOG_WIDTH/8-2:0], count_1h[C_AXIS_LOG_WIDTH/8-1]};
				end

				if(frame_begin) begin
					count_bytes <= {15'd0, axis_s1_tkeep};
					axis_s2_tkeep <= axis_s1_tkeep;
				end else begin
					count_bytes <= count_bytes + {15'd0, axis_s1_tkeep};
					axis_s2_tkeep <= axis_s1_tkeep | axis_s2_tkeep;
				end

				frame_begin <= axis_s1_tlast;
			end
		end
	end

	always_comb begin
		axis_s2_tuser[111:96] = count_bytes;
	end

	for(genvar i = 0; i < C_AXIS_LOG_WIDTH/8; ++i) begin
		always_ff @(posedge clk) begin
			if(~rst_n) begin
				axis_s2_tdata[i*8+7:i*8] <= 8'd0;
			end else if(axis_s1_tvalid & axis_s1_tkeep & count_1h[i]) begin
				axis_s2_tdata[i*8+7:i*8] <= axis_s1_tdata;
			end
		end
	end

	// Stage 3: Push to FIFO

	enum logic {ST_WAIT_FIFO, ST_WRITE_FRAME} state;
	logic in_frame;

	logic [C_AXIS_LOG_WIDTH-1:0] s_axis_frame_tdata;
	logic s_axis_frame_tvalid, s_axis_frame_tready;

	logic [121:0] s_axis_ctl_tdata;
	logic s_axis_ctl_tvalid, s_axis_ctl_tready;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_FIFO;

			in_frame <= 1'b0;
			overflow_count_cdc <= 64'd0;

			s_axis_ctl_tdata <= '0;
			s_axis_ctl_tvalid <= 1'b0;

			s_axis_frame_tdata <= '0;
			s_axis_frame_tvalid <= 1'b0;
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
					if(enable) begin
						if(s_axis_frame_tready & s_axis_ctl_tready & (~in_frame | (s_axis_tvalid & s_axis_tlast))) begin
							state <= ST_WRITE_FRAME;
						end

						if(s_axis_tvalid & s_axis_tlast) begin
							overflow_count_cdc <= overflow_count_cdc + 64'd1;
						end
					end
				end

				ST_WRITE_FRAME: begin
					if(~s_axis_frame_tvalid | s_axis_frame_tready) begin
						s_axis_frame_tdata <= axis_s2_tdata;
						s_axis_frame_tvalid <= axis_s2_tvalid & axis_s2_tkeep;

						s_axis_ctl_tdata <= axis_s2_tuser;

						if(axis_s2_tvalid & axis_s2_tlast) begin
							state <= ST_WAIT_FIFO;

							s_axis_ctl_tvalid <= 1'b1;
						end
					end else if(axis_s2_tvalid & axis_s2_tkeep) begin
						state <= ST_WAIT_FIFO;

						s_axis_ctl_tdata[C_NUM_SCRIPTS+113:114] <= '0;
						s_axis_ctl_tvalid <= 1'b1;
					end
				end
			endcase

			if(srst) begin
				overflow_count_cdc <= 64'd0;
			end
		end
	end

	// FIFO instances

	axis_fifo
	#(
		.C_DEPTH(C_EXTRACT_FIFO_SIZE / (C_AXIS_LOG_WIDTH/8)),
		.C_MEM_TYPE("block"),
		.C_CDC_STAGES(2),

		.C_DATA_WIDTH(C_AXIS_LOG_WIDTH)
	)
	U2
	(
		.s_clk(clk),
		.s_rst_n(rst_n),

		.s_axis_tdata(s_axis_frame_tdata),
		.s_axis_tvalid(s_axis_frame_tvalid),
		.s_axis_tready(s_axis_frame_tready),

		.m_clk(clk_log),

		.m_axis_tdata(m_axis_frame_tdata),
		.m_axis_tvalid(m_axis_frame_tvalid),
		.m_axis_tready(m_axis_frame_tready)
	);

	axis_fifo
	#(
		.C_DEPTH(C_EXTRACT_FIFO_SIZE / 64),
		.C_MEM_TYPE("block"),
		.C_CDC_STAGES(2),

		.C_DATA_WIDTH(122)
	)
	U3
	(
		.s_clk(clk),
		.s_rst_n(rst_n),

		.s_axis_tdata(s_axis_ctl_tdata),
		.s_axis_tvalid(s_axis_ctl_tvalid),
		.s_axis_tready(s_axis_ctl_tready),

		.m_clk(clk_log),

		.m_axis_tdata(m_axis_ctl_tdata),
		.m_axis_tvalid(m_axis_ctl_tvalid),
		.m_axis_tready(m_axis_ctl_tready)
	);
endmodule

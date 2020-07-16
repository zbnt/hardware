/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_mm2s_io
#(
	parameter C_AXI_WIDTH = 128,
	parameter C_AXI_ADDR_WIDTH = 64,
	parameter C_AXI_MAX_BURST = 255,
	parameter C_FIFO_SIZE = 256,
	parameter C_FIFO_TYPE = "block"
)
(
	input logic clk,
	input logic rst_n,

	output logic busy,
	output logic [1:0] response,

	input logic trigger,
	input logic [C_AXI_ADDR_WIDTH-1:0] start_addr,
	input logic [15:0] bytes_to_read,

	// M_AXI

	output logic [C_AXI_ADDR_WIDTH-1:0] m_axi_araddr,
	output logic [7:0] m_axi_arlen,
	output logic [2:0] m_axi_arsize,
	output logic m_axi_arvalid,
	input logic m_axi_arready,

	input logic [C_AXI_WIDTH-1:0] m_axi_rdata,
	input logic [1:0] m_axi_rresp,
	input logic m_axi_rvalid,
	input logic m_axi_rlast,
	output logic m_axi_rready,

	// M_AXIS

	output logic [C_AXI_WIDTH-1:0] m_axis_tdata,
	output logic [(C_AXI_WIDTH/8)-1:0] m_axis_tstrb,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	logic req_finished, rd_finished;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			busy <= 1'b0;
		end else if(~busy) begin
			busy <= trigger;
		end else begin
			busy <= ~req_finished | ~rd_finished;
		end
	end

	// AR-channel (requests)

	enum logic [1:0] {ST_REQ_IDLE, ST_REQ_SET_SIZE, ST_REQ_SET_LEN, ST_REQ_SET_ADDR} state_req;

	logic [C_AXI_WIDTH-1:0] s_axis_tdata;
	logic [(C_AXI_WIDTH/8)-1:0] s_axis_tstrb;
	logic s_axis_tlast, s_axis_tvalid, s_axis_tready;

	logic [15:0] req_bytes;
	logic [11:0] req_bytes_4k;
	logic [15-$clog2(C_AXI_WIDTH/8):0] req_beats;
	logic [11-$clog2(C_AXI_WIDTH/8):0] req_beats_4k;
	logic [7:0] req_len_a, req_len_b, req_len_c;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state_req <= ST_REQ_IDLE;

			req_finished <= 1'b0;
			req_bytes <= 16'd0;

			m_axi_araddr <= '0;
			m_axi_arlen <= 8'd0;
			m_axi_arsize <= 3'd0;
			m_axi_arvalid <= 1'b0;
		end else begin
			case(state_req)
				ST_REQ_IDLE: begin
					m_axi_araddr <= '0;
					m_axi_arlen <= 8'd0;
					m_axi_arsize <= 3'd0;
					m_axi_arvalid <= 1'b0;

					if(~busy) begin
						req_finished <= 1'b0;
					end

					if(~busy & trigger) begin
						state_req <= ST_REQ_SET_SIZE;

						m_axi_araddr <= start_addr;
						req_bytes <= bytes_to_read;
					end
				end

				ST_REQ_SET_SIZE: begin
					if(req_finished) begin
						state_req <= ST_REQ_IDLE;
					end else begin
						state_req <= ST_REQ_SET_LEN;
					end

					// Set the word size

					if(req_bytes > C_AXI_WIDTH/8 - 1) begin
						m_axi_arsize <= $clog2(C_AXI_WIDTH/8);
					end else begin
						for(int i = C_AXI_WIDTH/8; i >= 1; i /= 2) begin
							if(req_bytes[$clog2(C_AXI_WIDTH/8)-1:0] <= i - 1) begin
								m_axi_arsize <= $clog2(i);
							end
						end
					end

					// Get the bounds for the burst length, we'll choose the lowest value later

					if(req_bytes > C_AXI_WIDTH/8 - 1) begin
						req_len_a <= C_AXI_MAX_BURST;
					end else begin
						req_len_a <= 8'd0;
					end

					if(req_beats <= 'hFF) begin
						req_len_b <= req_beats[7:0];
					end else begin
						req_len_b <= 8'hFF;
					end

					if(req_beats_4k <= 'hFF) begin
						req_len_c <= req_beats_4k[7:0];
					end else begin
						req_len_c <= 8'hFF;
					end
				end

				ST_REQ_SET_LEN: begin
					state_req <= ST_REQ_SET_ADDR;

					// Choose the minimum length

					if(req_len_b <= req_len_c) begin
						// B <= C

						if(req_len_a <= req_len_b) begin
							// A <= B <= C
							m_axi_arlen <= req_len_a;
						end else begin
							// B <= C and B < A
							m_axi_arlen <= req_len_b;
						end
					end else begin
						// C < B

						if(req_len_a <= req_len_c) begin
							// A <= C < B
							m_axi_arlen <= req_len_a;
						end else begin
							// C < B and C < A
							m_axi_arlen <= req_len_c;
						end
					end

					m_axi_arvalid <= 1'b1;
				end

				ST_REQ_SET_ADDR: begin
					if(m_axi_arready) begin
						state_req <= ST_REQ_SET_SIZE;

						m_axi_araddr <= {m_axi_araddr[C_AXI_ADDR_WIDTH-1:$clog2(C_AXI_WIDTH/8)] + m_axi_arlen + 'd1, {($clog2(C_AXI_WIDTH/8)){1'b0}}};
						{req_finished, req_bytes} <= req_bytes - ({m_axi_arlen + 'd1, {($clog2(C_AXI_WIDTH/8)){1'b0}}} - m_axi_araddr[$clog2(C_AXI_WIDTH/8)-1:0]);

						m_axi_arvalid <= 1'b0;
					end
				end
			endcase
		end
	end

	always_comb begin
		req_beats = req_bytes[15:$clog2(C_AXI_WIDTH/8)] - {'0, ~&req_bytes[$clog2(C_AXI_WIDTH/8)-1:0]};

		req_bytes_4k = 12'hFFF - m_axi_araddr[11:0];
		req_beats_4k = req_bytes_4k[11:$clog2(C_AXI_WIDTH/8)];
	end

	// R-channel - Finished flag

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			rd_finished <= 1'b0;
		end else begin
			if(~busy) begin
				rd_finished <= 1'b0;
			end

			if(s_axis_tvalid & s_axis_tready & s_axis_tlast) begin
				rd_finished <= 1'b1;
			end
		end
	end

	// R-channel - Stage 1: Read from AXI

	enum logic [1:0] {ST_RD1_IDLE, ST_RD1_WAIT_REQ, ST_RD1_FETCH_WORD, ST_RD1_WAIT_END} state_rd_s1;

	logic [C_AXI_WIDTH-1:0] rd_data;
	logic [$clog2(C_AXI_WIDTH/8)-1:0] rd_offset;
	logic [16:0] rd_bytes_in;
	logic rd_ignore_first;

	logic rd_s1_valid;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state_rd_s1 <= ST_RD1_IDLE;
			response <= 2'd0;

			rd_data <= '0;
			rd_offset <= '0;
			rd_bytes_in <= 17'd0;
			rd_ignore_first <= 1'b0;

			rd_s1_valid <= 1'b0;
		end else begin
			case(state_rd_s1)
				ST_RD1_IDLE: begin
					rd_s1_valid <= 1'b0;

					if(trigger & ~busy) begin
						state_rd_s1 <= ST_RD1_WAIT_REQ;

						rd_offset <= start_addr[$clog2(C_AXI_WIDTH/8)-1:0];
						rd_bytes_in <= {1'b0, bytes_to_read} + start_addr[$clog2(C_AXI_WIDTH/8)-1:0];
					end
				end

				ST_RD1_WAIT_REQ: begin
					response <= 2'd0;

					rd_ignore_first <= (rd_bytes_in >= C_AXI_WIDTH/8 && rd_offset != '0);

					if(m_axi_arready & m_axi_arvalid) begin
						state_rd_s1 <= ST_RD1_FETCH_WORD;
					end
				end

				ST_RD1_FETCH_WORD: begin
					if(s_axis_tready | ~s_axis_tvalid) begin
						if(m_axi_rvalid) begin
							rd_bytes_in <= rd_bytes_in - (C_AXI_WIDTH/8);

							if(rd_bytes_in < (C_AXI_WIDTH/8)) begin
								state_rd_s1 <= ST_RD1_WAIT_END;
							end

							if(response == 2'd0 || response == 2'd1) begin
								case(m_axi_rresp)
									2'b00: response <= 2'd1;
									2'b01: response <= 2'd1;
									2'b10: response <= 2'd2;
									2'b11: response <= 2'd3;
								endcase
							end
						end

						rd_data <= m_axi_rdata;
						rd_s1_valid <= m_axi_rvalid;
					end
				end

				ST_RD1_WAIT_END: begin
					rd_data <= '0;
					rd_s1_valid <= 1'b1;

					if(s_axis_tready & s_axis_tvalid & s_axis_tlast) begin
						state_rd_s1 <= ST_RD1_IDLE;
						rd_s1_valid <= 1'b0;
					end
				end
			endcase
		end
	end

	always_comb begin
		if(state_rd_s1 == ST_RD1_FETCH_WORD) begin
			m_axi_rready = s_axis_tready | ~s_axis_tvalid;
		end else begin
			m_axi_rready = 1'b0;
		end
	end

	// R-channel - Stage 2: Shift-register and mask

	enum logic [1:0] {ST_RD2_IDLE, ST_RD2_WAIT_REQ, ST_RD2_FETCH_WORD, ST_RD2_WAIT_END} state_rd_s2;

	logic [2*C_AXI_WIDTH-1:0] rd_data_sr;
	logic [(C_AXI_WIDTH/8)-1:0] rd_mask;
	logic [$clog2(C_AXI_WIDTH/8)-1:0] rd_bits_mask;
	logic [16:0] rd_bytes_out;
	logic rd_first, rd_second;

	logic rd_s2_last, rd_s2_valid;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state_rd_s2 <= ST_RD2_IDLE;

			rd_data_sr <= '0;
			rd_mask <= '0;
			rd_bits_mask <= '0;
			rd_bytes_out <= 17'd0;
			rd_first <= 1'b0;
			rd_second <= 1'b0;

			rd_s2_last <= 1'b0;
			rd_s2_valid <= 1'b0;
		end else begin
			case(state_rd_s2)
				ST_RD2_IDLE: begin
					rd_s2_valid <= 1'b0;

					if(trigger & ~busy) begin
						state_rd_s2 <= ST_RD2_WAIT_REQ;

						rd_bytes_out <= {1'b0, bytes_to_read} + start_addr[$clog2(C_AXI_WIDTH/8)-1:0];
						rd_bits_mask <= bytes_to_read[$clog2(C_AXI_WIDTH/8)-1:0];
					end
				end

				ST_RD2_WAIT_REQ: begin
					rd_first <= 1'b1;

					if(m_axi_arready & m_axi_arvalid) begin
						state_rd_s2 <= ST_RD2_FETCH_WORD;
					end
				end

				ST_RD2_FETCH_WORD: begin
					if(s_axis_tready | ~s_axis_tvalid) begin
						if(rd_s1_valid) begin
							rd_first <= 1'b0;
							rd_second <= rd_first;
							rd_bytes_out <= rd_bytes_out - C_AXI_WIDTH/8;

							if(rd_bytes_out < C_AXI_WIDTH/8) begin
								state_rd_s2 <= ST_RD2_WAIT_END;
							end

							if(rd_first | ~rd_ignore_first) begin
								rd_data_sr <= {'0, rd_data};
							end else if(rd_second) begin
								rd_data_sr <= {rd_data, rd_data_sr[C_AXI_WIDTH-1:0]};
							end else begin
								rd_data_sr <= {rd_data, rd_data_sr[2*C_AXI_WIDTH-1:C_AXI_WIDTH]};
							end
						end

						rd_s2_last <= (rd_bytes_out < C_AXI_WIDTH/8);
						rd_s2_valid <= rd_s1_valid & (~rd_ignore_first | ~rd_first);
					end

					rd_mask[0] <= 1'b1;

					for(int i = 1; i < C_AXI_WIDTH/8; i++) begin
						rd_mask[i] <= (rd_bits_mask >= i);
					end
				end

				ST_RD2_WAIT_END: begin
					if(s_axis_tready | ~s_axis_tvalid) begin
						rd_s2_last <= 1'b0;
						rd_s2_valid <= 1'b0;
					end

					if(s_axis_tready & s_axis_tvalid & s_axis_tlast) begin
						state_rd_s2 <= ST_RD2_IDLE;
					end
				end
			endcase
		end
	end

	// R-channel - Stage 3: Realignment

	logic [C_AXI_WIDTH-1:0] rd_muxed_values[0:C_AXI_WIDTH/8-1];
	logic [(C_AXI_WIDTH/8)-1:0] rd_mask_final;

	for(genvar i = 0; i < C_AXI_WIDTH/8; i++) begin
		always_comb begin
			rd_muxed_values[i] = rd_data_sr[8*i+C_AXI_WIDTH-1:8*i];
			rd_mask_final[i] = rd_mask[i] | ~rd_s2_last;
		end
	end

	mux_big
	#(
		.C_WIDTH(C_AXI_WIDTH),
		.C_INPUTS(C_AXI_WIDTH/8),
		.C_DIVIDER(4)
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n),
		.enable(s_axis_tready | ~s_axis_tvalid),

		.selector(rd_offset),
		.values_in(rd_muxed_values),
		.value_out(s_axis_tdata)
	);

	reg_slice
	#(
		.C_WIDTH(C_AXI_WIDTH/8 + 2),
		.C_NUM_STAGES(($clog2(C_AXI_WIDTH/8) + 2) / 2 - 1),
		.C_USE_ENABLE(1)
	)
	U1
	(
		.clk(clk),
		.rst(~rst_n),
		.enable(s_axis_tready | ~s_axis_tvalid),

		.data_in({rd_mask_final, rd_s2_last, rd_s2_valid}),
		.data_out({s_axis_tstrb, s_axis_tlast, s_axis_tvalid})
	);

	// FIFO

	if(C_FIFO_TYPE != "none") begin
		xpm_fifo_axis
		#(
			.CDC_SYNC_STAGES(2),
			.CLOCKING_MODE("common_clock"),
			.ECC_MODE("no_ecc"),
			.FIFO_DEPTH(C_FIFO_SIZE),
			.FIFO_MEMORY_TYPE(C_FIFO_TYPE),
			.PACKET_FIFO("false"),
			.PROG_EMPTY_THRESH(10),
			.PROG_FULL_THRESH(10),
			.RD_DATA_COUNT_WIDTH(1),
			.RELATED_CLOCKS(0),
			.TDATA_WIDTH(C_AXI_WIDTH),
			.TDEST_WIDTH(1),
			.TID_WIDTH(1),
			.TUSER_WIDTH(1),
			.USE_ADV_FEATURES("1000"),
			.WR_DATA_COUNT_WIDTH(1)
		)
		U2
		(
			.m_aclk(clk),
			.s_aclk(clk),
			.s_aresetn(rst_n),

			.prog_full_axis(),
			.prog_empty_axis(),

			.s_axis_tdata(s_axis_tdata),
			.s_axis_tstrb(s_axis_tstrb),
			.s_axis_tlast(s_axis_tlast),
			.s_axis_tvalid(s_axis_tvalid),
			.s_axis_tready(s_axis_tready),

			.m_axis_tdata(m_axis_tdata),
			.m_axis_tstrb(m_axis_tstrb),
			.m_axis_tlast(m_axis_tlast),
			.m_axis_tvalid(m_axis_tvalid),
			.m_axis_tready(m_axis_tready),

			.s_axis_tdest(1'b0),
			.s_axis_tid(1'b0),
			.s_axis_tkeep(1'b1),
			.s_axis_tuser(1'b0),

			.injectdbiterr_axis(1'b0),
			.injectsbiterr_axis(1'b0)
		);
	end else begin
		always_comb begin
			m_axis_tdata = s_axis_tdata;
			m_axis_tstrb = s_axis_tstrb;
			m_axis_tlast = s_axis_tlast;
			m_axis_tvalid = s_axis_tvalid;
			s_axis_tready = m_axis_tready;
		end
	end
endmodule

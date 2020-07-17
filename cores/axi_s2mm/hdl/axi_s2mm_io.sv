/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_s2mm_io
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
	input logic [15:0] bytes_to_write,

	// M_AXI

	output logic [C_AXI_ADDR_WIDTH-1:0] m_axi_awaddr,
	output logic [7:0] m_axi_awlen,
	output logic [2:0] m_axi_awsize,
	output logic m_axi_awvalid,
	input logic m_axi_awready,

	output logic [C_AXI_WIDTH-1:0] m_axi_wdata,
	output logic [(C_AXI_WIDTH/8)-1:0] m_axi_wstrb,
	output logic m_axi_wlast,
	output logic m_axi_wvalid,
	input logic m_axi_wready,

	input logic [1:0] m_axi_bresp,
	input logic m_axi_bvalid,
	output logic m_axi_bready,

	// S_AXIS

	input logic [C_AXI_WIDTH-1:0] s_axis_tdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axis_tstrb,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready
);
	logic req_finished;
	logic [16-$clog2(C_AXI_WIDTH/8):0] req_beats_total, resp_beats_total;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			busy <= 1'b0;
		end else if(~busy) begin
			busy <= trigger;
		end else begin
			busy <= (~req_finished || resp_beats_total <= req_beats_total);
		end
	end

	// AW-channel (requests)

	enum logic [1:0] {ST_REQ_IDLE, ST_REQ_SET_SIZE, ST_REQ_SET_LEN, ST_REQ_SET_ADDR} state_req;

	logic [C_AXI_WIDTH-1:0] m_axis_tdata;
	logic [(C_AXI_WIDTH/8)-1:0] m_axis_tstrb;
	logic m_axis_tlast, m_axis_tvalid, m_axis_tready;

	logic [7:0] s_axis_len_tdata;
	logic s_axis_len_tvalid, s_axis_len_tready;

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
			req_beats_total <= '0;

			s_axis_len_tvalid <= 1'b0;

			m_axi_awaddr <= '0;
			m_axi_awlen <= 8'd0;
			m_axi_awsize <= 3'd0;
			m_axi_awvalid <= 1'b0;
		end else begin
			case(state_req)
				ST_REQ_IDLE: begin
					m_axi_awaddr <= '0;
					m_axi_awlen <= 8'd0;
					m_axi_awsize <= 3'd0;
					m_axi_awvalid <= 1'b0;

					s_axis_len_tvalid <= 1'b0;

					if(~busy) begin
						req_finished <= 1'b0;
					end

					if(~busy & trigger) begin
						state_req <= ST_REQ_SET_SIZE;

						m_axi_awaddr <= start_addr;
						req_bytes <= bytes_to_write;
						req_beats_total <= '0;
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
						m_axi_awsize <= $clog2(C_AXI_WIDTH/8);
					end else begin
						for(int i = C_AXI_WIDTH/8; i >= 1; i /= 2) begin
							if(req_bytes[$clog2(C_AXI_WIDTH/8)-1:0] <= i - 1) begin
								m_axi_awsize <= $clog2(i);
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
							m_axi_awlen <= req_len_a;
						end else begin
							// B <= C and B < A
							m_axi_awlen <= req_len_b;
						end
					end else begin
						// C < B

						if(req_len_a <= req_len_c) begin
							// A <= C < B
							m_axi_awlen <= req_len_a;
						end else begin
							// C < B and C < A
							m_axi_awlen <= req_len_c;
						end
					end

					m_axi_awvalid <= 1'b1;
					s_axis_len_tvalid <= 1'b1;
				end

				ST_REQ_SET_ADDR: begin
					if(~m_axi_awvalid & ~s_axis_len_tvalid) begin
						state_req <= ST_REQ_SET_SIZE;
					end

					if(m_axi_awready & m_axi_awvalid) begin
						m_axi_awaddr <= {m_axi_awaddr[C_AXI_ADDR_WIDTH-1:$clog2(C_AXI_WIDTH/8)] + m_axi_awlen + 'd1, {($clog2(C_AXI_WIDTH/8)){1'b0}}};
						{req_finished, req_bytes} <= req_bytes - ({m_axi_awlen + 'd1, {($clog2(C_AXI_WIDTH/8)){1'b0}}} - m_axi_awaddr[$clog2(C_AXI_WIDTH/8)-1:0]);
						req_beats_total <= req_beats_total + 'd1;

						m_axi_awvalid <= 1'b0;
					end

					if(s_axis_len_tready & s_axis_len_tvalid) begin
						s_axis_len_tvalid <= 1'b0;
					end
				end
			endcase
		end
	end

	always_comb begin
		req_beats = req_bytes[15:$clog2(C_AXI_WIDTH/8)] - {'0, ~&req_bytes[$clog2(C_AXI_WIDTH/8)-1:0]};

		req_bytes_4k = 12'hFFF - m_axi_awaddr[11:0];
		req_beats_4k = req_bytes_4k[11:$clog2(C_AXI_WIDTH/8)];

		s_axis_len_tdata = m_axi_awlen;
	end

	// B-channel

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			response <= 2'd0;
			resp_beats_total <= '0;

			m_axi_bready <= 1'b0;
		end else begin
			if(~busy) begin
				resp_beats_total <= 'd1;
				m_axi_bready <= 1'b0;

				if(trigger) begin
					response <= 2'd0;
				end
			end else begin
				m_axi_bready <= (req_beats_total >= resp_beats_total);

				if(m_axi_bready & m_axi_bvalid) begin
					resp_beats_total <= resp_beats_total + 'd1;
					m_axi_bready <= (req_beats_total >= resp_beats_total + 'd1);

					if(response == 2'd0 || response == 2'd1) begin
						case(m_axi_bresp)
							2'b00: response <= 2'd1;
							2'b01: response <= 2'd1;
							2'b10: response <= 2'd2;
							2'b11: response <= 2'd3;
						endcase
					end
				end
			end
		end
	end

	// W-channel - Stage 1: Read from AXIS

	enum logic [2:0] {ST_WR1_IDLE, ST_WR1_WAIT_LEN, ST_WR1_FETCH_WORD, ST_WR1_EXTRA_WORD, ST_WR1_END} state_wr_s1;

	logic [7:0] m_axis_len_tdata;
	logic m_axis_len_tvalid, m_axis_len_tready;

	logic [C_AXI_WIDTH-1:0] wr_data;
	logic [C_AXI_WIDTH/8-1:0] wr_mask;
	logic [$clog2(C_AXI_WIDTH/8)-1:0] wr_offset;
	logic [7:0] wr_length;
	logic wr_extra;

	logic wr_s1_stream_end, wr_s1_burst_last, wr_s1_valid;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state_wr_s1 <= ST_WR1_IDLE;

			wr_data <= '0;
			wr_mask <= '0;
			wr_offset <= '0;
			wr_length <= '0;
			wr_extra <= 1'b0;

			wr_s1_stream_end <= 1'b0;
			wr_s1_burst_last <= 1'b0;
			wr_s1_valid <= 1'b0;
		end else begin
			case(state_wr_s1)
				ST_WR1_IDLE: begin
					wr_s1_stream_end <= 1'b0;
					wr_s1_burst_last <= 1'b0;
					wr_s1_valid <= 1'b0;

					if(trigger & ~busy) begin
						state_wr_s1 <= ST_WR1_WAIT_LEN;

						wr_offset <= start_addr[$clog2(C_AXI_WIDTH/8)-1:0];

						if(start_addr[$clog2(C_AXI_WIDTH/8)-1:0] == '0) begin
							wr_extra <= (bytes_to_write[$clog2(C_AXI_WIDTH/8)-1:0] != '1);
						end else begin
							wr_extra <= (bytes_to_write[$clog2(C_AXI_WIDTH/8)-1:0] > {$clog2(C_AXI_WIDTH/8){1'b1}} - start_addr[$clog2(C_AXI_WIDTH/8)-1:0]);
						end
					end
				end

				ST_WR1_WAIT_LEN: begin
					if(m_axi_wready | ~m_axi_wvalid) begin
						if(m_axis_len_tvalid) begin
							state_wr_s1 <= ST_WR1_FETCH_WORD;
							wr_length <= m_axis_len_tdata;
						end

						wr_s1_stream_end <= 1'b0;
						wr_s1_burst_last <= 1'b0;
						wr_s1_valid <= 1'b0;
					end
				end

				ST_WR1_FETCH_WORD: begin
					if(m_axi_wready | ~m_axi_wvalid) begin
						if(m_axis_tvalid) begin
							if(m_axis_tlast) begin
								if(~wr_extra) begin
									state_wr_s1 <= ST_WR1_END;
									wr_s1_burst_last <= 1'b1;
								end else begin
									state_wr_s1 <= ST_WR1_EXTRA_WORD;
									wr_s1_burst_last <= 1'b0;
								end
							end else if(wr_length == '0) begin
								state_wr_s1 <= ST_WR1_WAIT_LEN;
								wr_s1_burst_last <= 1'b1;
							end

							wr_length <= wr_length - 8'd1;
						end

						wr_data <= m_axis_tdata;
						wr_mask <= m_axis_tstrb;
						wr_s1_stream_end <= m_axis_tlast;
						wr_s1_valid <= m_axis_tvalid;
					end
				end

				ST_WR1_EXTRA_WORD: begin
					if(m_axi_wready | ~m_axi_wvalid) begin
						state_wr_s1 <= ST_WR1_END;

						wr_data <= '0;
						wr_mask <= '0;
						wr_s1_burst_last <= 1'b1;
						wr_s1_stream_end <= 1'b1;
						wr_s1_valid <= 1'b1;
					end
				end

				ST_WR1_END: begin
					if(m_axi_wready | ~m_axi_wvalid) begin
						state_wr_s1 <= ST_WR1_IDLE;

						wr_data <= '0;
						wr_mask <= '0;
						wr_s1_stream_end <= 1'b0;
						wr_s1_burst_last <= 1'b0;
						wr_s1_valid <= 1'b0;
					end
				end

				default: begin
					state_wr_s1 <= ST_WR1_IDLE;
				end
			endcase
		end
	end

	always_comb begin
		if(state_wr_s1 == ST_WR1_WAIT_LEN) begin
			m_axis_len_tready = m_axi_wready | ~m_axi_wvalid;
		end else begin
			m_axis_len_tready = 1'b0;
		end

		if(state_wr_s1 == ST_WR1_FETCH_WORD) begin
			m_axis_tready = m_axi_wready | ~m_axi_wvalid;
		end else begin
			m_axis_tready = 1'b0;
		end
	end

	// W-channel - Stage 2: Add data and mask to shift-registers

	enum logic [1:0] {ST_WR2_IDLE, ST_WR2_WAIT_REQ, ST_WR2_FETCH_WORD, ST_WR2_END} state_wr_s2;

	logic [2*C_AXI_WIDTH-1:0] wr_data_sr;
	logic [C_AXI_WIDTH/4-1:0] wr_mask_sr;

	logic wr_s2_last, wr_s2_valid;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state_wr_s2 <= ST_WR2_IDLE;

			wr_data_sr <= '0;
			wr_mask_sr <= '0;

			wr_s2_last <= 1'b0;
			wr_s2_valid <= 1'b0;
		end else begin
			case(state_wr_s2)
				ST_WR2_IDLE: begin
					wr_data_sr <= '0;
					wr_mask_sr <= '0;
					wr_s2_last <= 1'b0;
					wr_s2_valid <= 1'b0;

					if(trigger & ~busy) begin
						state_wr_s2 <= ST_WR2_WAIT_REQ;
					end
				end

				ST_WR2_WAIT_REQ: begin
					if(m_axi_awready & m_axi_awvalid) begin
						state_wr_s2 <= ST_WR2_FETCH_WORD;
					end
				end

				ST_WR2_FETCH_WORD: begin
					if(m_axi_wready | ~m_axi_wvalid) begin
						if(wr_s1_valid) begin
							if(wr_s1_stream_end & wr_s1_burst_last) begin
								state_wr_s2 <= ST_WR2_END;
							end

							wr_data_sr <= {wr_data, wr_data_sr[2*C_AXI_WIDTH-1:C_AXI_WIDTH]};
							wr_mask_sr <= {wr_mask, wr_mask_sr[C_AXI_WIDTH/4-1:C_AXI_WIDTH/8]};
						end

						wr_s2_last <= wr_s1_burst_last;
						wr_s2_valid <= wr_s1_valid;
					end
				end

				ST_WR2_END: begin
					if(m_axi_wready | ~m_axi_wvalid) begin
						state_wr_s2 <= ST_WR2_IDLE;
						wr_s2_valid <= 1'b0;
					end
				end
			endcase
		end
	end

	// R-channel - Stage 3: Realignment

	logic [C_AXI_WIDTH-1:0] wr_muxed_values[0:C_AXI_WIDTH/8-1];
	logic [C_AXI_WIDTH/8-1:0] wr_muxed_masks[0:C_AXI_WIDTH/8-1];

	for(genvar i = 0; i < C_AXI_WIDTH/8; i++) begin
		always_comb begin
			wr_muxed_values[i] = wr_data_sr[2*C_AXI_WIDTH-8*i-1:C_AXI_WIDTH-8*i];
			wr_muxed_masks[i] = wr_mask_sr[C_AXI_WIDTH/4-i-1:C_AXI_WIDTH/8-i];
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
		.enable(m_axi_wready | ~m_axi_wvalid),

		.selector(wr_offset),
		.values_in(wr_muxed_values),
		.value_out(m_axi_wdata)
	);

	mux_big
	#(
		.C_WIDTH(C_AXI_WIDTH/8),
		.C_INPUTS(C_AXI_WIDTH/8),
		.C_DIVIDER(4)
	)
	U1
	(
		.clk(clk),
		.rst_n(rst_n),
		.enable(m_axi_wready | ~m_axi_wvalid),

		.selector(wr_offset),
		.values_in(wr_muxed_masks),
		.value_out(m_axi_wstrb)
	);

	reg_slice
	#(
		.C_WIDTH(2),
		.C_NUM_STAGES(($clog2(C_AXI_WIDTH/8) + 2) / 2 - 1),
		.C_USE_ENABLE(1)
	)
	U2
	(
		.clk(clk),
		.rst(~rst_n),
		.enable(m_axi_wready | ~m_axi_wvalid),

		.data_in({wr_s2_last, wr_s2_valid}),
		.data_out({m_axi_wlast, m_axi_wvalid})
	);

	// FIFOs

	xpm_fifo_axis
	#(
		.CDC_SYNC_STAGES(2),
		.CLOCKING_MODE("common_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(16),
		.FIFO_MEMORY_TYPE("distributed"),
		.PACKET_FIFO("false"),
		.PROG_EMPTY_THRESH(10),
		.PROG_FULL_THRESH(10),
		.RD_DATA_COUNT_WIDTH(1),
		.RELATED_CLOCKS(0),
		.TDATA_WIDTH(8),
		.TDEST_WIDTH(1),
		.TID_WIDTH(1),
		.TUSER_WIDTH(1),
		.USE_ADV_FEATURES("1000"),
		.WR_DATA_COUNT_WIDTH(1)
	)
	U3
	(
		.m_aclk(clk),
		.s_aclk(clk),
		.s_aresetn(rst_n),

		.prog_full_axis(),
		.prog_empty_axis(),

		.s_axis_tdata(s_axis_len_tdata),
		.s_axis_tvalid(s_axis_len_tvalid),
		.s_axis_tready(s_axis_len_tready),

		.m_axis_tdata(m_axis_len_tdata),
		.m_axis_tvalid(m_axis_len_tvalid),
		.m_axis_tready(m_axis_len_tready),

		.s_axis_tstrb(1'b0),
		.s_axis_tlast(1'b0),
		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tuser(1'b0),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);

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
		U4
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

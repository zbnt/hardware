/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module bpi_flash_read_fsm
#(
	parameter C_AXI_WIDTH = 32,
	parameter C_FIFO_DEPTH = 128,

	parameter C_MEM_WIDTH = 16,
	parameter C_MEM_SIZE = 134217728
)
(
	input logic clk,
	input logic rst_n,

	input logic enable,
	output logic active,

	// S_AXI

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	output logic s_axi_rlast,
	input logic s_axi_rready,

	// S_AXIS_RQ

	input logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] s_axis_rq_tdata,
	input logic [9:0] s_axis_rq_tuser, // {length, burst, error}
	input logic s_axis_rq_tvalid,
	output logic s_axis_rq_tready,

	// S_AXIS_RD

	input logic [C_MEM_WIDTH-1:0] s_axis_rd_tdata,
	input logic s_axis_rd_tvalid,

	// M_AXIS_RD

	output logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] m_axis_rd_tdata,
	output logic m_axis_rd_tvalid,
	input logic m_axis_rd_tready
);
	enum logic [2:0] {ST_IDLE, ST_FIX_ALIGNMENT, ST_EXEC_RAW_RD, ST_EXEC_BURST_RD, ST_EXEC_ERROR} state;

	localparam C_COUNT_WIDTH = (C_AXI_WIDTH == C_MEM_WIDTH) ? 1 : $clog2(C_AXI_WIDTH/C_MEM_WIDTH);

	logic [C_COUNT_WIDTH-1:0] count;
	logic [(C_AXI_WIDTH/C_MEM_WIDTH)-1:0] count_1h;
	logic overflow, overflow_q;

	logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] curr_addr, curr_end;
	logic [C_AXI_WIDTH-1:0] curr_buffer;
	logic [7:0] curr_len;
	logic curr_burst, curr_unaligned, curr_fifo_overflow;

	logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] queued_addr;
	logic [7:0] queued_len;
	logic queued_error, queued_burst, queued_combine, queued_valid;

	logic [C_AXI_WIDTH-1:0] s_fifo_tdata;
	logic s_fifo_tuser, s_fifo_tlast, s_fifo_tvalid, s_fifo_tready;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;
			active <= 1'b0;

			count <= 'd1;
			count_1h <= 'd1;
			overflow <= 1'b0;
			overflow_q <= 1'b0;

			curr_addr <= '0;
			curr_end <= '0;
			curr_buffer <= '0;
			curr_len <= '0;
			curr_burst <= 1'b0;
			curr_unaligned <= 1'b0;
			curr_fifo_overflow <= 1'b0;

			queued_addr <= '0;
			queued_len <= '0;
			queued_error <= 1'b0;
			queued_burst <= 1'b0;
			queued_combine <= 1'b0;
			queued_valid <= 1'b0;

			m_axis_rd_tdata <= '0;
			m_axis_rd_tvalid <= 1'b0;

			s_fifo_tdata <= '0;
			s_fifo_tuser <= 1'b0;
			s_fifo_tlast <= 1'b0;
			s_fifo_tvalid <= 1'b0;

			s_axis_rq_tready <= 1'b0;
		end else begin
			if(overflow) begin
				overflow_q <= 1'b1;
			end

			case(state)
				ST_IDLE: begin
					s_axis_rq_tready <= enable;

					active <= 1'b0;

					count <= 'd1;
					count_1h <= 'd1;
					overflow <= 1'b0;
					overflow_q <= 1'b0;

					curr_buffer <= '0;
					curr_fifo_overflow <= 1'b0;

					s_fifo_tdata <= '0;

					if(queued_valid) begin
						// We prefetched another request, but it wasn't possible to combine it with the previous one
						// Execute it before fetching another one

						if(queued_error) begin
							state <= ST_EXEC_ERROR;
						end else begin
							if(C_AXI_WIDTH == C_MEM_WIDTH || queued_addr[C_COUNT_WIDTH-1:0] == '0) begin
								curr_unaligned <= 1'b0;

								if(queued_burst) begin
									state <= ST_EXEC_BURST_RD;
								end else begin
									state <= ST_EXEC_RAW_RD;
								end
							end else begin
								state <= ST_FIX_ALIGNMENT;
								curr_burst <= queued_burst;
								curr_unaligned <= 1'b1;
							end
						end

						active <= 1'b1;

						curr_addr <= queued_addr;
						curr_len <= queued_len;

						queued_valid <= 1'b0;
						s_axis_rq_tready <= 1'b0;
					end else if(s_axis_rq_tready & s_axis_rq_tvalid) begin
						// Nothing pending to execute, proceed with the request in s_axis_rq

						if(s_axis_rq_tuser[0]) begin
							state <= ST_EXEC_ERROR;
						end else begin
							if(C_AXI_WIDTH == C_MEM_WIDTH || s_axis_rq_tdata[C_COUNT_WIDTH-1:0] == '0) begin
								curr_unaligned <= 1'b0;

								if(s_axis_rq_tuser[1]) begin
									state <= ST_EXEC_BURST_RD;
								end else begin
									state <= ST_EXEC_RAW_RD;
								end
							end else begin
								state <= ST_FIX_ALIGNMENT;
								curr_burst <= s_axis_rq_tuser[1];
								curr_unaligned <= 1'b1;
							end
						end

						active <= 1'b1;

						curr_addr <= s_axis_rq_tdata;
						curr_len <= s_axis_rq_tuser[9:2];

						s_axis_rq_tready <= 1'b0;
					end
				end

				ST_FIX_ALIGNMENT: begin
					count <= count + 'd1;
					count_1h <= {count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-2:0], count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-1]};

					if(count == curr_addr[$clog2(C_AXI_WIDTH/8)-1:0]) begin
						if(curr_burst) begin
							state <= ST_EXEC_BURST_RD;
						end else begin
							state <= ST_EXEC_RAW_RD;
						end
					end
				end

				ST_EXEC_RAW_RD: begin
					s_fifo_tuser <= 1'b0;
					s_fifo_tlast <= 1'b1;

					// Request data from memory

					if(~m_axis_rd_tvalid & ~s_axis_rd_tvalid & ~s_fifo_tvalid) begin
						if(~overflow & ~overflow_q) begin
							m_axis_rd_tdata <= curr_addr;
							m_axis_rd_tvalid <= 1'b1;
						end else begin
							s_fifo_tvalid <= 1'b1;
						end
					end

					// Receive a single mem-word

					if(s_axis_rd_tvalid & m_axis_rd_tvalid & m_axis_rd_tready) begin
						count_1h <= {count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-2:0], count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-1]};

						{overflow, curr_addr} <= curr_addr + 'd1;

						// HACK: double-loop required in order to avoid synthesis error

						for(int i = 0; i < C_AXI_WIDTH/C_MEM_WIDTH; ++i) begin
							for(int j = 0; j < C_MEM_WIDTH; ++j) begin
								if(count_1h[i]) begin
									s_fifo_tdata[C_MEM_WIDTH*i + j] <= s_axis_rd_tdata[j];
								end
							end
						end

						s_fifo_tvalid <= count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-1];

						m_axis_rd_tvalid <= 1'b0;
					end

					// Store the complete axi-word in FIFO

					if(s_fifo_tvalid & s_fifo_tready) begin
						state <= ST_IDLE;
						s_fifo_tvalid <= 1'b0;
					end
				end

				ST_EXEC_BURST_RD: begin
					s_fifo_tuser <= 1'b0;

					// Try to prefetch another request if we haven't done so already, but only if the active request is aligned
					// to C_AXI_WIDTH and doesn't end beyond the memory limit

					if(~queued_valid & ~curr_unaligned) begin
						s_axis_rq_tready <= 1'b1;

						if(s_axis_rq_tready & s_axis_rq_tvalid) begin
							queued_addr <= s_axis_rq_tdata;
							queued_len <= s_axis_rq_tuser[9:2];
							queued_burst <= s_axis_rq_tuser[1];
							queued_error <= s_axis_rq_tuser[0];
							queued_valid <= 1'b1;

							// We can combine curr and queued if queued is a burst that starts right where curr ends
							queued_combine <= (s_axis_rq_tdata == curr_end && s_axis_rq_tuser[1] && ~s_axis_rq_tuser[0]);

							s_axis_rq_tready <= 1'b0;
						end
					end

					// Request data from memory

					if(~m_axis_rd_tvalid & ~s_axis_rd_tvalid & ~s_fifo_tvalid) begin
						m_axis_rd_tdata <= curr_addr;
						m_axis_rd_tvalid <= 1'b1;
					end

					// Receive a single mem-word

					if(s_axis_rd_tvalid & ~overflow) begin
						if(~s_fifo_tvalid | s_fifo_tready) begin
							count_1h <= {count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-2:0], count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-1]};

							{overflow, curr_addr} <= curr_addr + 'd1;

							// HACK: double-loop required in order to avoid synthesis error

							for(int i = 0; i < C_AXI_WIDTH/C_MEM_WIDTH; ++i) begin
								for(int j = 0; j < C_MEM_WIDTH; ++j) begin
									if(count_1h[i]) begin
										s_fifo_tdata[C_MEM_WIDTH*i + j] <= s_axis_rd_tdata[j];
									end
								end
							end

							if(count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-1]) begin
								if(curr_len == 8'd0) begin
									// We're done with this request
									s_fifo_tlast <= 1'b1;

									if(queued_valid & queued_combine) begin
										// Don't stop the data burst, we can combine with the queued request
										curr_len <= queued_len;
										queued_valid <= 1'b0;
									end else begin
										m_axis_rd_tvalid <= 1'b0;
									end
								end else begin
									s_fifo_tlast <= 1'b0;
									curr_len <= curr_len - 8'd1;
								end

								s_fifo_tvalid <= 1'b1;
							end else begin
								s_fifo_tvalid <= 1'b0;
							end
						end else begin
							// The FIFO is full, stop bursting until we can store the axi-word we just read
							curr_fifo_overflow <= 1'b1;
							m_axis_rd_tvalid <= 1'b0;
						end
					end

					if(overflow & ~s_fifo_tvalid) begin
						state <= ST_EXEC_ERROR;
						m_axis_rd_tvalid <= 1'b0;
					end

					// Store the complete axi-word in FIFO

					if(s_fifo_tvalid & s_fifo_tready) begin
						if(curr_fifo_overflow) begin
							curr_fifo_overflow <= 1'b0;
						end

						if(curr_fifo_overflow | overflow) begin
							s_fifo_tvalid <= 1'b0;
						end

						if(s_fifo_tlast && curr_len == 8'd0) begin
							// The request has been completed, go back to idle state
							state <= ST_IDLE;
						end
					end
				end

				ST_EXEC_ERROR: begin
					s_fifo_tdata <= '0;
					s_fifo_tuser <= 1'b1;
					s_fifo_tlast <= (curr_len <= 8'd1);
					s_fifo_tvalid <= 1'b1;

					// Store the response in FIFO

					if(s_fifo_tvalid & s_fifo_tready) begin
						curr_len <= curr_len - 8'd1;

						if(s_fifo_tlast) begin
							state <= ST_IDLE;
							s_fifo_tvalid <= 1'b0;
						end
					end
				end

				default: begin
					state <= ST_IDLE;
				end
			endcase
		end
	end

	// FIFO

	always_comb begin
		s_axi_rresp[0] = 1'b0;
	end

	xpm_fifo_axis
	#(
		.CDC_SYNC_STAGES(2),
		.CLOCKING_MODE("common_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(C_FIFO_DEPTH),
		.FIFO_MEMORY_TYPE("block"),
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
	U1
	(
		.m_aclk(clk),
		.s_aclk(clk),
		.s_aresetn(rst_n),

		.prog_full_axis(),
		.prog_empty_axis(),

		.s_axis_tdata(s_fifo_tdata),
		.s_axis_tlast(s_fifo_tlast),
		.s_axis_tuser(s_fifo_tuser),
		.s_axis_tvalid(s_fifo_tvalid),
		.s_axis_tready(s_fifo_tready),

		.m_axis_tdata(s_axi_rdata),
		.m_axis_tlast(s_axi_rlast),
		.m_axis_tuser(s_axi_rresp[1]),
		.m_axis_tvalid(s_axi_rvalid),
		.m_axis_tready(s_axi_rready),

		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tstrb(1'b1),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);
endmodule

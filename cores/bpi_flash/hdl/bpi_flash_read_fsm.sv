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
	input logic s_axis_rd_tlast,
	input logic s_axis_rd_tvalid,
	output logic s_axis_rd_tready,

	// M_AXIS_RD

	output logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] m_axis_rd_tdata,
	output logic [$clog2(256 * (C_AXI_WIDTH/C_MEM_WIDTH))-1:0] m_axis_rd_tuser,
	output logic m_axis_rd_tvalid,
	input logic m_axis_rd_tready
);
	enum logic [2:0] {ST_IDLE, ST_FIX_ALIGNMENT, ST_EXEC_RAW_RD, ST_EXEC_BURST_RD, ST_EXEC_ERROR} state;

	localparam C_COUNT_WIDTH = (C_AXI_WIDTH == C_MEM_WIDTH) ? 1 : $clog2(C_AXI_WIDTH/C_MEM_WIDTH);

	logic [C_COUNT_WIDTH-1:0] count;
	logic [(C_AXI_WIDTH/C_MEM_WIDTH)-1:0] count_1h;

	logic [C_AXI_WIDTH-1:0] curr_buffer;
	logic curr_burst;

	logic [C_AXI_WIDTH-1:0] s_fifo_tdata;
	logic s_fifo_tuser, s_fifo_tlast, s_fifo_tvalid, s_fifo_tready;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;
			active <= 1'b0;

			count <= 'd1;
			count_1h <= 'd1;

			curr_buffer <= '0;
			curr_burst <= 1'b0;

			m_axis_rd_tdata <= '0;
			m_axis_rd_tuser <= '0;
			m_axis_rd_tvalid <= 1'b0;

			s_fifo_tdata <= '0;
			s_fifo_tuser <= 1'b0;
			s_fifo_tlast <= 1'b0;
			s_fifo_tvalid <= 1'b0;

			s_axis_rq_tready <= 1'b0;
		end else begin
			case(state)
				ST_IDLE: begin
					active <= 1'b0;

					count <= 'd1;
					count_1h <= 'd1;

					curr_buffer <= '0;
					curr_burst <= 1'b0;

					m_axis_rd_tdata <= '0;
					m_axis_rd_tuser <= '0;
					m_axis_rd_tvalid <= 1'b0;

					s_fifo_tdata <= '0;
					s_fifo_tuser <= 1'b0;
					s_fifo_tlast <= 1'b0;
					s_fifo_tvalid <= 1'b0;

					s_axis_rq_tready <= enable;

					if(s_axis_rq_tready & s_axis_rq_tvalid) begin
						if(s_axis_rq_tuser[0]) begin
							state <= ST_EXEC_ERROR;

							m_axis_rd_tdata <= s_axis_rq_tdata;
							m_axis_rd_tuser <= s_axis_rq_tuser[9:2];
							m_axis_rd_tvalid <= 1'b0;
						end else begin
							m_axis_rd_tdata <= s_axis_rq_tdata;

							if(s_axis_rq_tuser[1]) begin
								m_axis_rd_tuser <= s_axis_rq_tuser[9:2] * (C_AXI_WIDTH/C_MEM_WIDTH) + (C_AXI_WIDTH/C_MEM_WIDTH - 'd1);
							end else begin
								m_axis_rd_tuser <= '0;
							end

							if(C_AXI_WIDTH == C_MEM_WIDTH || s_axis_rq_tdata[C_COUNT_WIDTH-1:0] == '0) begin
								if(s_axis_rq_tuser[1]) begin
									state <= ST_EXEC_BURST_RD;
								end else begin
									state <= ST_EXEC_RAW_RD;
								end

								m_axis_rd_tvalid <= 1'b1;
							end else begin
								state <= ST_FIX_ALIGNMENT;
								curr_burst <= s_axis_rq_tuser[1];

								m_axis_rd_tvalid <= 1'b0;
							end
						end

						active <= 1'b1;
						s_axis_rq_tready <= 1'b0;
					end
				end

				ST_FIX_ALIGNMENT: begin
					count <= count + 'd1;
					count_1h <= {count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-2:0], count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-1]};

					if(count == m_axis_rd_tdata[$clog2(C_AXI_WIDTH/8)-1:0]) begin
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

					if(m_axis_rd_tready) begin
						m_axis_rd_tvalid <= 1'b0;
					end

					if(s_fifo_tvalid & s_fifo_tready) begin
						state <= ST_IDLE;
						s_fifo_tvalid <= 1'b0;
					end

					if(s_axis_rd_tready & s_axis_rd_tvalid) begin
						count_1h <= {count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-2:0], count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-1]};

						// HACK: double-loop required in order to avoid synthesis error

						for(int i = 0; i < C_AXI_WIDTH/C_MEM_WIDTH; ++i) begin
							for(int j = 0; j < C_MEM_WIDTH; ++j) begin
								if(count_1h[i]) begin
									s_fifo_tdata[C_MEM_WIDTH*i + j] <= s_axis_rd_tdata[j];
								end
							end
						end

						if(count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-1]) begin
							s_fifo_tlast <= 1'b1;
							s_fifo_tvalid <= 1'b1;
						end else begin
							s_fifo_tvalid <= 1'b0;

							m_axis_rd_tdata <= m_axis_rd_tdata + 'd1;
							m_axis_rd_tvalid <= 1'b1;
						end
					end
				end

				ST_EXEC_BURST_RD: begin
					s_fifo_tuser <= 1'b0;

					if(m_axis_rd_tready) begin
						m_axis_rd_tvalid <= 1'b0;
					end

					if(s_axis_rd_tready & s_axis_rd_tvalid) begin
						count_1h <= {count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-2:0], count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-1]};

						// HACK: double-loop required in order to avoid synthesis error

						for(int i = 0; i < C_AXI_WIDTH/C_MEM_WIDTH; ++i) begin
							for(int j = 0; j < C_MEM_WIDTH; ++j) begin
								if(count_1h[i]) begin
									s_fifo_tdata[C_MEM_WIDTH*i + j] <= s_axis_rd_tdata[j];
								end
							end
						end
					end

					if(s_fifo_tready) begin
						s_fifo_tlast <= s_axis_rd_tvalid & s_axis_rd_tlast & ~s_fifo_tlast;
						s_fifo_tvalid <= s_axis_rd_tvalid & count_1h[(C_AXI_WIDTH/C_MEM_WIDTH)-1];
					end

					if(s_fifo_tvalid & s_fifo_tready & s_fifo_tlast) begin
						state <= ST_IDLE;
					end
				end

				ST_EXEC_ERROR: begin
					s_fifo_tdata <= '0;
					s_fifo_tuser <= 1'b1;
					s_fifo_tlast <= (m_axis_rd_tuser[7:0] <= 8'd1);
					s_fifo_tvalid <= 1'b1;

					// Store the response in FIFO

					if(s_fifo_tvalid & s_fifo_tready) begin
						m_axis_rd_tuser <= m_axis_rd_tuser - 8'd1;

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

	always_comb begin
		s_axis_rd_tready = s_fifo_tready;
	end

	// FIFO

	always_comb begin
		s_axi_rresp[0] = 1'b0;
	end

	if(C_FIFO_DEPTH != 0) begin
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
	end else begin
		always_comb begin
			s_axi_rdata = s_fifo_tdata;
			s_axi_rlast = s_fifo_tlast;
			s_axi_rresp[1] = s_fifo_tuser;
			s_axi_rvalid = s_fifo_tvalid;
			s_fifo_tready = s_axi_rready;
		end
	end
endmodule

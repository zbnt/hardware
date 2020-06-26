/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module bpi_flash_write_fsm
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
	input logic enable_fifo,
	output logic active,

	// S_AXI

	input logic [C_AXI_WIDTH-1:0] s_axi_wdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input logic s_axi_wlast,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	// S_AXIS_RQ

	input logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] s_axis_rq_tdata,
	input logic s_axis_rq_tuser,
	input logic s_axis_rq_tvalid,
	output logic s_axis_rq_tready,

	// M_AXIS_WR

	output logic [C_MEM_WIDTH-1:0] m_axis_wr_tdata,
	output logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] m_axis_wr_tdest,
	output logic m_axis_wr_tvalid,
	input logic m_axis_wr_tready
);
	enum logic [1:0] {ST_IDLE, ST_READ_FIFO, ST_EXEC_WRITE, ST_WRITE_RESP} state;

	logic op_end, op_error;
	logic [2:0] op_overflow;
	logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] op_addr;

	logic [C_MEM_WIDTH-1:0] m_fifo_tdata;
	logic [$clog2(C_AXI_WIDTH/C_MEM_WIDTH)+1:0] m_fifo_tuser; // {offset, strb_valid, axi_word_end}
	logic m_fifo_tlast, m_fifo_tvalid, m_fifo_tready;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;
			active <= 1'b0;

			m_axis_wr_tdata <= '0;
			m_axis_wr_tdest <= '0;
			m_axis_wr_tvalid <= 1'b0;
			s_axis_rq_tready <= 1'b0;
			m_fifo_tready <= 1'b0;

			s_axi_bresp <= 2'b0;
			s_axi_bvalid <= 1'b0;

			op_end <= 1'b0;
			op_error <= 1'b0;
			op_overflow <= 3'b0;
			op_addr <= '0;
		end else begin
			if(op_overflow[1:0] != 2'd0) begin
				op_overflow[2] <= 1'b1;
			end

			case(state)
				ST_IDLE: begin
					s_axis_rq_tready <= enable;

					active <= 1'b0;
					op_end <= 1'b0;
					op_overflow <= 3'b0;

					if(s_axis_rq_tready & s_axis_rq_tvalid) begin
						state <= ST_READ_FIFO;
						active <= 1'b1;

						op_addr <= s_axis_rq_tdata;
						op_error <= s_axis_rq_tuser;

						s_axis_rq_tready <= 1'b0;
					end
				end

				ST_READ_FIFO: begin
					m_fifo_tready <= 1'b1;

					if(m_fifo_tready & m_fifo_tvalid) begin
						m_axis_wr_tdata <= m_fifo_tdata;

						if(C_AXI_WIDTH != C_MEM_WIDTH) begin
							{op_overflow[0], m_axis_wr_tdest} <= op_addr + m_fifo_tuser[$clog2(C_AXI_WIDTH/C_MEM_WIDTH)+1:2];
						end else begin
							m_axis_wr_tdest <= op_addr;
						end

						if(m_fifo_tuser[0]) begin
							{op_overflow[1], op_addr} <= op_addr + C_AXI_WIDTH/C_MEM_WIDTH;
						end

						op_end <= m_fifo_tlast;

						if(~op_overflow[2] & ~op_error & m_fifo_tuser[1]) begin
							state <= ST_EXEC_WRITE;
							m_fifo_tready <= 1'b0;
						end else if(m_fifo_tlast) begin
							state <= ST_WRITE_RESP;
							m_fifo_tready <= 1'b0;
						end
					end
				end

				ST_EXEC_WRITE: begin
					m_axis_wr_tvalid <= 1'b1;

					if((m_axis_wr_tready & m_axis_wr_tvalid) | op_overflow[0]) begin
						if(~op_end) begin
							state <= ST_READ_FIFO;
						end else begin
							state <= ST_WRITE_RESP;
						end

						m_axis_wr_tvalid <= 1'b0;
					end
				end

				ST_WRITE_RESP: begin
					s_axi_bresp <= {op_error, 1'b0};
					s_axi_bvalid <= 1'b1;

					if(s_axi_bready & s_axi_bvalid) begin
						state <= ST_IDLE;
						active <= 1'b0;

						s_axi_bvalid <= 1'b0;
					end
				end
			endcase
		end
	end

	// FIFO

	bpi_flash_write_fifo
	#(
		C_AXI_WIDTH,
		C_MEM_WIDTH,
		C_FIFO_DEPTH
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.enable(enable_fifo),

		// S_AXI

		.s_axi_wdata(s_axi_wdata),
		.s_axi_wstrb(s_axi_wstrb),
		.s_axi_wlast(s_axi_wlast),
		.s_axi_wvalid(s_axi_wvalid),
		.s_axi_wready(s_axi_wready),

		// M_AXIS_WR

		.m_axis_tdata(m_fifo_tdata),
		.m_axis_tuser(m_fifo_tuser),
		.m_axis_tlast(m_fifo_tlast),
		.m_axis_tvalid(m_fifo_tvalid),
		.m_axis_tready(m_fifo_tready)
	);
endmodule

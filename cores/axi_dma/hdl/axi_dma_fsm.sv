/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_dma_fsm
#(
	parameter C_AXI_WIDTH = 64,
	parameter C_AXI_ADDR_WIDTH_H = 64,
	parameter C_AXI_ADDR_WIDTH_F = 32,
	parameter C_AXI_MAX_BURST = 255,
	parameter C_FIFO_SIZE = 256,
	parameter C_FIFO_TYPE = "block",
	parameter C_MAX_SG_ENTRIES = 64
)
(
	input logic clk,
	input logic rst_n,

	output logic irq,
	input logic irq_en,
	input logic irq_clr,

	input logic trigger,
	input logic direction,
	input logic [C_AXI_ADDR_WIDTH_F-1:0] fpga_addr,

	output logic busy,
	output logic [3:0] response,

	input logic [$clog2(C_MAX_SG_ENTRIES+1)-1:0] sg_occupancy,

	// S_AXIS_SG

	input logic [C_AXI_ADDR_WIDTH_H+15:0] s_axis_sg_tdata,
	input logic s_axis_sg_tvalid,
	output logic s_axis_sg_tready,

	// M_AXI_FPGA

	output logic [C_AXI_ADDR_WIDTH_F-1:0] m_axi_fpga_awaddr,
	output logic [7:0] m_axi_fpga_awlen,
	output logic [2:0] m_axi_fpga_awsize,
	output logic m_axi_fpga_awvalid,
	input logic m_axi_fpga_awready,

	output logic [C_AXI_WIDTH-1:0] m_axi_fpga_wdata,
	output logic [(C_AXI_WIDTH/8)-1:0] m_axi_fpga_wstrb,
	output logic m_axi_fpga_wlast,
	output logic m_axi_fpga_wvalid,
	input logic m_axi_fpga_wready,

	input logic [1:0] m_axi_fpga_bresp,
	input logic m_axi_fpga_bvalid,
	output logic m_axi_fpga_bready,

	output logic [C_AXI_ADDR_WIDTH_F-1:0] m_axi_fpga_araddr,
	output logic [7:0] m_axi_fpga_arlen,
	output logic [2:0] m_axi_fpga_arsize,
	output logic m_axi_fpga_arvalid,
	input logic m_axi_fpga_arready,

	input logic [C_AXI_WIDTH-1:0] m_axi_fpga_rdata,
	input logic [1:0] m_axi_fpga_rresp,
	input logic m_axi_fpga_rvalid,
	input logic m_axi_fpga_rlast,
	output logic m_axi_fpga_rready,

	// M_AXI_HOST

	output logic [C_AXI_ADDR_WIDTH_H-1:0] m_axi_host_awaddr,
	output logic [7:0] m_axi_host_awlen,
	output logic [2:0] m_axi_host_awsize,
	output logic m_axi_host_awvalid,
	input logic m_axi_host_awready,

	output logic [C_AXI_WIDTH-1:0] m_axi_host_wdata,
	output logic [(C_AXI_WIDTH/8)-1:0] m_axi_host_wstrb,
	output logic m_axi_host_wlast,
	output logic m_axi_host_wvalid,
	input logic m_axi_host_wready,

	input logic [1:0] m_axi_host_bresp,
	input logic m_axi_host_bvalid,
	output logic m_axi_host_bready,

	output logic [C_AXI_ADDR_WIDTH_H-1:0] m_axi_host_araddr,
	output logic [7:0] m_axi_host_arlen,
	output logic [2:0] m_axi_host_arsize,
	output logic m_axi_host_arvalid,
	input logic m_axi_host_arready,

	input logic [C_AXI_WIDTH-1:0] m_axi_host_rdata,
	input logic [1:0] m_axi_host_rresp,
	input logic m_axi_host_rvalid,
	input logic m_axi_host_rlast,
	output logic m_axi_host_rready
);
	enum logic [1:0] {ST_IDLE, ST_FETCH_SG, ST_WAIT_IO, ST_DONE} state;

	logic io_trigger, io_opcode;
	logic io_busy_f, io_busy_h;
	logic [3:0] io_response_f, io_response_h;
	logic [15:0] io_bytes;

	logic [C_AXI_ADDR_WIDTH_F-1:0] io_addr_f;
	logic [C_AXI_ADDR_WIDTH_H-1:0] io_addr_h;

	logic [C_AXI_WIDTH-1:0] axis_h2f_tdata, axis_f2h_tdata;
	logic [C_AXI_WIDTH/8-1:0] axis_h2f_tstrb, axis_f2h_tstrb;
	logic axis_h2f_tlast, axis_f2h_tlast;
	logic axis_h2f_tvalid, axis_f2h_tvalid;
	logic axis_h2f_tready, axis_f2h_tready;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;

			irq <= 1'b0;
			busy <= 1'b0;
			response <= 4'd0;

			io_trigger <= 1'b0;
			io_opcode <= 1'b0;
			io_bytes <= 16'd0;
			io_addr_f <= '0;
			io_addr_h <= '0;

			s_axis_sg_tready <= 1'b0;
		end else begin
			io_trigger <= 1'b0;

			case(state)
				ST_IDLE: begin
					busy <= 1'b0;
					s_axis_sg_tready <= 1'b0;

					if(trigger && sg_occupancy != '0) begin
						state <= ST_FETCH_SG;

						io_opcode <= direction;
						io_addr_f <= fpga_addr;

						busy <= 1'b1;
						response <= 4'd0;
						s_axis_sg_tready <= 1'b1;
					end
				end

				ST_FETCH_SG: begin
					busy <= 1'b1;
					s_axis_sg_tready <= 1'b1;

					if(s_axis_sg_tready & s_axis_sg_tvalid) begin
						state <= ST_WAIT_IO;
						io_trigger <= 1'b1;

						io_addr_h <= s_axis_sg_tdata[C_AXI_ADDR_WIDTH_H+15:16];
						io_bytes <= s_axis_sg_tdata[15:0];

						s_axis_sg_tready <= 1'b0;
					end
				end

				ST_WAIT_IO: begin
					busy <= 1'b1;

					if(~io_busy_f & ~io_busy_h & ~io_trigger) begin
						if(sg_occupancy == '0) begin
							state <= ST_DONE;
							irq <= irq_en;
						end else begin
							state <= ST_FETCH_SG;
							s_axis_sg_tready <= 1'b1;
						end

						if(response[1:0] <= 2'd1) begin
							response[1:0] <= io_response_f;
						end

						if(response[3:2] <= 2'd1) begin
							response[3:2] <= io_response_h;
						end

						io_addr_f <= io_addr_f + io_bytes + 'd1;
					end
				end

				ST_DONE: begin
					busy <= 1'b0;

					if(irq_clr) begin
						irq <= 1'b0;
					end

					if(~irq) begin
						state <= ST_IDLE;
					end
				end
			endcase
		end
	end

	axi_dma_io
	#(
		.C_AXI_WIDTH(C_AXI_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH_F),
		.C_AXI_MAX_BURST(C_AXI_MAX_BURST),
		.C_FIFO_SIZE(C_FIFO_SIZE),
		.C_FIFO_TYPE(C_FIFO_TYPE)
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.busy(io_busy_f),
		.response(io_response_f),

		.trigger(io_trigger),
		.opcode(io_opcode),
		.start_addr(io_addr_f),
		.num_bytes(io_bytes),

		// M_AXI

		.m_axi_araddr(m_axi_fpga_araddr),
		.m_axi_arlen(m_axi_fpga_arlen),
		.m_axi_arsize(m_axi_fpga_arsize),
		.m_axi_arvalid(m_axi_fpga_arvalid),
		.m_axi_arready(m_axi_fpga_arready),

		.m_axi_rdata(m_axi_fpga_rdata),
		.m_axi_rresp(m_axi_fpga_rresp),
		.m_axi_rvalid(m_axi_fpga_rvalid),
		.m_axi_rlast(m_axi_fpga_rlast),
		.m_axi_rready(m_axi_fpga_rready),

		.m_axi_awaddr(m_axi_fpga_awaddr),
		.m_axi_awlen(m_axi_fpga_awlen),
		.m_axi_awsize(m_axi_fpga_awsize),
		.m_axi_awvalid(m_axi_fpga_awvalid),
		.m_axi_awready(m_axi_fpga_awready),

		.m_axi_wdata(m_axi_fpga_wdata),
		.m_axi_wstrb(m_axi_fpga_wstrb),
		.m_axi_wlast(m_axi_fpga_wlast),
		.m_axi_wvalid(m_axi_fpga_wvalid),
		.m_axi_wready(m_axi_fpga_wready),

		.m_axi_bresp(m_axi_fpga_bresp),
		.m_axi_bvalid(m_axi_fpga_bvalid),
		.m_axi_bready(m_axi_fpga_bready),

		// M_AXIS

		.m_axis_tdata(axis_f2h_tdata),
		.m_axis_tstrb(axis_f2h_tstrb),
		.m_axis_tlast(axis_f2h_tlast),
		.m_axis_tvalid(axis_f2h_tvalid),
		.m_axis_tready(axis_f2h_tready),

		// S_AXIS

		.s_axis_tdata(axis_h2f_tdata),
		.s_axis_tstrb(axis_h2f_tstrb),
		.s_axis_tlast(axis_h2f_tlast),
		.s_axis_tvalid(axis_h2f_tvalid),
		.s_axis_tready(axis_h2f_tready)
	);

	axi_dma_io
	#(
		.C_AXI_WIDTH(C_AXI_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH_H),
		.C_AXI_MAX_BURST(C_AXI_MAX_BURST),
		.C_FIFO_SIZE(C_FIFO_SIZE),
		.C_FIFO_TYPE(C_FIFO_TYPE)
	)
	U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.busy(io_busy_h),
		.response(io_response_h),

		.trigger(io_trigger),
		.opcode(~io_opcode),
		.start_addr(io_addr_h),
		.num_bytes(io_bytes),

		// M_AXI

		.m_axi_araddr(m_axi_host_araddr),
		.m_axi_arlen(m_axi_host_arlen),
		.m_axi_arsize(m_axi_host_arsize),
		.m_axi_arvalid(m_axi_host_arvalid),
		.m_axi_arready(m_axi_host_arready),

		.m_axi_rdata(m_axi_host_rdata),
		.m_axi_rresp(m_axi_host_rresp),
		.m_axi_rvalid(m_axi_host_rvalid),
		.m_axi_rlast(m_axi_host_rlast),
		.m_axi_rready(m_axi_host_rready),

		.m_axi_awaddr(m_axi_host_awaddr),
		.m_axi_awlen(m_axi_host_awlen),
		.m_axi_awsize(m_axi_host_awsize),
		.m_axi_awvalid(m_axi_host_awvalid),
		.m_axi_awready(m_axi_host_awready),

		.m_axi_wdata(m_axi_host_wdata),
		.m_axi_wstrb(m_axi_host_wstrb),
		.m_axi_wlast(m_axi_host_wlast),
		.m_axi_wvalid(m_axi_host_wvalid),
		.m_axi_wready(m_axi_host_wready),

		.m_axi_bresp(m_axi_host_bresp),
		.m_axi_bvalid(m_axi_host_bvalid),
		.m_axi_bready(m_axi_host_bready),

		// M_AXIS

		.m_axis_tdata(axis_h2f_tdata),
		.m_axis_tstrb(axis_h2f_tstrb),
		.m_axis_tlast(axis_h2f_tlast),
		.m_axis_tvalid(axis_h2f_tvalid),
		.m_axis_tready(axis_h2f_tready),

		// S_AXIS

		.s_axis_tdata(axis_f2h_tdata),
		.s_axis_tstrb(axis_f2h_tstrb),
		.s_axis_tlast(axis_f2h_tlast),
		.s_axis_tvalid(axis_f2h_tvalid),
		.s_axis_tready(axis_f2h_tready)
	);
endmodule

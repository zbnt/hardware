/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_dma_io
#(
	parameter C_AXI_WIDTH = 64,
	parameter C_AXI_ADDR_WIDTH = 32,
	parameter C_AXI_MAX_BURST = 255,
	parameter C_FIFO_SIZE = 256,
	parameter C_FIFO_TYPE = "block"
)
(
	input logic clk,
	input logic rst_n,

	output logic busy,
	output logic [3:0] response,

	input logic trigger,
	input logic opcode,
	input logic [C_AXI_ADDR_WIDTH-1:0] start_addr,
	input logic [15:0] num_bytes,

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

	// M_AXIS

	output logic [C_AXI_WIDTH-1:0] m_axis_tdata,
	output logic [(C_AXI_WIDTH/8)-1:0] m_axis_tstrb,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready,

	// S_AXIS

	input logic [C_AXI_WIDTH-1:0] s_axis_tdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axis_tstrb,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready
);
	logic mm2s_busy, s2mm_busy;

	always_comb begin
		busy = mm2s_busy | s2mm_busy;
	end

	axi_mm2s_io
	#(
		.C_AXI_WIDTH(C_AXI_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.C_AXI_MAX_BURST(C_AXI_MAX_BURST),
		.C_FIFO_SIZE(C_FIFO_SIZE),
		.C_FIFO_TYPE(C_FIFO_TYPE)
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.busy(mm2s_busy),
		.response(response[1:0]),

		.trigger(trigger & ~opcode & ~s2mm_busy),
		.start_addr(start_addr),
		.bytes_to_read(num_bytes),

		// M_AXI

		.m_axi_araddr(m_axi_araddr),
		.m_axi_arlen(m_axi_arlen),
		.m_axi_arsize(m_axi_arsize),
		.m_axi_arvalid(m_axi_arvalid),
		.m_axi_arready(m_axi_arready),

		.m_axi_rdata(m_axi_rdata),
		.m_axi_rresp(m_axi_rresp),
		.m_axi_rvalid(m_axi_rvalid),
		.m_axi_rlast(m_axi_rlast),
		.m_axi_rready(m_axi_rready),

		// M_AXIS

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tstrb(m_axis_tstrb),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);

	axi_s2mm_io
	#(
		.C_AXI_WIDTH(C_AXI_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.C_AXI_MAX_BURST(C_AXI_MAX_BURST),
		.C_FIFO_SIZE(16),
		.C_FIFO_TYPE("none")
	)
	U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.busy(s2mm_busy),
		.response(response[3:2]),

		.trigger(trigger & opcode & ~mm2s_busy),
		.start_addr(start_addr),
		.bytes_to_write(num_bytes),

		// M_AXI

		.m_axi_awaddr(m_axi_awaddr),
		.m_axi_awlen(m_axi_awlen),
		.m_axi_awsize(m_axi_awsize),
		.m_axi_awvalid(m_axi_awvalid),
		.m_axi_awready(m_axi_awready),

		.m_axi_wdata(m_axi_wdata),
		.m_axi_wstrb(m_axi_wstrb),
		.m_axi_wlast(m_axi_wlast),
		.m_axi_wvalid(m_axi_wvalid),
		.m_axi_wready(m_axi_wready),

		.m_axi_bresp(m_axi_bresp),
		.m_axi_bvalid(m_axi_bvalid),
		.m_axi_bready(m_axi_bready),

		// S_AXIS

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tstrb(s_axis_tstrb),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tready(s_axis_tready)
	);
endmodule

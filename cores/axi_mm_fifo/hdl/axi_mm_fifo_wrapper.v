/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_mm_fifo_w
#(
	parameter C_WIDTH = 64,
	parameter C_BASE_ADDR = 0,
	parameter C_MEM_SIZE = 134217728,
	parameter C_END_ADDR = C_BASE_ADDR + C_MEM_SIZE - 1,
	parameter C_MAX_OCCUPANCY = (C_MEM_SIZE / (C_WIDTH * C_WIDTH / 8)) * (C_WIDTH - 2)
)
(
	input wire clk_axis,
	input wire rst_axis_n,

	input wire clk_axi,
	input wire rst_axi_n,

	input wire flush,
	output wire [$clog2(C_MAX_OCCUPANCY+1)-1:0] occupancy,

	// M_AXI

	output wire [$clog2(C_END_ADDR+1)-1:0] m_axi_araddr,
	output wire [1:0] m_axi_arburst,
	output wire [7:0] m_axi_arlen,
	output wire [2:0] m_axi_arsize,
	output wire m_axi_arvalid,
	input wire m_axi_arready,

	input wire [C_WIDTH-1:0] m_axi_rdata,
	input wire [1:0] m_axi_rresp,
	input wire m_axi_rlast,
	input wire m_axi_rvalid,
	output wire m_axi_rready,

	output wire [$clog2(C_END_ADDR+1)-1:0] m_axi_awaddr,
	output wire [1:0] m_axi_awburst,
	output wire [7:0] m_axi_awlen,
	output wire [2:0] m_axi_awsize,
	output wire m_axi_awvalid,
	input wire m_axi_awready,

	output wire [C_WIDTH-1:0] m_axi_wdata,
	output wire [C_WIDTH/8-1:0] m_axi_wstrb,
	output wire m_axi_wlast,
	output wire m_axi_wvalid,
	input wire m_axi_wready,

	input wire [1:0] m_axi_bresp,
	input wire m_axi_bvalid,
	output wire m_axi_bready,

	// M_AXIS

	output wire [C_WIDTH-1:0] m_axis_tdata,
	output wire m_axis_tlast,
	output wire m_axis_tvalid,
	input wire m_axis_tready,

	// S_AXIS

	input wire [C_WIDTH-1:0] s_axis_tdata,
	input wire s_axis_tlast,
	input wire s_axis_tvalid,
	output wire s_axis_tready
);
	assign m_axi_awsize = $clog2(C_WIDTH/8);
	assign m_axi_awburst = 2'd1;

	assign m_axi_arsize = $clog2(C_WIDTH/8);
	assign m_axi_arburst = 2'd1;

	assign m_axi_wstrb = {(C_WIDTH/8){1'b1}};

	axi_mm_fifo
	#(
		C_WIDTH,
		C_BASE_ADDR,
		C_END_ADDR,
		C_MAX_OCCUPANCY
	)
	U0
	(
		.clk_axis(clk_axis),
		.rst_axis_n(rst_axis_n),

		.clk_axi(clk_axi),
		.rst_axi_n(rst_axi_n),

		.flush(flush),
		.occupancy(occupancy),

		// M_AXI

		.m_axi_araddr(m_axi_araddr),
		.m_axi_arlen(m_axi_arlen),
		.m_axi_arvalid(m_axi_arvalid),
		.m_axi_arready(m_axi_arready),

		.m_axi_rdata(m_axi_rdata),
		.m_axi_rresp(m_axi_rresp),
		.m_axi_rlast(m_axi_rlast),
		.m_axi_rvalid(m_axi_rvalid),
		.m_axi_rready(m_axi_rready),

		.m_axi_awaddr(m_axi_awaddr),
		.m_axi_awlen(m_axi_awlen),
		.m_axi_awvalid(m_axi_awvalid),
		.m_axi_awready(m_axi_awready),

		.m_axi_wdata(m_axi_wdata),
		.m_axi_wlast(m_axi_wlast),
		.m_axi_wvalid(m_axi_wvalid),
		.m_axi_wready(m_axi_wready),

		.m_axi_bresp(m_axi_bresp),
		.m_axi_bvalid(m_axi_bvalid),
		.m_axi_bready(m_axi_bready),

		// M_AXIS

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready),

		// S_AXIS

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tready(s_axis_tready)
	);
endmodule

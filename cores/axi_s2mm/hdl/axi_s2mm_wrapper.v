/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_s2mm_w
#(
	parameter C_AXI_WIDTH = 64,
	parameter C_AXI_ADDR_WIDTH = 64,
	parameter C_AXI_MAX_BURST = 255,

	parameter C_FIFO_SIZE = 256,
	parameter C_FIFO_TYPE = "block",

	parameter C_VALUE_AWPROT = 3'd0,
	parameter C_VALUE_AWCACHE = 4'b1111,
	parameter C_VALUE_AWUSER = 4'b1111
)
(
	input wire clk,
	input wire rst_n,

	// S_AXIS_CTL

	input wire [C_AXI_ADDR_WIDTH+15:0] s_axis_ctl_tdata,
	input wire s_axis_ctl_tvalid,
	output wire s_axis_ctl_tready,

	// M_AXIS_ST

	output wire [7:0] m_axis_st_tdata,
	output wire m_axis_st_tvalid,
	input wire m_axis_st_tready,

	// M_AXI

	output wire [C_AXI_ADDR_WIDTH-1:0] m_axi_awaddr,
	output wire [2:0] m_axi_awprot,
	output wire [7:0] m_axi_awlen,
	output wire [1:0] m_axi_awburst,
	output wire [2:0] m_axi_awsize,
	output wire [3:0] m_axi_awuser,
	output wire [3:0] m_axi_awcache,
	output wire m_axi_awvalid,
	input wire m_axi_awready,

	output wire [C_AXI_WIDTH-1:0] m_axi_wdata,
	output wire [(C_AXI_WIDTH/8)-1:0] m_axi_wstrb,
	output wire m_axi_wlast,
	output wire m_axi_wvalid,
	input wire m_axi_wready,

	input wire [1:0] m_axi_bresp,
	input wire m_axi_bvalid,
	output wire m_axi_bready,

	// S_AXIS

	input wire [C_AXI_WIDTH-1:0] s_axis_tdata,
	input wire [(C_AXI_WIDTH/8)-1:0] s_axis_tstrb,
	input wire s_axis_tlast,
	input wire s_axis_tvalid,
	output wire s_axis_tready
);
	assign m_axi_awprot = C_VALUE_AWPROT;
	assign m_axi_awuser = C_VALUE_AWUSER;
	assign m_axi_awcache = C_VALUE_AWCACHE;
	assign m_axi_awburst = 2'd1;

	axi_s2mm
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

		// S_AXIS_CTL

		.s_axis_ctl_tdata(s_axis_ctl_tdata),
		.s_axis_ctl_tvalid(s_axis_ctl_tvalid),
		.s_axis_ctl_tready(s_axis_ctl_tready),

		// M_AXIS_ST

		.m_axis_st_tdata(m_axis_st_tdata),
		.m_axis_st_tvalid(m_axis_st_tvalid),
		.m_axis_st_tready(m_axis_st_tready),

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

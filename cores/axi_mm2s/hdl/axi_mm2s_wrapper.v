/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_mm2s_w
#(
	parameter C_AXI_WIDTH = 64,
	parameter C_AXI_ADDR_WIDTH = 64,
	parameter C_AXI_MAX_BURST = 255,

	parameter C_FIFO_SIZE = 256,
	parameter C_FIFO_TYPE = "block",

	parameter C_VALUE_ARPROT = 3'd0,
	parameter C_VALUE_ARCACHE = 4'b1111,
	parameter C_VALUE_ARUSER = 4'b1111
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

	output wire [C_AXI_ADDR_WIDTH-1:0] m_axi_araddr,
	output wire [7:0] m_axi_arlen,
	output wire [2:0] m_axi_arsize,
	output wire [1:0] m_axi_arburst,
	output wire [2:0] m_axi_arprot,
	output wire [3:0] m_axi_aruser,
	output wire [3:0] m_axi_arcache,
	output wire m_axi_arvalid,
	input wire m_axi_arready,

	input wire [C_AXI_WIDTH-1:0] m_axi_rdata,
	input wire [1:0] m_axi_rresp,
	input wire m_axi_rvalid,
	input wire m_axi_rlast,
	output wire m_axi_rready,

	// M_AXIS

	output wire [C_AXI_WIDTH-1:0] m_axis_tdata,
	output wire [(C_AXI_WIDTH/8)-1:0] m_axis_tstrb,
	output wire m_axis_tlast,
	output wire m_axis_tvalid,
	input wire m_axis_tready
);
	assign m_axi_arprot = C_VALUE_ARPROT;
	assign m_axi_aruser = C_VALUE_ARUSER;
	assign m_axi_arcache = C_VALUE_ARCACHE;
	assign m_axi_arburst = 2'd1;

	axi_mm2s
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
endmodule

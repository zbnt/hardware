/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_dma_w
#(
	parameter C_AXI_WIDTH = 64,
	parameter C_AXI_ADDR_WIDTH_H = 64,
	parameter C_AXI_ADDR_WIDTH_F = 32,
	parameter C_AXI_MAX_BURST = 255,

	parameter C_AXI_CFG_WIDTH = 64,
	parameter C_AXI_CFG_ADDR_WIDTH = 12,

	parameter C_IO_FIFO_TYPE = "block",
	parameter C_IO_FIFO_SIZE = 64,

	parameter C_SG_FIFO_TYPE = "distributed",
	parameter C_SG_FIFO_SIZE = 64,

	parameter C_AXI_AXPROT_F = 3'd0,
	parameter C_AXI_AXCACHE_F = 4'b1111,
	parameter C_AXI_AXUSER_F = 4'b1111,

	parameter C_AXI_AXPROT_H = 3'd0,
	parameter C_AXI_AXCACHE_H = 4'b1111,
	parameter C_AXI_AXUSER_H = 4'b1111
)
(
	input wire clk,
	input wire rst_n,

	output wire irq,

	// S_AXI_CFG

	input wire [C_AXI_CFG_ADDR_WIDTH-1:0] s_axi_cfg_awaddr,
	input wire s_axi_cfg_awvalid,
	output wire s_axi_cfg_awready,

	input wire [C_AXI_CFG_WIDTH-1:0] s_axi_cfg_wdata,
	input wire [(C_AXI_CFG_WIDTH/8)-1:0] s_axi_cfg_wstrb,
	input wire s_axi_cfg_wvalid,
	output wire s_axi_cfg_wready,

	output wire [1:0] s_axi_cfg_bresp,
	output wire s_axi_cfg_bvalid,
	input wire s_axi_cfg_bready,

	input wire [C_AXI_CFG_ADDR_WIDTH-1:0] s_axi_cfg_araddr,
	input wire s_axi_cfg_arvalid,
	output wire s_axi_cfg_arready,

	output wire [C_AXI_CFG_WIDTH-1:0] s_axi_cfg_rdata,
	output wire [1:0] s_axi_cfg_rresp,
	output wire s_axi_cfg_rvalid,
	input wire s_axi_cfg_rready,

	// M_AXI_FPGA

	output wire [C_AXI_ADDR_WIDTH_F-1:0] m_axi_fpga_awaddr,
	output wire [7:0] m_axi_fpga_awlen,
	output wire [2:0] m_axi_fpga_awsize,
	output wire [1:0] m_axi_fpga_awburst,
	output wire [2:0] m_axi_fpga_awprot,
	output wire [3:0] m_axi_fpga_awuser,
	output wire [3:0] m_axi_fpga_awcache,
	output wire m_axi_fpga_awvalid,
	input wire m_axi_fpga_awready,

	output wire [C_AXI_WIDTH-1:0] m_axi_fpga_wdata,
	output wire [(C_AXI_WIDTH/8)-1:0] m_axi_fpga_wstrb,
	output wire m_axi_fpga_wlast,
	output wire m_axi_fpga_wvalid,
	input wire m_axi_fpga_wready,

	input wire [1:0] m_axi_fpga_bresp,
	input wire m_axi_fpga_bvalid,
	output wire m_axi_fpga_bready,

	output wire [C_AXI_ADDR_WIDTH_F-1:0] m_axi_fpga_araddr,
	output wire [7:0] m_axi_fpga_arlen,
	output wire [2:0] m_axi_fpga_arsize,
	output wire [1:0] m_axi_fpga_arburst,
	output wire [2:0] m_axi_fpga_arprot,
	output wire [3:0] m_axi_fpga_aruser,
	output wire [3:0] m_axi_fpga_arcache,
	output wire m_axi_fpga_arvalid,
	input wire m_axi_fpga_arready,

	input wire [C_AXI_WIDTH-1:0] m_axi_fpga_rdata,
	input wire [1:0] m_axi_fpga_rresp,
	input wire m_axi_fpga_rvalid,
	input wire m_axi_fpga_rlast,
	output wire m_axi_fpga_rready,

	// M_AXI_HOST

	output wire [C_AXI_ADDR_WIDTH_H-1:0] m_axi_host_awaddr,
	output wire [7:0] m_axi_host_awlen,
	output wire [2:0] m_axi_host_awsize,
	output wire [1:0] m_axi_host_awburst,
	output wire [2:0] m_axi_host_awprot,
	output wire [3:0] m_axi_host_awuser,
	output wire [3:0] m_axi_host_awcache,
	output wire m_axi_host_awvalid,
	input wire m_axi_host_awready,

	output wire [C_AXI_WIDTH-1:0] m_axi_host_wdata,
	output wire [(C_AXI_WIDTH/8)-1:0] m_axi_host_wstrb,
	output wire m_axi_host_wlast,
	output wire m_axi_host_wvalid,
	input wire m_axi_host_wready,

	input wire [1:0] m_axi_host_bresp,
	input wire m_axi_host_bvalid,
	output wire m_axi_host_bready,

	output wire [C_AXI_ADDR_WIDTH_H-1:0] m_axi_host_araddr,
	output wire [7:0] m_axi_host_arlen,
	output wire [2:0] m_axi_host_arsize,
	output wire [1:0] m_axi_host_arburst,
	output wire [2:0] m_axi_host_arprot,
	output wire [3:0] m_axi_host_aruser,
	output wire [3:0] m_axi_host_arcache,
	output wire m_axi_host_arvalid,
	input wire m_axi_host_arready,

	input wire [C_AXI_WIDTH-1:0] m_axi_host_rdata,
	input wire [1:0] m_axi_host_rresp,
	input wire m_axi_host_rvalid,
	input wire m_axi_host_rlast,
	output wire m_axi_host_rready
);
	assign m_axi_host_awprot = C_AXI_AXPROT_H;
	assign m_axi_host_awuser = C_AXI_AXUSER_H;
	assign m_axi_host_awcache = C_AXI_AXCACHE_H;
	assign m_axi_host_awburst = 2'd1;

	assign m_axi_host_arprot = C_AXI_AXPROT_H;
	assign m_axi_host_aruser = C_AXI_AXUSER_H;
	assign m_axi_host_arcache = C_AXI_AXCACHE_H;
	assign m_axi_host_arburst = 2'd1;

	assign m_axi_fpga_awprot = C_AXI_AXPROT_F;
	assign m_axi_fpga_awuser = C_AXI_AXUSER_F;
	assign m_axi_fpga_awcache = C_AXI_AXCACHE_F;
	assign m_axi_fpga_awburst = 2'd1;

	assign m_axi_fpga_arprot = C_AXI_AXPROT_F;
	assign m_axi_fpga_aruser = C_AXI_AXUSER_F;
	assign m_axi_fpga_arcache = C_AXI_AXCACHE_F;
	assign m_axi_fpga_arburst = 2'd1;

	axi_dma
	#(
		.C_AXI_WIDTH(C_AXI_WIDTH),
		.C_AXI_ADDR_WIDTH_H(C_AXI_ADDR_WIDTH_H),
		.C_AXI_ADDR_WIDTH_F(C_AXI_ADDR_WIDTH_F),
		.C_AXI_MAX_BURST(C_AXI_MAX_BURST),

		.C_AXI_CFG_WIDTH(C_AXI_CFG_WIDTH),
		.C_AXI_CFG_ADDR_WIDTH(C_AXI_CFG_ADDR_WIDTH),

		.C_IO_FIFO_TYPE(C_IO_FIFO_TYPE),
		.C_IO_FIFO_SIZE(C_IO_FIFO_SIZE),

		.C_SG_FIFO_TYPE(C_SG_FIFO_TYPE),
		.C_SG_FIFO_SIZE(C_SG_FIFO_SIZE)
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.irq(irq),

		// S_AXI_CFG

		.s_axi_cfg_awaddr(s_axi_cfg_awaddr),
		.s_axi_cfg_awvalid(s_axi_cfg_awvalid),
		.s_axi_cfg_awready(s_axi_cfg_awready),

		.s_axi_cfg_wdata(s_axi_cfg_wdata),
		.s_axi_cfg_wstrb(s_axi_cfg_wstrb),
		.s_axi_cfg_wvalid(s_axi_cfg_wvalid),
		.s_axi_cfg_wready(s_axi_cfg_wready),

		.s_axi_cfg_bresp(s_axi_cfg_bresp),
		.s_axi_cfg_bvalid(s_axi_cfg_bvalid),
		.s_axi_cfg_bready(s_axi_cfg_bready),

		.s_axi_cfg_araddr(s_axi_cfg_araddr),
		.s_axi_cfg_arvalid(s_axi_cfg_arvalid),
		.s_axi_cfg_arready(s_axi_cfg_arready),

		.s_axi_cfg_rdata(s_axi_cfg_rdata),
		.s_axi_cfg_rresp(s_axi_cfg_rresp),
		.s_axi_cfg_rvalid(s_axi_cfg_rvalid),
		.s_axi_cfg_rready(s_axi_cfg_rready),

		// M_AXI_FPGA

		.m_axi_fpga_awaddr(m_axi_fpga_awaddr),
		.m_axi_fpga_awlen(m_axi_fpga_awlen),
		.m_axi_fpga_awsize(m_axi_fpga_awsize),
		.m_axi_fpga_awvalid(m_axi_fpga_awvalid),
		.m_axi_fpga_awready(m_axi_fpga_awready),

		.m_axi_fpga_wdata(m_axi_fpga_wdata),
		.m_axi_fpga_wstrb(m_axi_fpga_wstrb),
		.m_axi_fpga_wlast(m_axi_fpga_wlast),
		.m_axi_fpga_wvalid(m_axi_fpga_wvalid),
		.m_axi_fpga_wready(m_axi_fpga_wready),

		.m_axi_fpga_bresp(m_axi_fpga_bresp),
		.m_axi_fpga_bvalid(m_axi_fpga_bvalid),
		.m_axi_fpga_bready(m_axi_fpga_bready),

		.m_axi_fpga_araddr(m_axi_fpga_araddr),
		.m_axi_fpga_arlen(m_axi_fpga_arlen),
		.m_axi_fpga_arsize(m_axi_fpga_arsize),
		.m_axi_fpga_arvalid(m_axi_fpga_arvalid),
		.m_axi_fpga_arready(m_axi_fpga_arready),

		.m_axi_fpga_rdata(m_axi_fpga_rdata),
		.m_axi_fpga_rresp(m_axi_fpga_rresp),
		.m_axi_fpga_rvalid(m_axi_fpga_rvalid),
		.m_axi_fpga_rlast(m_axi_fpga_rlast),
		.m_axi_fpga_rready(m_axi_fpga_rready),

		// M_AXI_HOST

		.m_axi_host_awaddr(m_axi_host_awaddr),
		.m_axi_host_awlen(m_axi_host_awlen),
		.m_axi_host_awsize(m_axi_host_awsize),
		.m_axi_host_awvalid(m_axi_host_awvalid),
		.m_axi_host_awready(m_axi_host_awready),

		.m_axi_host_wdata(m_axi_host_wdata),
		.m_axi_host_wstrb(m_axi_host_wstrb),
		.m_axi_host_wlast(m_axi_host_wlast),
		.m_axi_host_wvalid(m_axi_host_wvalid),
		.m_axi_host_wready(m_axi_host_wready),

		.m_axi_host_bresp(m_axi_host_bresp),
		.m_axi_host_bvalid(m_axi_host_bvalid),
		.m_axi_host_bready(m_axi_host_bready),

		.m_axi_host_araddr(m_axi_host_araddr),
		.m_axi_host_arlen(m_axi_host_arlen),
		.m_axi_host_arsize(m_axi_host_arsize),
		.m_axi_host_arvalid(m_axi_host_arvalid),
		.m_axi_host_arready(m_axi_host_arready),

		.m_axi_host_rdata(m_axi_host_rdata),
		.m_axi_host_rresp(m_axi_host_rresp),
		.m_axi_host_rvalid(m_axi_host_rvalid),
		.m_axi_host_rlast(m_axi_host_rlast),
		.m_axi_host_rready(m_axi_host_rready)
	);
endmodule

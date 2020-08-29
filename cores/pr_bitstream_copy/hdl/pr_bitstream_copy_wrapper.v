/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module pr_bitstream_copy_w
#(
	parameter C_AXI_WIDTH = 32,
	parameter C_AXI_ADDR_WIDTH = 32,

	parameter C_SOURCE_ADDR = 32'h01000000,
	parameter C_DESTINATION_ADDR = 32'h00000000,
	parameter C_MEMORY_SIZE = 0
)
(
	input wire clk,
	input wire rst_n,

	output wire ready,
	output wire error,

	// M_AXI_SRC

	output wire [C_AXI_ADDR_WIDTH-1:0] m_axi_src_araddr,
	output wire [7:0] m_axi_src_arlen,
	output wire [2:0] m_axi_src_arsize,
	output wire [1:0] m_axi_src_arburst,
	output wire m_axi_src_arvalid,
	input wire m_axi_src_arready,

	input wire [C_AXI_WIDTH-1:0] m_axi_src_rdata,
	input wire [1:0] m_axi_src_rresp,
	input wire m_axi_src_rvalid,
	input wire m_axi_src_rlast,
	output wire m_axi_src_rready,

	// M_AXI_DST

	output wire [C_AXI_ADDR_WIDTH-1:0] m_axi_dst_awaddr,
	output wire [7:0] m_axi_dst_awlen,
	output wire [2:0] m_axi_dst_awsize,
	output wire [1:0] m_axi_dst_awburst,
	output wire m_axi_dst_awvalid,
	input wire m_axi_dst_awready,

	output wire [C_AXI_WIDTH-1:0] m_axi_dst_wdata,
	output wire [(C_AXI_WIDTH/8)-1:0] m_axi_dst_wstrb,
	output wire m_axi_dst_wlast,
	output wire m_axi_dst_wvalid,
	input wire m_axi_dst_wready,

	input wire [1:0] m_axi_dst_bresp,
	input wire m_axi_dst_bvalid,
	output wire m_axi_dst_bready,

	// M_AXI_PRC

	output wire [C_AXI_ADDR_WIDTH-1:0] m_axi_prc_araddr,
	output wire [7:0] m_axi_prc_arlen,
	output wire [2:0] m_axi_prc_arsize,
	output wire [1:0] m_axi_prc_arburst,
	output wire m_axi_prc_arvalid,
	input wire m_axi_prc_arready,

	input wire [C_AXI_WIDTH-1:0] m_axi_prc_rdata,
	input wire [1:0] m_axi_prc_rresp,
	input wire m_axi_prc_rvalid,
	input wire m_axi_prc_rlast,
	output wire m_axi_prc_rready,

	// S_AXI_PRC

	input wire [C_AXI_ADDR_WIDTH-1:0] s_axi_prc_araddr,
	input wire [7:0] s_axi_prc_arlen,
	input wire [2:0] s_axi_prc_arsize,
	input wire [1:0] s_axi_prc_arburst,
	input wire s_axi_prc_arvalid,
	output wire s_axi_prc_arready,

	output wire [C_AXI_WIDTH-1:0] s_axi_prc_rdata,
	output wire [1:0] s_axi_prc_rresp,
	output wire s_axi_prc_rvalid,
	output wire s_axi_prc_rlast,
	input wire s_axi_prc_rready
);
	assign m_axi_prc_araddr = s_axi_prc_araddr;
	assign m_axi_prc_arlen = s_axi_prc_arlen;
	assign m_axi_prc_arsize = s_axi_prc_arsize;
	assign m_axi_prc_arburst = s_axi_prc_arburst;
	assign m_axi_prc_arvalid = s_axi_prc_arvalid & ready;
	assign m_axi_prc_rready = s_axi_prc_rready & ready;

	assign s_axi_prc_arready = m_axi_prc_arready & ready;
	assign s_axi_prc_rdata = m_axi_prc_rdata;
	assign s_axi_prc_rresp = m_axi_prc_rresp;
	assign s_axi_prc_rvalid = m_axi_prc_rvalid & ready;
	assign s_axi_prc_rlast = m_axi_prc_rlast;

	assign m_axi_src_arburst = 2'd1;
	assign m_axi_dst_awburst = 2'd1;

	wire [C_AXI_ADDR_WIDTH-1:0] bytes_total;

	pr_bitstream_copy
	#(
		.C_AXI_WIDTH(C_AXI_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),

		.C_SOURCE_ADDR(C_SOURCE_ADDR),
		.C_DESTINATION_ADDR(C_DESTINATION_ADDR)
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.bytes_total(bytes_total),

		.ready(ready),
		.error(error),

		// M_AXI_SRC

		.m_axi_src_araddr(m_axi_src_araddr),
		.m_axi_src_arlen(m_axi_src_arlen),
		.m_axi_src_arsize(m_axi_src_arsize),
		.m_axi_src_arvalid(m_axi_src_arvalid),
		.m_axi_src_arready(m_axi_src_arready),

		.m_axi_src_rdata(m_axi_src_rdata),
		.m_axi_src_rresp(m_axi_src_rresp),
		.m_axi_src_rvalid(m_axi_src_rvalid),
		.m_axi_src_rlast(m_axi_src_rlast),
		.m_axi_src_rready(m_axi_src_rready),

		// M_AXI_DST

		.m_axi_dst_awaddr(m_axi_dst_awaddr),
		.m_axi_dst_awlen(m_axi_dst_awlen),
		.m_axi_dst_awsize(m_axi_dst_awsize),
		.m_axi_dst_awvalid(m_axi_dst_awvalid),
		.m_axi_dst_awready(m_axi_dst_awready),

		.m_axi_dst_wdata(m_axi_dst_wdata),
		.m_axi_dst_wstrb(m_axi_dst_wstrb),
		.m_axi_dst_wlast(m_axi_dst_wlast),
		.m_axi_dst_wvalid(m_axi_dst_wvalid),
		.m_axi_dst_wready(m_axi_dst_wready),

		.m_axi_dst_bresp(m_axi_dst_bresp),
		.m_axi_dst_bvalid(m_axi_dst_bvalid),
		.m_axi_dst_bready(m_axi_dst_bready)
	);

	pr_bitstream_copy_rom
	#(
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.C_MEMORY_SIZE(C_MEMORY_SIZE)
	)
	U1
	(
		.bytes_total(bytes_total)
	);
endmodule

/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module circular_dma_w #(parameter C_AXI_WIDTH = 32, parameter C_ADDR_WIDTH = 32, parameter C_AXIS_WIDTH = 64, parameter C_MAX_BURST = 16)
(
	input wire clk,
	input wire rst_n,
	input wire [31:0] fifo_occupancy,

	output wire irq,
	output wire dm_rst_n,

	// S_AXI

	input wire [11:0] s_axi_awaddr,
	input wire [2:0] s_axi_awprot,
	input wire s_axi_awvalid,
	output wire s_axi_awready,

	input wire [C_AXI_WIDTH-1:0] s_axi_wdata,
	input wire [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input wire s_axi_wvalid,
	output wire s_axi_wready,

	output wire [1:0] s_axi_bresp,
	output wire s_axi_bvalid,
	input wire s_axi_bready,

	input wire [11:0] s_axi_araddr,
	input wire [2:0] s_axi_arprot,
	input wire s_axi_arvalid,
	output wire s_axi_arready,

	output wire [C_AXI_WIDTH-1:0] s_axi_rdata,
	output wire [1:0] s_axi_rresp,
	output wire s_axi_rvalid,
	input wire s_axi_rready,

	// S_AXIS_S2MM

	input wire [C_AXIS_WIDTH-1:0] s_axis_s2mm_tdata,
	input wire s_axis_s2mm_tlast,
	input wire s_axis_s2mm_tvalid,
	output wire s_axis_s2mm_tready,

	// S_AXIS_S2MM_STS

	input wire [7:0] s_axis_s2mm_sts_tdata,
	input wire [0:0] s_axis_s2mm_sts_tkeep,
	input wire s_axis_s2mm_sts_tlast,
	input wire s_axis_s2mm_sts_tvalid,
	output wire s_axis_s2mm_sts_tready,

	// M_AXIS_S2MM

	output wire [C_AXIS_WIDTH-1:0] m_axis_s2mm_tdata,
	output wire m_axis_s2mm_tlast,
	output wire m_axis_s2mm_tvalid,
	input wire m_axis_s2mm_tready,

	// M_AXIS_S2MM_CMD

	output wire [C_ADDR_WIDTH+39:0] m_axis_s2mm_cmd_tdata,
	output wire m_axis_s2mm_cmd_tvalid,
	input wire m_axis_s2mm_cmd_tready
);
	circular_dma #(C_AXI_WIDTH, C_ADDR_WIDTH, C_AXIS_WIDTH, C_MAX_BURST) U0
	(
		.clk(clk),
		.rst_n(rst_n),
		.fifo_occupancy(fifo_occupancy),

		.irq(irq),
		.dm_rst_n(dm_rst_n),

		// S_AXI

		.s_axi_awaddr(s_axi_awaddr),
		.s_axi_awprot(s_axi_awprot),
		.s_axi_awvalid(s_axi_awvalid),
		.s_axi_awready(s_axi_awready),

		.s_axi_wdata(s_axi_wdata),
		.s_axi_wstrb(s_axi_wstrb),
		.s_axi_wvalid(s_axi_wvalid),
		.s_axi_wready(s_axi_wready),

		.s_axi_bresp(s_axi_bresp),
		.s_axi_bvalid(s_axi_bvalid),
		.s_axi_bready(s_axi_bready),

		.s_axi_araddr(s_axi_araddr),
		.s_axi_arprot(s_axi_arprot),
		.s_axi_arvalid(s_axi_arvalid),
		.s_axi_arready(s_axi_arready),

		.s_axi_rdata(s_axi_rdata),
		.s_axi_rresp(s_axi_rresp),
		.s_axi_rvalid(s_axi_rvalid),
		.s_axi_rready(s_axi_rready),

		// S_AXIS_S2MM

		.s_axis_s2mm_tdata(s_axis_s2mm_tdata),
		.s_axis_s2mm_tlast(s_axis_s2mm_tlast),
		.s_axis_s2mm_tvalid(s_axis_s2mm_tvalid),
		.s_axis_s2mm_tready(s_axis_s2mm_tready),

		// S_AXIS_S2MM_STS

		.s_axis_s2mm_sts_tdata(s_axis_s2mm_sts_tdata),
		.s_axis_s2mm_sts_tkeep(s_axis_s2mm_sts_tkeep),
		.s_axis_s2mm_sts_tlast(s_axis_s2mm_sts_tlast),
		.s_axis_s2mm_sts_tvalid(s_axis_s2mm_sts_tvalid),
		.s_axis_s2mm_sts_tready(s_axis_s2mm_sts_tready),

		// M_AXIS_S2MM

		.m_axis_s2mm_tdata(m_axis_s2mm_tdata),
		.m_axis_s2mm_tlast(m_axis_s2mm_tlast),
		.m_axis_s2mm_tvalid(m_axis_s2mm_tvalid),
		.m_axis_s2mm_tready(m_axis_s2mm_tready),

		// M_AXIS_S2MM_CMD

		.m_axis_s2mm_cmd_tdata(m_axis_s2mm_cmd_tdata),
		.m_axis_s2mm_cmd_tvalid(m_axis_s2mm_cmd_tvalid),
		.m_axis_s2mm_cmd_tready(m_axis_s2mm_cmd_tready)
	);
endmodule

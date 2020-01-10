/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	circular_dma: Circular DMA

	Circular DMA core, for use with AXI DataMover.
*/

module circular_dma #(parameter C_AXI_WIDTH = 32, parameter C_ADDR_WIDTH = 32, parameter C_AXIS_WIDTH = 64, parameter C_MAX_BURST = 16)
(
	input logic clk,
	input logic rst_n,

	output logic irq,
	output logic dm_rst_n,

	// S_AXI : AXI4-Lite slave interface (from PS)

	input logic [11:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [C_AXI_WIDTH-1:0] s_axi_wdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [11:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// S_AXIS_S2MM

	input logic [C_AXIS_WIDTH-1:0] s_axis_s2mm_tdata,
	input logic s_axis_s2mm_tlast,
	input logic s_axis_s2mm_tvalid,
	output logic s_axis_s2mm_tready,

	// S_AXIS_S2MM_STS

	input logic [7:0] s_axis_s2mm_sts_tdata,
	input logic [0:0] s_axis_s2mm_sts_tkeep,
	input logic s_axis_s2mm_sts_tlast,
	input logic s_axis_s2mm_sts_tvalid,
	output logic s_axis_s2mm_sts_tready,

	// M_AXIS_S2MM

	output logic [C_AXIS_WIDTH-1:0] m_axis_s2mm_tdata,
	output logic m_axis_s2mm_tlast,
	output logic m_axis_s2mm_tvalid,
	input logic m_axis_s2mm_tready,

	// M_AXIS_S2MM_CMD

	output logic [C_ADDR_WIDTH+47:0] m_axis_s2mm_cmd_tdata,
	output logic m_axis_s2mm_cmd_tvalid,
	input logic m_axis_s2mm_cmd_tready
);
	// axi4_lite registers

	logic enable, srst;
	logic [1:0] bits_irq, clear_irq, enable_irq;
	logic [C_ADDR_WIDTH-1:0] mem_base;
	logic [31:0] mem_size, bytes_written, last_msg_end, timeout;
	logic [3:0] status_flags;

	circular_dma_axi #(C_AXI_WIDTH, C_ADDR_WIDTH, C_AXIS_WIDTH) U0
	(
		.clk(clk),
		.rst_n(rst_n),

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

		.enable(enable),
		.srst(srst),
		.status_flags(status_flags),

		.irq(bits_irq),
		.clear_irq(clear_irq),
		.enable_irq(enable_irq),

		.mem_base(mem_base),
		.mem_size(mem_size),
		.bytes_written(bytes_written),
		.last_msg_end(last_msg_end),
		.timeout(timeout)
	);

	circular_dma_fsm #(C_ADDR_WIDTH, C_AXIS_WIDTH, C_MAX_BURST) U1
	(
		.clk(clk),
		.rst_n(dm_rst_n),

		.enable(enable),
		.clear_irq(clear_irq),
		.enable_irq(enable_irq),

		.irq(bits_irq),
		.status_flags(status_flags),

		.mem_base(mem_base),
		.mem_size(mem_size),
		.bytes_written(bytes_written),
		.last_msg_end(last_msg_end),
		.timeout(timeout),

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

	always_comb begin
		dm_rst_n = rst_n & ~srst;
		irq = |bits_irq;
	end
endmodule

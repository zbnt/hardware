/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	circular_dma: Circular DMA

	Circular DMA core, takes an AXI4-Stream input and converts it into AXI4-MM write operations.
*/

module circular_dma
#(
	parameter C_AXI_WIDTH = 32,
	parameter C_ADDR_WIDTH = 32,
	parameter C_AXIS_WIDTH = 64,
	parameter C_MAX_BURST = 16,

	parameter C_FIFO_TYPE_0 = "block",
	parameter C_FIFO_TYPE_1 = "none",
	parameter C_FIFO_TYPE_2 = "none",
	parameter C_FIFO_TYPE_3 = "none",

	parameter C_FIFO_DEPTH_0 = 256,
	parameter C_FIFO_DEPTH_1 = 256,
	parameter C_FIFO_DEPTH_2 = 256,
	parameter C_FIFO_DEPTH_3 = 256
)
(
	input logic clk,
	input logic rst_n,

	output logic irq,

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

	// M_AXI

	output logic [C_ADDR_WIDTH-1:0] m_axi_awaddr,
	output logic [7:0] m_axi_awlen,
	output logic m_axi_awvalid,
	input logic m_axi_awready,

	output logic [C_AXIS_WIDTH-1:0] m_axi_wdata,
	output logic m_axi_wlast,
	output logic m_axi_wvalid,
	input logic m_axi_wready,

	input logic [1:0] m_axi_bresp,
	input logic m_axi_bvalid,
	output logic m_axi_bready,

	// S_AXIS

	input logic [C_AXIS_WIDTH-1:0] s_axis_tdata,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready
);
	// Registers

	logic enable, srst, flush_req, flush_ack, fifo_ready;
	logic [2:0] bits_irq, clear_irq, enable_irq;
	logic [C_ADDR_WIDTH-1:0] mem_base;
	logic [31:0] mem_size, bytes_written, last_msg_end;
	logic [2:0] status_flags;

	circular_dma_axi #(C_AXI_WIDTH, C_ADDR_WIDTH, C_AXIS_WIDTH, C_MAX_BURST) U0
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

		.fifo_ready(fifo_ready),
		.fifo_flush_req(flush_req),
		.fifo_flush_ack(flush_ack),

		.irq(bits_irq),
		.clear_irq(clear_irq),
		.enable_irq(enable_irq),

		.mem_base(mem_base),
		.mem_size(mem_size),
		.bytes_written(bytes_written),
		.last_msg_end(last_msg_end)
	);

	// IRQ

	always_ff @(posedge clk) begin
		irq <= rst_n & (|bits_irq) & ~(|clear_irq);
	end

	// FSM

	logic [C_AXIS_WIDTH-1:0] axis_fifo_tdata;
	logic axis_fifo_tlast, axis_fifo_tvalid, axis_fifo_tready;

	logic flush_active;
	logic [$clog2(C_MAX_BURST+1)-1:0] fifo_occupancy;

	circular_dma_fsm #(C_ADDR_WIDTH, C_AXIS_WIDTH, C_MAX_BURST) U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.flush_req(flush_active),
		.flush_ack(flush_ack),
		.fifo_occupancy(fifo_occupancy),

		.enable(fifo_ready),
		.clear_irq(clear_irq),
		.enable_irq(enable_irq),
		.irq(bits_irq),
		.status_flags(status_flags),

		.mem_base(mem_base),
		.mem_size(mem_size),
		.bytes_written(bytes_written),
		.last_msg_end(last_msg_end),

		// M_AXI

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

		// S_AXIS

		.s_axis_tdata(axis_fifo_tdata),
		.s_axis_tlast(axis_fifo_tlast),
		.s_axis_tvalid(axis_fifo_tvalid),
		.s_axis_tready(axis_fifo_tready)
	);

	// FIFOs

	circular_dma_fifos
	#(
		.C_AXIS_WIDTH(C_AXIS_WIDTH),
		.C_MAX_BURST(C_MAX_BURST),

		.C_FIFO_TYPE_0(C_FIFO_TYPE_0),
		.C_FIFO_TYPE_1(C_FIFO_TYPE_1),
		.C_FIFO_TYPE_2(C_FIFO_TYPE_2),
		.C_FIFO_TYPE_3(C_FIFO_TYPE_3),

		.C_FIFO_DEPTH_0(C_FIFO_DEPTH_0),
		.C_FIFO_DEPTH_1(C_FIFO_DEPTH_1),
		.C_FIFO_DEPTH_2(C_FIFO_DEPTH_2),
		.C_FIFO_DEPTH_3(C_FIFO_DEPTH_3)
	)
	U2
	(
		.clk(clk),
		.rst_n(rst_n),

		.enable(enable),
		.flush_req(flush_req),

		.ready(fifo_ready),
		.flush_active(flush_active),
		.flush_ack(flush_ack),

		.occupancy(fifo_occupancy),

		// S_AXIS

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tready(s_axis_tready),

		// M_AXIS

		.m_axis_tdata(axis_fifo_tdata),
		.m_axis_tlast(axis_fifo_tlast),
		.m_axis_tvalid(axis_fifo_tvalid),
		.m_axis_tready(axis_fifo_tready)
	);
endmodule

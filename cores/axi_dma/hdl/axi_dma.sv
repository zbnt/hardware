/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_dma
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
	parameter C_SG_FIFO_SIZE = 64
)
(
	input logic clk,
	input logic rst_n,

	output logic irq,

	// S_AXI_CFG

	input logic [C_AXI_CFG_ADDR_WIDTH-1:0] s_axi_cfg_awaddr,
	input logic s_axi_cfg_awvalid,
	output logic s_axi_cfg_awready,

	input logic [C_AXI_CFG_WIDTH-1:0] s_axi_cfg_wdata,
	input logic [(C_AXI_CFG_WIDTH/8)-1:0] s_axi_cfg_wstrb,
	input logic s_axi_cfg_wvalid,
	output logic s_axi_cfg_wready,

	output logic [1:0] s_axi_cfg_bresp,
	output logic s_axi_cfg_bvalid,
	input logic s_axi_cfg_bready,

	input logic [C_AXI_CFG_ADDR_WIDTH-1:0] s_axi_cfg_araddr,
	input logic s_axi_cfg_arvalid,
	output logic s_axi_cfg_arready,

	output logic [C_AXI_CFG_WIDTH-1:0] s_axi_cfg_rdata,
	output logic [1:0] s_axi_cfg_rresp,
	output logic s_axi_cfg_rvalid,
	input logic s_axi_cfg_rready,

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
	logic irq_io, irq_en, irq_clr;

	logic busy;
	logic [3:0] response;

	logic dma_trigger, dma_direction;
	logic [C_AXI_ADDR_WIDTH_F-1:0] dma_fpga_addr;

	logic [$clog2(C_SG_FIFO_SIZE + 1)-1:0] sg_occupancy;

	logic [C_AXI_ADDR_WIDTH_H+15:0] m_axis_sg_tdata, s_axis_sg_tdata;
	logic m_axis_sg_tvalid, s_axis_sg_tvalid;
	logic m_axis_sg_tready, s_axis_sg_tready;

	// AXI-Lite configuration interface

	axi_dma_cfg
	#(
		.C_AXI_WIDTH(C_AXI_CFG_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_CFG_ADDR_WIDTH),

		.C_FPGA_ADDR_WIDTH(C_AXI_ADDR_WIDTH_F),
		.C_HOST_ADDR_WIDTH(C_AXI_ADDR_WIDTH_H),

		.C_SG_FIFO_SIZE(C_SG_FIFO_SIZE)
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n),

		// S_AXI

		.s_axi_awaddr(s_axi_cfg_awaddr),
		.s_axi_awvalid(s_axi_cfg_awvalid),
		.s_axi_awready(s_axi_cfg_awready),

		.s_axi_wdata(s_axi_cfg_wdata),
		.s_axi_wstrb(s_axi_cfg_wstrb),
		.s_axi_wvalid(s_axi_cfg_wvalid),
		.s_axi_wready(s_axi_cfg_wready),

		.s_axi_bresp(s_axi_cfg_bresp),
		.s_axi_bvalid(s_axi_cfg_bvalid),
		.s_axi_bready(s_axi_cfg_bready),

		.s_axi_araddr(s_axi_cfg_araddr),
		.s_axi_arvalid(s_axi_cfg_arvalid),
		.s_axi_arready(s_axi_cfg_arready),

		.s_axi_rdata(s_axi_cfg_rdata),
		.s_axi_rresp(s_axi_cfg_rresp),
		.s_axi_rvalid(s_axi_cfg_rvalid),
		.s_axi_rready(s_axi_cfg_rready),

		// Registers

		.busy(busy),
		.response(response),

		.irq(irq),
		.irq_en(irq_en),
		.irq_clr(irq_clr),

		.dma_trigger(dma_trigger),
		.dma_direction(dma_direction),
		.dma_fpga_addr(dma_fpga_addr),

		.sg_occupancy(sg_occupancy),

		.m_axis_sg_tdata(s_axis_sg_tdata),
		.m_axis_sg_tvalid(s_axis_sg_tvalid),
		.m_axis_sg_tready(s_axis_sg_tready)
	);

	// IO FSM

	axi_dma_fsm
	#(
		.C_AXI_WIDTH(C_AXI_WIDTH),
		.C_AXI_ADDR_WIDTH_H(C_AXI_ADDR_WIDTH_H),
		.C_AXI_ADDR_WIDTH_F(C_AXI_ADDR_WIDTH_F),
		.C_AXI_MAX_BURST(C_AXI_MAX_BURST),
		.C_FIFO_SIZE(C_IO_FIFO_SIZE),
		.C_FIFO_TYPE(C_IO_FIFO_TYPE),
		.C_MAX_SG_ENTRIES(C_SG_FIFO_SIZE)
	)
	U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.irq(irq),
		.irq_en(irq_en),
		.irq_clr(irq_clr),

		.trigger(dma_trigger),
		.direction(dma_direction),
		.fpga_addr(dma_fpga_addr),

		.busy(busy),
		.response(response),

		.sg_occupancy(sg_occupancy),

		// S_AXIS_SG

		.s_axis_sg_tdata(m_axis_sg_tdata),
		.s_axis_sg_tvalid(m_axis_sg_tvalid),
		.s_axis_sg_tready(m_axis_sg_tready),

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

	// FIFO for the scatterlist

	xpm_fifo_axis
	#(
		.CDC_SYNC_STAGES(2),
		.CLOCKING_MODE("common_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(C_SG_FIFO_SIZE),
		.FIFO_MEMORY_TYPE(C_SG_FIFO_TYPE),
		.PACKET_FIFO("false"),
		.PROG_EMPTY_THRESH(10),
		.PROG_FULL_THRESH(10),
		.RD_DATA_COUNT_WIDTH($clog2(C_SG_FIFO_SIZE + 1)),
		.RELATED_CLOCKS(0),
		.TDATA_WIDTH(C_AXI_ADDR_WIDTH_H + 16),
		.TDEST_WIDTH(1),
		.TID_WIDTH(1),
		.TUSER_WIDTH(1),
		.USE_ADV_FEATURES("1400"),
		.WR_DATA_COUNT_WIDTH(1)
	)
	U2
	(
		.m_aclk(clk),
		.s_aclk(clk),
		.s_aresetn(rst_n),

		.prog_full_axis(),
		.prog_empty_axis(),

		.rd_data_count_axis(sg_occupancy),

		.s_axis_tdata(s_axis_sg_tdata),
		.s_axis_tvalid(s_axis_sg_tvalid),
		.s_axis_tready(s_axis_sg_tready),

		.m_axis_tdata(m_axis_sg_tdata),
		.m_axis_tvalid(m_axis_sg_tvalid),
		.m_axis_tready(m_axis_sg_tready),

		.s_axis_tstrb('0),
		.s_axis_tlast(1'b0),
		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tuser(1'b0),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);
endmodule


module rp_wrapper
(
	input wire clk,
	input wire rst_prc_n,
	input wire rst_pcie_n,

	input wire shutdown_req,
	output wire shutdown_ack,
	output wire active,

	// ETH0

	input wire clk_rx0,

	output wire [7:0] m_axis_eth0_tdata,
	output wire m_axis_eth0_tuser,
	output wire m_axis_eth0_tlast,
	output wire m_axis_eth0_tvalid,
	input wire m_axis_eth0_tready,

	input wire [7:0] s_axis_eth0_tdata,
	input wire s_axis_eth0_tuser,
	input wire s_axis_eth0_tlast,
	input wire s_axis_eth0_tvalid,

	// ETH1

	input wire clk_rx1,

	output wire [7:0] m_axis_eth1_tdata,
	output wire m_axis_eth1_tuser,
	output wire m_axis_eth1_tlast,
	output wire m_axis_eth1_tvalid,
	input wire m_axis_eth1_tready,

	input wire [7:0] s_axis_eth1_tdata,
	input wire s_axis_eth1_tuser,
	input wire s_axis_eth1_tlast,
	input wire s_axis_eth1_tvalid,

	// ETH2

	input wire clk_rx2,

	output wire [7:0] m_axis_eth2_tdata,
	output wire m_axis_eth2_tuser,
	output wire m_axis_eth2_tlast,
	output wire m_axis_eth2_tvalid,
	input wire m_axis_eth2_tready,

	input wire [7:0] s_axis_eth2_tdata,
	input wire s_axis_eth2_tuser,
	input wire s_axis_eth2_tlast,
	input wire s_axis_eth2_tvalid,

	// ETH3

	input wire clk_rx3,

	output wire [7:0] m_axis_eth3_tdata,
	output wire m_axis_eth3_tuser,
	output wire m_axis_eth3_tlast,
	output wire m_axis_eth3_tvalid,
	input wire m_axis_eth3_tready,

	input wire [7:0] s_axis_eth3_tdata,
	input wire s_axis_eth3_tuser,
	input wire s_axis_eth3_tlast,
	input wire s_axis_eth3_tvalid,

	// M_AXIS_DMA

	output wire [127:0] m_axis_dma_tdata,
	output wire m_axis_dma_tlast,
	output wire m_axis_dma_tvalid,
	input wire m_axis_dma_tready,

	// S_AXI_PCIE

	input wire [21:0] s_axi_pcie_araddr,
	input wire [1:0] s_axi_pcie_arburst,
	input wire [7:0] s_axi_pcie_arlen,
	input wire [2:0] s_axi_pcie_arsize,
	input wire s_axi_pcie_arvalid,
	output wire s_axi_pcie_arready,

	output wire [63:0] s_axi_pcie_rdata,
	output wire [1:0] s_axi_pcie_rresp,
	output wire s_axi_pcie_rlast,
	output wire s_axi_pcie_rvalid,
	input wire s_axi_pcie_rready,

	input wire [21:0] s_axi_pcie_awaddr,
	input wire [1:0] s_axi_pcie_awburst,
	input wire [7:0] s_axi_pcie_awlen,
	input wire [2:0] s_axi_pcie_awsize,
	input wire s_axi_pcie_awvalid,
	output wire s_axi_pcie_awready,

	input wire [63:0] s_axi_pcie_wdata,
	input wire [7:0] s_axi_pcie_wstrb,
	input wire s_axi_pcie_wlast,
	input wire s_axi_pcie_wvalid,
	output wire s_axi_pcie_wready,

	output wire [1:0] s_axi_pcie_bresp,
	output wire s_axi_pcie_bvalid,
	input wire s_axi_pcie_bready
);
	bd_reconfig_region U0
	(
		.clk(clk),
		.rst_prc_n(rst_prc_n),
		.rst_pcie_n(rst_pcie_n),

		.shutdown_req(shutdown_req),
		.shutdown_ack(shutdown_ack),
		.active(active),

		// ETH0

		.clk_rx0(clk_rx0),

		.M_AXIS_ETH0_tdata(m_axis_eth0_tdata),
		.M_AXIS_ETH0_tuser(m_axis_eth0_tuser),
		.M_AXIS_ETH0_tlast(m_axis_eth0_tlast),
		.M_AXIS_ETH0_tvalid(m_axis_eth0_tvalid),
		.M_AXIS_ETH0_tready(m_axis_eth0_tready),

		.S_AXIS_ETH0_tdata(s_axis_eth0_tdata),
		.S_AXIS_ETH0_tuser(s_axis_eth0_tuser),
		.S_AXIS_ETH0_tlast(s_axis_eth0_tlast),
		.S_AXIS_ETH0_tvalid(s_axis_eth0_tvalid),

		// ETH1

		.clk_rx1(clk_rx1),

		.M_AXIS_ETH1_tdata(m_axis_eth1_tdata),
		.M_AXIS_ETH1_tuser(m_axis_eth1_tuser),
		.M_AXIS_ETH1_tlast(m_axis_eth1_tlast),
		.M_AXIS_ETH1_tvalid(m_axis_eth1_tvalid),
		.M_AXIS_ETH1_tready(m_axis_eth1_tready),

		.S_AXIS_ETH1_tdata(s_axis_eth1_tdata),
		.S_AXIS_ETH1_tuser(s_axis_eth1_tuser),
		.S_AXIS_ETH1_tlast(s_axis_eth1_tlast),
		.S_AXIS_ETH1_tvalid(s_axis_eth1_tvalid),

		// ETH2

		.clk_rx2(clk_rx2),

		.M_AXIS_ETH2_tdata(m_axis_eth2_tdata),
		.M_AXIS_ETH2_tuser(m_axis_eth2_tuser),
		.M_AXIS_ETH2_tlast(m_axis_eth2_tlast),
		.M_AXIS_ETH2_tvalid(m_axis_eth2_tvalid),
		.M_AXIS_ETH2_tready(m_axis_eth2_tready),

		.S_AXIS_ETH2_tdata(s_axis_eth2_tdata),
		.S_AXIS_ETH2_tuser(s_axis_eth2_tuser),
		.S_AXIS_ETH2_tlast(s_axis_eth2_tlast),
		.S_AXIS_ETH2_tvalid(s_axis_eth2_tvalid),

		// ETH3

		.clk_rx3(clk_rx3),

		.M_AXIS_ETH3_tdata(m_axis_eth3_tdata),
		.M_AXIS_ETH3_tuser(m_axis_eth3_tuser),
		.M_AXIS_ETH3_tlast(m_axis_eth3_tlast),
		.M_AXIS_ETH3_tvalid(m_axis_eth3_tvalid),
		.M_AXIS_ETH3_tready(m_axis_eth3_tready),

		.S_AXIS_ETH3_tdata(s_axis_eth3_tdata),
		.S_AXIS_ETH3_tuser(s_axis_eth3_tuser),
		.S_AXIS_ETH3_tlast(s_axis_eth3_tlast),
		.S_AXIS_ETH3_tvalid(s_axis_eth3_tvalid),

		// M_AXIS_DMA

		.M_AXIS_DMA_tdata(m_axis_dma_tdata),
		.M_AXIS_DMA_tlast(m_axis_dma_tlast),
		.M_AXIS_DMA_tvalid(m_axis_dma_tvalid),
		.M_AXIS_DMA_tready(m_axis_dma_tready),

		// S_AXI_PCIE

		.S_AXI_PCIE_araddr(s_axi_pcie_araddr),
		.S_AXI_PCIE_arburst(s_axi_pcie_arburst),
		.S_AXI_PCIE_arlen(s_axi_pcie_arlen),
		.S_AXI_PCIE_arsize(s_axi_pcie_arsize),
		.S_AXI_PCIE_arprot(3'd0),
		.S_AXI_PCIE_arcache(4'd0),
		.S_AXI_PCIE_arid(1'b0),
		.S_AXI_PCIE_arlock(1'b0),
		.S_AXI_PCIE_arqos(4'd0),
		.S_AXI_PCIE_arregion(4'd0),
		.S_AXI_PCIE_arvalid(s_axi_pcie_arvalid),
		.S_AXI_PCIE_arready(s_axi_pcie_arready),

		.S_AXI_PCIE_rdata(s_axi_pcie_rdata),
		.S_AXI_PCIE_rresp(s_axi_pcie_rresp),
		.S_AXI_PCIE_rlast(s_axi_pcie_rlast),
		.S_AXI_PCIE_rvalid(s_axi_pcie_rvalid),
		.S_AXI_PCIE_rready(s_axi_pcie_rready),

		.S_AXI_PCIE_awaddr(s_axi_pcie_awaddr),
		.S_AXI_PCIE_awburst(s_axi_pcie_awburst),
		.S_AXI_PCIE_awlen(s_axi_pcie_awlen),
		.S_AXI_PCIE_awsize(s_axi_pcie_awsize),
		.S_AXI_PCIE_awprot(3'd0),
		.S_AXI_PCIE_awcache(4'd0),
		.S_AXI_PCIE_awid(1'b0),
		.S_AXI_PCIE_awlock(1'b0),
		.S_AXI_PCIE_awqos(4'd0),
		.S_AXI_PCIE_awregion(4'd0),
		.S_AXI_PCIE_awvalid(s_axi_pcie_awvalid),
		.S_AXI_PCIE_awready(s_axi_pcie_awready),

		.S_AXI_PCIE_wdata(s_axi_pcie_wdata),
		.S_AXI_PCIE_wstrb(s_axi_pcie_wstrb),
		.S_AXI_PCIE_wlast(s_axi_pcie_wlast),
		.S_AXI_PCIE_wvalid(s_axi_pcie_wvalid),
		.S_AXI_PCIE_wready(s_axi_pcie_wready),

		.S_AXI_PCIE_bresp(s_axi_pcie_bresp),
		.S_AXI_PCIE_bvalid(s_axi_pcie_bvalid),
		.S_AXI_PCIE_bready(s_axi_pcie_bready)
	);
endmodule

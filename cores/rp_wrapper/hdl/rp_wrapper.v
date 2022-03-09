
module rp_wrapper
(
	input wire clk,
	input wire rst_n,
	input wire rst_prc_n,

	output wire active,

	// ETH0

	input wire clk_rx0,

	output wire [7:0] m_axis_eth0_tdata,
	output wire m_axis_eth0_tuser,
	output wire m_axis_eth0_tlast,
	output wire m_axis_eth0_tvalid,
	input wire m_axis_eth0_tready,

	input wire [7:0] s_axis_eth0_tdata,
	input wire [2:0] s_axis_eth0_tuser,
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
	input wire [2:0] s_axis_eth1_tuser,
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
	input wire [2:0] s_axis_eth2_tuser,
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
	input wire [2:0] s_axis_eth3_tuser,
	input wire s_axis_eth3_tlast,
	input wire s_axis_eth3_tvalid,

	// M_AXIS_DMA

	output wire [127:0] m_axis_dma_tdata,
	output wire m_axis_dma_tlast,
	output wire m_axis_dma_tvalid,
	input wire m_axis_dma_tready,

	// S_AXI_PCIE

	input wire [21:0] s_axi_pcie_araddr,
	input wire s_axi_pcie_arvalid,
	output wire s_axi_pcie_arready,

	output wire [63:0] s_axi_pcie_rdata,
	output wire [1:0] s_axi_pcie_rresp,
	output wire s_axi_pcie_rvalid,
	input wire s_axi_pcie_rready,

	input wire [21:0] s_axi_pcie_awaddr,
	input wire s_axi_pcie_awvalid,
	output wire s_axi_pcie_awready,

	input wire [63:0] s_axi_pcie_wdata,
	input wire [7:0] s_axi_pcie_wstrb,
	input wire s_axi_pcie_wvalid,
	output wire s_axi_pcie_wready,

	output wire [1:0] s_axi_pcie_bresp,
	output wire s_axi_pcie_bvalid,
	input wire s_axi_pcie_bready
);
endmodule


module rp_wrapper
(
	input wire clk,
	input wire rst_prc_n,
	input wire rst_pcie_n,

	input wire shutdown_req,
	output wire shutdown_ack,

	output wire active,
	output wire irq,

	// ETH0

	input wire clk_rx0,
	input wire [1:0] speed0,

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
	input wire [1:0] speed1,

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
	input wire [1:0] speed2,

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
	input wire [1:0] speed3,

	output wire [7:0] m_axis_eth3_tdata,
	output wire m_axis_eth3_tuser,
	output wire m_axis_eth3_tlast,
	output wire m_axis_eth3_tvalid,
	input wire m_axis_eth3_tready,

	input wire [7:0] s_axis_eth3_tdata,
	input wire s_axis_eth3_tuser,
	input wire s_axis_eth3_tlast,
	input wire s_axis_eth3_tvalid,

	// S_AXI_PCIE

	input wire [29:0] s_axi_pcie_araddr,
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

	input wire [29:0] s_axi_pcie_awaddr,
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
	input wire s_axi_pcie_bready,

	// M_AXI_PCIE

	output wire [31:0] m_axi_pcie_araddr,
	output wire [1:0] m_axi_pcie_arburst,
	output wire [7:0] m_axi_pcie_arlen,
	output wire [2:0] m_axi_pcie_arsize,
	output wire m_axi_pcie_arvalid,
	input wire m_axi_pcie_arready,

	input wire [127:0] m_axi_pcie_rdata,
	input wire [1:0] m_axi_pcie_rresp,
	input wire m_axi_pcie_rlast,
	input wire m_axi_pcie_rvalid,
	output wire m_axi_pcie_rready,

	output wire [31:0] m_axi_pcie_awaddr,
	output wire [1:0] m_axi_pcie_awburst,
	output wire [7:0] m_axi_pcie_awlen,
	output wire [2:0] m_axi_pcie_awsize,
	output wire m_axi_pcie_awvalid,
	input wire m_axi_pcie_awready,

	output wire [127:0] m_axi_pcie_wdata,
	output wire [15:0] m_axi_pcie_wstrb,
	output wire m_axi_pcie_wlast,
	output wire m_axi_pcie_wvalid,
	input wire m_axi_pcie_wready,

	input wire [1:0] m_axi_pcie_bresp,
	input wire m_axi_pcie_bvalid,
	output wire m_axi_pcie_bready,

	// M_AXI_DDR3_R

	output wire [28:0] m_axi_ddr3_r_araddr,
	output wire [1:0] m_axi_ddr3_r_arburst,
	output wire [7:0] m_axi_ddr3_r_arlen,
	output wire [2:0] m_axi_ddr3_r_arsize,
	output wire m_axi_ddr3_r_arid,
	output wire m_axi_ddr3_r_arvalid,
	input wire m_axi_ddr3_r_arready,

	input wire [63:0] m_axi_ddr3_r_rdata,
	input wire [1:0] m_axi_ddr3_r_rresp,
	input wire m_axi_ddr3_r_rid,
	input wire m_axi_ddr3_r_rlast,
	input wire m_axi_ddr3_r_rvalid,
	output wire m_axi_ddr3_r_rready,

	// M_AXI_DDR3_W

	output wire [28:0] m_axi_ddr3_w_awaddr,
	output wire [1:0] m_axi_ddr3_w_awburst,
	output wire [7:0] m_axi_ddr3_w_awlen,
	output wire [2:0] m_axi_ddr3_w_awsize,
	output wire m_axi_ddr3_w_awid,
	output wire m_axi_ddr3_w_awvalid,
	input wire m_axi_ddr3_w_awready,

	output wire [63:0] m_axi_ddr3_w_wdata,
	output wire m_axi_ddr3_w_wlast,
	output wire m_axi_ddr3_w_wvalid,
	input wire m_axi_ddr3_w_wready,

	input wire [1:0] m_axi_ddr3_w_bresp,
	input wire m_axi_ddr3_w_bid,
	input wire m_axi_ddr3_w_bvalid,
	output wire m_axi_ddr3_w_bready
);
endmodule

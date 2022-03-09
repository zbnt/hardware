cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core alexforencich.com verilog-ethernet eth_mac_1g 1.0]

ip::set_disp_name   $core "1G Ethernet MAC"
ip::set_description $core "1G Ethernet MAC"
ip::set_categories  $core /Communication_&_Networking/Ethernet

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/eth_mac_1g_wrapper.v
	hdl/eth_mac_1g.v
	hdl/axis_gmii_rx.v
	hdl/axis_gmii_tx.v
	hdl/eth_mac_1g_gmii.v
	hdl/eth_mac_1g_rgmii.v
	hdl/gmii_phy_if.v
	hdl/iddr.v
	hdl/lfsr.v
	hdl/oddr.v
	hdl/rgmii_phy_if.v
	hdl/ssio_ddr_in.v
	hdl/ssio_sdr_in.v
	hdl/ssio_sdr_out.v
}

ip::add_synth_sources $core xdc/eth_mac_1g.xdc

ip::add_gui_script $core xgui/eth_mac_1g.tcl
ip::add_gui_utils  $core xgui/eth_mac_1g.gtcl

ip::set_top $core eth_mac_1g_w hdl/eth_mac_1g_wrapper.v

# Parameters

ip::set_param_disp_name $core C_IFACE_TYPE "Interface Type"
ip::set_param_list      $core C_IFACE_TYPE {RGMII GMII}

ip::set_param_disp_name $core C_USE_CLK90 "Enable TX clock skew"
ip::set_param_format    $core C_USE_CLK90 bool
ip::set_param_value     $core C_USE_CLK90 false

ip::set_param_disp_name $core C_GTX_AS_RX_CLK "Use gtx_clk as TX and RX clocks"
ip::set_param_format    $core C_GTX_AS_RX_CLK bool
ip::set_param_value     $core C_GTX_AS_RX_CLK false

ip::set_param_disp_name $core C_IDELAY_VALUE "IDELAY Value"
ip::set_param_range     $core C_IDELAY_VALUE 0 31

ip::set_param_disp_name $core C_ENABLE_FCS_OUTPUT "Enable FCS output"
ip::set_param_format    $core C_ENABLE_FCS_OUTPUT bool
ip::set_param_value     $core C_ENABLE_FCS_OUTPUT false

ip::set_param_disp_name $core C_ENABLE_FCS_INPUT "Enable FCS input"
ip::set_param_format    $core C_ENABLE_FCS_INPUT bool
ip::set_param_value     $core C_ENABLE_FCS_INPUT false

ip::set_param_disp_name $core C_CLK_INPUT_STYLE "RX clock buffers"
ip::set_param_pairs     $core C_CLK_INPUT_STYLE {
	{BUFIO - BUFR} BUFR
	{BUFIO - BUFG} BUFIO
	{BUFG - BUFG}  BUFG
	None           NONE
}

# Interfaces

ip::add_bus_interface $core RGMII master "xilinx.com:interface:rgmii_rtl:1.0" "xilinx.com:interface:rgmii:1.0" {
	RD     rgmii_rd
	RXC    rgmii_rxc
	RX_CTL rgmii_rx_ctl
	TD     rgmii_td
	TXC    rgmii_txc
	TX_CTL rgmii_tx_ctl
}

ip::add_bus_interface $core GMII master "xilinx.com:interface:gmii_rtl:1.0" "xilinx.com:interface:gmii:1.0" {
	GTX_CLK gmii_tx_clk
	RX_CLK  gmii_rx_clk
	RXD     gmii_rxd
	RX_DV   gmii_rx_dv
	RX_ER   gmii_rx_er
	TX_CLK  mii_tx_clk
	TXD     gmii_txd
	TX_EN   gmii_tx_en
	TX_ER   gmii_tx_er
}

ip::add_axis_interface $core RX_AXIS master {DATA USER LAST VALID}
ip::add_axis_interface $core TX_AXIS slave  {DATA USER LAST VALID READY}

ip::add_clk_interface $core gtx_clk   slave  {}        gtx_rst_n TX_AXIS
ip::add_clk_interface $core gtx_clk90 slave  {}        {}        {}
ip::add_clk_interface $core rx_clk    master 125000000 {}        RX_AXIS
ip::add_rst_interface $core gtx_rst_n slave  ACTIVE_LOW

ip::set_iface_dependencies $core {
	GMII      {$C_IFACE_TYPE == "GMII"}
	RGMII     {$C_IFACE_TYPE == "RGMII"}
	gtx_clk90 {$C_IFACE_TYPE == "RGMII" && $C_USE_CLK90 != 0}
}

ip::save_core $core

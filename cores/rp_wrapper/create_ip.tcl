cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt rp_wrapper 1.0]

ip::set_disp_name   $core "ZBNT Reconfigurable Partition"
ip::set_description $core "ZBNT Reconfigurable Partition"
ip::set_categories  $core /UserIP

ip::set_supported_families $core {
	kintex7{xc7k325tffg676-1} Production
}

# Sources

ip::add_sources $core {
	hdl/rp_wrapper.v
}

ip::add_gui_script $core xgui/rp_wrapper.tcl

ip::set_top $core rp_wrapper hdl/rp_wrapper.v

# Interfaces

ip::add_axi_interface $core S_AXI_PCIE slave {
	AW {ADDR VALID READY}
	W  {DATA STRB VALID READY}
	B  {RESP VALID READY}
	AR {ADDR VALID READY}
	R  {DATA RESP VALID READY}
}

ip::add_axis_interface $core M_AXIS_DMA master {DATA LAST VALID READY}

for {set i 0} {$i < 4} {incr i} {
	ip::add_axis_interface $core M_AXIS_ETH${i} master {DATA USER LAST VALID READY}
}

for {set i 0} {$i < 4} {incr i} {
	ip::add_axis_interface $core S_AXIS_ETH${i} slave {DATA USER LAST VALID}
}

ip::add_clk_interface $core clk       slave {} rst_n:rst_prc_n S_AXI_PCIE:M_AXIS_DMA:M_AXIS_ETH0:M_AXIS_ETH1:M_AXIS_ETH2:M_AXIS_ETH3
ip::add_clk_interface $core clk_rx0   slave {} {}              S_AXIS_ETH0
ip::add_clk_interface $core clk_rx1   slave {} {}              S_AXIS_ETH1
ip::add_clk_interface $core clk_rx2   slave {} {}              S_AXIS_ETH2
ip::add_clk_interface $core clk_rx3   slave {} {}              S_AXIS_ETH3
ip::add_rst_interface $core rst_n     slave ACTIVE_LOW
ip::add_rst_interface $core rst_prc_n slave ACTIVE_LOW

ip::save_core $core

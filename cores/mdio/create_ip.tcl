cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt mdio 1.0]

ip::set_disp_name   $core "AXI MDIO"
ip::set_description $core "Provides access to MDIO registers via AXI"
ip::set_categories  $core /AXI_Peripheral

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/mdio_wrapper.v
	hdl/mdio.sv
	hdl/mdio_clk.sv
	hdl/mdio_fsm.sv
}

ip::add_gui_script $core xgui/mdio.tcl

ip::set_top $core mdio_w hdl/mdio_wrapper.v

# Parameters

ip::set_param_disp_name $core C_AXI_WIDTH "AXI Data Width"
ip::set_param_list      $core C_AXI_WIDTH {32 64}

ip::set_param_disp_name $core C_PREAMBLE_TIME "Preamble length"
ip::set_param_range     $core C_PREAMBLE_TIME 1 32

# Interfaces

ip::add_axi_interface $core S_AXI slave {
	AW {ADDR PROT VALID READY}
	W  {DATA STRB VALID READY}
	B  {RESP VALID READY}
	AR {ADDR PROT VALID READY}
	R  {DATA RESP VALID READY}
}

ip::add_clk_interface $core clk   slave {} rst_n S_AXI
ip::add_rst_interface $core rst_n slave ACTIVE_LOW

ip::save_core $core

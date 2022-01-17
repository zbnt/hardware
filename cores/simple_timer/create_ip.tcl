cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt simple_timer 1.1]

ip::set_disp_name   $core "Simple AXI Timer"
ip::set_description $core "Simple 64-bits timer with AXI4-Lite interface"
ip::set_categories  $core AXI_Peripheral

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/simple_timer_wrapper.v
	hdl/simple_timer.sv
	hdl/simple_timer_axi.sv
}

ip::add_subcore    $core "oscar-rc.dev:zbnt:common:1.0"
ip::add_gui_script $core xgui/simple_timer.tcl

ip::set_top $core simple_timer_w hdl/simple_timer_wrapper.v

# Parameters

ip::set_param_disp_name $core axi_width "AXI Data Width"
ip::set_param_list      $core axi_width {32 64}

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

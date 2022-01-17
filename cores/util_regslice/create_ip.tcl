cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt util_regslice 1.0]

ip::set_disp_name   $core "Register Slice"
ip::set_description $core "Simple register slice"
ip::set_categories  $core /BaseIP

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/util_regslice.v
}

ip::add_subcore $core "oscar-rc.dev:zbnt:common:1.0"
ip::add_gui_script $core xgui/util_regslice.tcl

ip::set_top $core util_regslice hdl/util_regslice.v

# Parameters

ip::set_param_disp_name $core C_WIDTH "Width"
ip::set_param_range     $core C_WIDTH 1 1024

ip::set_param_disp_name $core C_NUM_STAGES "Stages"
ip::set_param_range     $core C_NUM_STAGES 1 32

# Interfaces

ip::add_clk_interface $core clk   slave {} rst_n {}
ip::add_rst_interface $core rst_n slave ACTIVE_LOW

ip::save_core $core

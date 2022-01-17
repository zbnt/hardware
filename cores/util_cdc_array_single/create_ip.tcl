cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt util_cdc_array_single 1.0]

ip::set_disp_name   $core "Single-bit Array CDC"
ip::set_description $core "Single-bit Array CDC"
ip::set_categories  $core /BaseIP

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/util_cdc_array_single.v
}

ip::add_gui_script $core xgui/util_cdc_array_single.tcl

ip::set_top $core util_cdc_array_single hdl/util_cdc_array_single.v

# Parameters

ip::set_param_disp_name $core C_WIDTH "Width"
ip::set_param_range     $core C_WIDTH 1 1024

ip::set_param_disp_name $core C_NUM_STAGES "Stages"
ip::set_param_range     $core C_NUM_STAGES 2 10

# Interfaces

ip::add_clk_interface $core clk_dst slave {} {} {}
ip::add_clk_interface $core clk_src slave {} {} {}

ip::save_core $core

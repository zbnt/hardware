cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt util_iobuf 1.0]

ip::set_disp_name   $core "IOBUF"
ip::set_description $core "Wrapper for the IOBUF primitive"
ip::set_categories  $core /BaseIP

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/util_iobuf.v
}

ip::add_gui_script $core xgui/util_iobuf.tcl

ip::set_top $core util_iobuf hdl/util_iobuf.v

# Parameters

ip::set_param_disp_name $core C_WIDTH "Width"
ip::set_param_range     $core C_WIDTH 1 2048

ip::save_core $core

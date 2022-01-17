cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt util_axis2msi 1.0]

ip::set_disp_name   $core "AXI-Stream to MSI"
ip::set_description $core "AXI-Stream to MSI"
ip::set_categories  $core /AXI_Infrastructure

ip::set_supported_families $core {
	kintex7 Production
}

# Sources

ip::add_sources $core {
	hdl/util_axis2msi.v
}

ip::add_gui_script $core xgui/util_axis2msi.tcl

ip::set_top $core util_axis2msi hdl/util_axis2msi.v

# Interfaces

ip::add_axis_interface $core S_AXIS slave {DATA VALID READY}
ip::add_clk_interface  $core clk    slave {} rst_n S_AXIS
ip::add_rst_interface  $core rst_n  slave ACTIVE_LOW

ip::save_core $core

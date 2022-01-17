cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt util_startup 1.0]

ip::set_disp_name   $core "STARTUP"
ip::set_description $core "Wrapper for the STARTUPE2/STARTUPE3 primitives"
ip::set_categories  $core /BaseIP

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/util_startup.v
}

ip::add_gui_script $core xgui/util_startup.tcl
ip::add_gui_utils  $core xgui/util_startup.gtcl

ip::set_top $core util_startup hdl/util_startup.v

# Parameters

ip::set_param_disp_name $core C_FAMILY_TYPE "Type"
ip::set_param_pairs     $core C_FAMILY_TYPE {{7-Series (STARTUPE2)} 0 {UltraScale (STARTUPE3)} 1}

ip::set_param_disp_name $core C_PROG_USR "PROG_USR"
ip::set_param_pairs     $core C_PROG_USR {true TRUE false FALSE}

ip::set_param_disp_name $core C_SIM_CCLK_FREQ "SIM_CCLK_FREQ"
ip::set_param_format    $core C_SIM_CCLK_FREQ float

ip::add_param           $core C_ENABLE_CLK bool false
ip::set_param_disp_name $core C_ENABLE_CLK "Enable clk input"

# Interfaces

ip::add_clk_interface $core clk slave {} {} {}

ip::set_iface_dependency $core clk {$C_FAMILY_TYPE == 0 && $C_ENABLE_CLK}

ip::set_port_dependencies $core {
	di     {$C_FAMILY_TYPE == 1}
	do     {$C_FAMILY_TYPE == 1}
	dts    {$C_FAMILY_TYPE == 1}
	fcsbo  {$C_FAMILY_TYPE == 1}
	fcsbts {$C_FAMILY_TYPE == 1}
	pack   {$C_PROG_USR == "TRUE"}
}

ip::set_port_drivers $core {
	clk       0
	di        0
	do        0
	dts       7
	fcsbo     0
	fcsbts    1
	gsr       0
	gts       0
	keyclearb 1
	pack      1
	usrcclko  0
	usrcclkts 1
	usrdoneo  0
	usrdonets 1
}

ip::save_core $core

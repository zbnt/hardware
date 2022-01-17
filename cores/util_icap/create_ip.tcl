cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt util_icap 1.0]

ip::set_disp_name   $core "ICAP"
ip::set_description $core "Wrapper for the ICAPE2/ICAPE3 primitives"
ip::set_categories  $core /BaseIP

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/util_icap.v
}

ip::add_gui_script $core xgui/util_icap.tcl

ip::set_top $core util_icap hdl/util_icap.v

# Parameters

ip::set_param_disp_name $core C_FAMILY_TYPE "Type"
ip::set_param_pairs     $core C_FAMILY_TYPE {{7-Series (ICAPE2)} 0 {UltraScale (ICAPE3)} 1}

# Interfaces

ip::add_bus_interface $core ICAP slave "xilinx.com:interface:icap_rtl:1.0" "xilinx.com:interface:icap:1.0" {
	avail   avail
	csib    csib
	i       i
	o       o
	prdone  prdone
	prerror prerror
	rdwrb   rdwrb
}

ip::set_port_dependencies $core {
	avail   {$C_FAMILY_TYPE == 1}
	prdone  {$C_FAMILY_TYPE == 1}
	prerror {$C_FAMILY_TYPE == 1}
}

ip::set_port_drivers $core {
	avail   0
	clk     0
	prdone  0
	prerror 0
}

ip::save_core $core

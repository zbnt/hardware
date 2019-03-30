# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set mem_size [ipgui::add_param $IPINST -name "mem_size" -parent ${Page_0}]
  set_property tooltip {Size in bytes of attached memory} ${mem_size}
  set mem_addr_width [ipgui::add_param $IPINST -name "mem_addr_width" -parent ${Page_0}]
  set_property tooltip {Width in bits of attached memory addresses} ${mem_addr_width}


}

proc update_PARAM_VALUE.mem_addr_width { PARAM_VALUE.mem_addr_width } {
	# Procedure called to update mem_addr_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.mem_addr_width { PARAM_VALUE.mem_addr_width } {
	# Procedure called to validate mem_addr_width
	return true
}

proc update_PARAM_VALUE.mem_size { PARAM_VALUE.mem_size } {
	# Procedure called to update mem_size when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.mem_size { PARAM_VALUE.mem_size } {
	# Procedure called to validate mem_size
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to update C_S_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to validate C_S_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to update C_S_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to validate C_S_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.mem_addr_width { MODELPARAM_VALUE.mem_addr_width PARAM_VALUE.mem_addr_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.mem_addr_width}] ${MODELPARAM_VALUE.mem_addr_width}
}

proc update_MODELPARAM_VALUE.mem_size { MODELPARAM_VALUE.mem_size PARAM_VALUE.mem_size } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.mem_size}] ${MODELPARAM_VALUE.mem_size}
}


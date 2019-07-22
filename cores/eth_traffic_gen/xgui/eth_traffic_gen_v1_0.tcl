# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set axi_width [ipgui::add_param $IPINST -name "axi_width" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Width of the AXI bus, in bytes.} ${axi_width}
  set use_ext_enable [ipgui::add_param $IPINST -name "use_ext_enable" -parent ${Page_0}]
  set_property tooltip {Adds an input signal for enabling frame transmission} ${use_ext_enable}


}

proc update_PARAM_VALUE.axi_width { PARAM_VALUE.axi_width } {
	# Procedure called to update axi_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.axi_width { PARAM_VALUE.axi_width } {
	# Procedure called to validate axi_width
	return true
}

proc update_PARAM_VALUE.use_ext_enable { PARAM_VALUE.use_ext_enable } {
	# Procedure called to update use_ext_enable when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.use_ext_enable { PARAM_VALUE.use_ext_enable } {
	# Procedure called to validate use_ext_enable
	return true
}


proc update_MODELPARAM_VALUE.use_ext_enable { MODELPARAM_VALUE.use_ext_enable PARAM_VALUE.use_ext_enable } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.use_ext_enable}] ${MODELPARAM_VALUE.use_ext_enable}
}

proc update_MODELPARAM_VALUE.axi_width { MODELPARAM_VALUE.axi_width PARAM_VALUE.axi_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.axi_width}] ${MODELPARAM_VALUE.axi_width}
}


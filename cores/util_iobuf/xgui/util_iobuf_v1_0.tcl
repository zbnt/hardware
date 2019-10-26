# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"

}

proc update_PARAM_VALUE.C_WIDTH { PARAM_VALUE.C_WIDTH } {
	# Procedure called to update C_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_WIDTH { PARAM_VALUE.C_WIDTH } {
	# Procedure called to validate C_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_WIDTH { MODELPARAM_VALUE.C_WIDTH PARAM_VALUE.C_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_WIDTH}] ${MODELPARAM_VALUE.C_WIDTH}
}


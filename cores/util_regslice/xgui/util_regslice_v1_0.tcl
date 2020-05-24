# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_WIDTH" -parent ${Page_0}
  set C_NUM_STAGES [ipgui::add_param $IPINST -name "C_NUM_STAGES" -parent ${Page_0}]
  set_property tooltip {Number of register stages} ${C_NUM_STAGES}


}

proc update_PARAM_VALUE.C_NUM_STAGES { PARAM_VALUE.C_NUM_STAGES } {
	# Procedure called to update C_NUM_STAGES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_NUM_STAGES { PARAM_VALUE.C_NUM_STAGES } {
	# Procedure called to validate C_NUM_STAGES
	return true
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

proc update_MODELPARAM_VALUE.C_NUM_STAGES { MODELPARAM_VALUE.C_NUM_STAGES PARAM_VALUE.C_NUM_STAGES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_NUM_STAGES}] ${MODELPARAM_VALUE.C_NUM_STAGES}
}


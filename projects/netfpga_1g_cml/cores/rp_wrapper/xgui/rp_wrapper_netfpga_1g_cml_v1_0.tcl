# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_ENABLE_DDR3" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_ENABLE_DDR3 { PARAM_VALUE.C_ENABLE_DDR3 } {
	# Procedure called to update C_ENABLE_DDR3 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ENABLE_DDR3 { PARAM_VALUE.C_ENABLE_DDR3 } {
	# Procedure called to validate C_ENABLE_DDR3
	return true
}



proc init_gui { IPINST } {
	ipgui::add_param $IPINST -name "Component_Name"

	set Page_0 [ipgui::add_page $IPINST -name "Page 0"]

	set C_AXI_WIDTH [ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${Page_0} -layout horizontal]
	set_property tooltip {Width of the AXI bus, in bits.} ${C_AXI_WIDTH}

	set Other_options [ipgui::add_group $IPINST -name "Other options" -parent ${Page_0}]
	ipgui::add_param $IPINST -name "C_EXT_ENABLE" -parent ${Other_options}
}

proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {}
proc update_PARAM_VALUE.C_EXT_ENABLE { PARAM_VALUE.C_EXT_ENABLE } {}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_EXT_ENABLE { PARAM_VALUE.C_EXT_ENABLE } {
	return true
}

proc update_MODELPARAM_VALUE.C_AXI_WIDTH { MODELPARAM_VALUE.C_AXI_WIDTH PARAM_VALUE.C_AXI_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WIDTH}] ${MODELPARAM_VALUE.C_AXI_WIDTH}
}

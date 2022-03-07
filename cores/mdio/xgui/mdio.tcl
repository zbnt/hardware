proc init_gui { IPINST } {
	ipgui::add_param $IPINST -name "Component_Name"

	set Page_0 [ipgui::add_page $IPINST -name "Page 0"]

	set C_AXI_WIDTH [ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${Page_0} -layout horizontal]
	set_property tooltip {Width of the AXI bus, in bits.} ${C_AXI_WIDTH}

	set Timing [ipgui::add_group $IPINST -name "Timing" -parent ${Page_0}]

	set C_PREAMBLE_TIME [ipgui::add_param $IPINST -name "C_PREAMBLE_TIME" -parent ${Timing}]
	set_property tooltip {Number of clock cycles to wait before sending the start sequence.} ${C_PREAMBLE_TIME}
}

proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {}
proc update_PARAM_VALUE.C_PREAMBLE_TIME { PARAM_VALUE.C_PREAMBLE_TIME } {}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_PREAMBLE_TIME { PARAM_VALUE.C_PREAMBLE_TIME } {
	return true
}

proc update_MODELPARAM_VALUE.C_AXI_WIDTH { MODELPARAM_VALUE.C_AXI_WIDTH PARAM_VALUE.C_AXI_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WIDTH}] ${MODELPARAM_VALUE.C_AXI_WIDTH}
}

proc update_MODELPARAM_VALUE.C_PREAMBLE_TIME { MODELPARAM_VALUE.C_PREAMBLE_TIME PARAM_VALUE.C_PREAMBLE_TIME } {
	set_property value [get_property value ${PARAM_VALUE.C_PREAMBLE_TIME}] ${MODELPARAM_VALUE.C_PREAMBLE_TIME}
}

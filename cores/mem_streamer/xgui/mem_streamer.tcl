proc init_gui { IPINST } {
	ipgui::add_param $IPINST -name "Component_Name"

	set Settings [ipgui::add_page $IPINST -name "Settings"]

	set C_DATA_WIDTH [ipgui::add_param $IPINST -name "C_DATA_WIDTH" -parent ${Settings} -widget comboBox]
	set_property tooltip {Width of the memory data, in bits.} ${C_DATA_WIDTH}

	set C_MEM_SIZE [ipgui::add_param $IPINST -name "C_MEM_SIZE" -parent ${Settings}]
	set_property tooltip {Size of the memory, in bytes.} ${C_MEM_SIZE}

	set C_DELAY_TIME [ipgui::add_param $IPINST -name "C_DELAY_TIME" -parent ${Settings}]
	set_property tooltip {Number of clock cycles to wait before restarting transmission.} ${C_DELAY_TIME}
}

proc update_PARAM_VALUE.C_DATA_WIDTH { PARAM_VALUE.C_DATA_WIDTH } {}
proc update_PARAM_VALUE.C_DELAY_TIME { PARAM_VALUE.C_DELAY_TIME } {}
proc update_PARAM_VALUE.C_MEM_SIZE { PARAM_VALUE.C_MEM_SIZE } {}

proc validate_PARAM_VALUE.C_DATA_WIDTH { PARAM_VALUE.C_DATA_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_DELAY_TIME { PARAM_VALUE.C_DELAY_TIME } {
	return true
}

proc validate_PARAM_VALUE.C_MEM_SIZE { PARAM_VALUE.C_MEM_SIZE } {
	return true
}

proc update_MODELPARAM_VALUE.C_MEM_SIZE { MODELPARAM_VALUE.C_MEM_SIZE PARAM_VALUE.C_MEM_SIZE } {
	set_property value [get_property value ${PARAM_VALUE.C_MEM_SIZE}] ${MODELPARAM_VALUE.C_MEM_SIZE}
}

proc update_MODELPARAM_VALUE.C_DATA_WIDTH { MODELPARAM_VALUE.C_DATA_WIDTH PARAM_VALUE.C_DATA_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_DATA_WIDTH}] ${MODELPARAM_VALUE.C_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_DELAY_TIME { MODELPARAM_VALUE.C_DELAY_TIME PARAM_VALUE.C_DELAY_TIME } {
	set_property value [get_property value ${PARAM_VALUE.C_DELAY_TIME}] ${MODELPARAM_VALUE.C_DELAY_TIME}
}

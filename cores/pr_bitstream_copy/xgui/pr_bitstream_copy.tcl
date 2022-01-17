proc init_gui { IPINST } {
	ipgui::add_param $IPINST -name "Component_Name"

	set Page_0 [ipgui::add_page $IPINST -name "Page 0"]

	set AXI [ipgui::add_group $IPINST -name "AXI" -parent ${Page_0}]
	ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${AXI} -widget comboBox
	ipgui::add_param $IPINST -name "C_AXI_ADDR_WIDTH" -parent ${AXI}
	ipgui::add_param $IPINST -name "C_SOURCE_ADDR" -parent ${AXI}
	ipgui::add_param $IPINST -name "C_DESTINATION_ADDR" -parent ${AXI}

	set C_MEMORY_SIZE [ipgui::add_param $IPINST -name "C_MEMORY_SIZE" -parent ${AXI}]
	set_property tooltip {Memory size, in bytes} ${C_MEMORY_SIZE}
}

proc update_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {}
proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {}
proc update_PARAM_VALUE.C_DESTINATION_ADDR { PARAM_VALUE.C_DESTINATION_ADDR } {}
proc update_PARAM_VALUE.C_MEMORY_SIZE { PARAM_VALUE.C_MEMORY_SIZE } {}
proc update_PARAM_VALUE.C_SOURCE_ADDR { PARAM_VALUE.C_SOURCE_ADDR } {}

proc validate_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_DESTINATION_ADDR { PARAM_VALUE.C_DESTINATION_ADDR } {
	return true
}

proc validate_PARAM_VALUE.C_MEMORY_SIZE { PARAM_VALUE.C_MEMORY_SIZE } {
	return true
}

proc validate_PARAM_VALUE.C_SOURCE_ADDR { PARAM_VALUE.C_SOURCE_ADDR } {
	return true
}

proc update_MODELPARAM_VALUE.C_AXI_WIDTH { MODELPARAM_VALUE.C_AXI_WIDTH PARAM_VALUE.C_AXI_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WIDTH}] ${MODELPARAM_VALUE.C_AXI_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_ADDR_WIDTH PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_SOURCE_ADDR { MODELPARAM_VALUE.C_SOURCE_ADDR PARAM_VALUE.C_SOURCE_ADDR } {
	set_property value [get_property value ${PARAM_VALUE.C_SOURCE_ADDR}] ${MODELPARAM_VALUE.C_SOURCE_ADDR}
}

proc update_MODELPARAM_VALUE.C_DESTINATION_ADDR { MODELPARAM_VALUE.C_DESTINATION_ADDR PARAM_VALUE.C_DESTINATION_ADDR } {
	set_property value [get_property value ${PARAM_VALUE.C_DESTINATION_ADDR}] ${MODELPARAM_VALUE.C_DESTINATION_ADDR}
}

proc update_MODELPARAM_VALUE.C_MEMORY_SIZE { MODELPARAM_VALUE.C_MEMORY_SIZE PARAM_VALUE.C_MEMORY_SIZE } {
	set_property value [get_property value ${PARAM_VALUE.C_MEMORY_SIZE}] ${MODELPARAM_VALUE.C_MEMORY_SIZE}
}

proc init_gui { IPINST } {
	ipgui::add_param $IPINST -name "Component_Name"

	set Page_0 [ipgui::add_page $IPINST -name "Page 0"]

	set AXI [ipgui::add_group $IPINST -name "AXI" -parent ${Page_0}]
	ipgui::add_param $IPINST -name "C_AXI_ADDR_WIDTH" -parent ${AXI} -widget comboBox
	ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${AXI} -widget comboBox
	ipgui::add_param $IPINST -name "C_AXI_MAX_BURST" -parent ${AXI}
	ipgui::add_param $IPINST -name "C_VALUE_AWCACHE" -parent ${AXI}
	ipgui::add_param $IPINST -name "C_VALUE_AWUSER" -parent ${AXI}
	ipgui::add_param $IPINST -name "C_VALUE_AWPROT" -parent ${AXI}

	set FIFO [ipgui::add_group $IPINST -name "FIFO" -parent ${Page_0}]
	ipgui::add_param $IPINST -name "C_FIFO_TYPE" -parent ${FIFO} -widget comboBox
	ipgui::add_param $IPINST -name "C_FIFO_SIZE" -parent ${FIFO}
}

proc update_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {}
proc update_PARAM_VALUE.C_AXI_MAX_BURST { PARAM_VALUE.C_AXI_MAX_BURST } {}
proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {}
proc update_PARAM_VALUE.C_FIFO_SIZE { PARAM_VALUE.C_FIFO_SIZE } {}
proc update_PARAM_VALUE.C_FIFO_TYPE { PARAM_VALUE.C_FIFO_TYPE } {}
proc update_PARAM_VALUE.C_VALUE_AWCACHE { PARAM_VALUE.C_VALUE_AWCACHE } {}
proc update_PARAM_VALUE.C_VALUE_AWPROT { PARAM_VALUE.C_VALUE_AWPROT } {}
proc update_PARAM_VALUE.C_VALUE_AWUSER { PARAM_VALUE.C_VALUE_AWUSER } {}

proc validate_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_AXI_MAX_BURST { PARAM_VALUE.C_AXI_MAX_BURST } {
	return true
}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_FIFO_SIZE { PARAM_VALUE.C_FIFO_SIZE } {
	return true
}

proc validate_PARAM_VALUE.C_FIFO_TYPE { PARAM_VALUE.C_FIFO_TYPE } {
	return true
}

proc validate_PARAM_VALUE.C_VALUE_AWCACHE { PARAM_VALUE.C_VALUE_AWCACHE } {
	return true
}

proc validate_PARAM_VALUE.C_VALUE_AWPROT { PARAM_VALUE.C_VALUE_AWPROT } {
	return true
}

proc validate_PARAM_VALUE.C_VALUE_AWUSER { PARAM_VALUE.C_VALUE_AWUSER } {
	return true
}

proc update_MODELPARAM_VALUE.C_AXI_WIDTH { MODELPARAM_VALUE.C_AXI_WIDTH PARAM_VALUE.C_AXI_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WIDTH}] ${MODELPARAM_VALUE.C_AXI_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_ADDR_WIDTH PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_MAX_BURST { MODELPARAM_VALUE.C_AXI_MAX_BURST PARAM_VALUE.C_AXI_MAX_BURST } {
	set_property value [get_property value ${PARAM_VALUE.C_AXI_MAX_BURST}] ${MODELPARAM_VALUE.C_AXI_MAX_BURST}
}

proc update_MODELPARAM_VALUE.C_FIFO_SIZE { MODELPARAM_VALUE.C_FIFO_SIZE PARAM_VALUE.C_FIFO_SIZE } {
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_SIZE}] ${MODELPARAM_VALUE.C_FIFO_SIZE}
}

proc update_MODELPARAM_VALUE.C_FIFO_TYPE { MODELPARAM_VALUE.C_FIFO_TYPE PARAM_VALUE.C_FIFO_TYPE } {
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_TYPE}] ${MODELPARAM_VALUE.C_FIFO_TYPE}
}

proc update_MODELPARAM_VALUE.C_VALUE_AWPROT { MODELPARAM_VALUE.C_VALUE_AWPROT PARAM_VALUE.C_VALUE_AWPROT } {
	set_property value [get_property value ${PARAM_VALUE.C_VALUE_AWPROT}] ${MODELPARAM_VALUE.C_VALUE_AWPROT}
}

proc update_MODELPARAM_VALUE.C_VALUE_AWCACHE { MODELPARAM_VALUE.C_VALUE_AWCACHE PARAM_VALUE.C_VALUE_AWCACHE } {
	set_property value [get_property value ${PARAM_VALUE.C_VALUE_AWCACHE}] ${MODELPARAM_VALUE.C_VALUE_AWCACHE}
}

proc update_MODELPARAM_VALUE.C_VALUE_AWUSER { MODELPARAM_VALUE.C_VALUE_AWUSER PARAM_VALUE.C_VALUE_AWUSER } {
	set_property value [get_property value ${PARAM_VALUE.C_VALUE_AWUSER}] ${MODELPARAM_VALUE.C_VALUE_AWUSER}
}

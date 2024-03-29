proc init_gui { IPINST } {
	ipgui::add_param $IPINST -name "Component_Name"

	set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {AXI}]

	set S_AXI_Options [ipgui::add_group $IPINST -name "S_AXI Options" -parent ${Page_0} -display_name {S_AXI Options}]

	set C_AXI_WIDTH [ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${S_AXI_Options} -widget comboBox]
	set_property tooltip {Width of the S_AXI bus, in bits.} ${C_AXI_WIDTH}

	set DMA_Options [ipgui::add_group $IPINST -name "DMA Options" -parent ${Page_0}]

	set C_AXIS_WIDTH [ipgui::add_param $IPINST -name "C_AXIS_WIDTH" -parent ${DMA_Options} -widget comboBox]
	set_property tooltip {Width of the S_AXIS and M_AXI interfaces, in bits.} ${C_AXIS_WIDTH}

	set C_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_ADDR_WIDTH" -parent ${DMA_Options} -widget comboBox]
	set_property tooltip {Width of the memory addresses, in bits.} ${C_ADDR_WIDTH}

	set C_MAX_BURST [ipgui::add_param $IPINST -name "C_MAX_BURST" -parent ${DMA_Options} -widget comboBox]
	set_property tooltip {Maximum number of transfers in one burst.} ${C_MAX_BURST}

	set M_AXI_Options [ipgui::add_group $IPINST -name "M_AXI Options" -parent ${Page_0} -display_name {M_AXI Options}]

	set C_VALUE_AWPROT [ipgui::add_param $IPINST -name "C_VALUE_AWPROT" -parent ${M_AXI_Options}]
	set_property tooltip {Value for the AWPROT signal in M_AXI} ${C_VALUE_AWPROT}

	set C_VALUE_AWCACHE [ipgui::add_param $IPINST -name "C_VALUE_AWCACHE" -parent ${M_AXI_Options}]
	set_property tooltip {Value for the AWCACHE signal in M_AXI} ${C_VALUE_AWCACHE}

	set C_VALUE_AWUSER [ipgui::add_param $IPINST -name "C_VALUE_AWUSER" -parent ${M_AXI_Options}]
	set_property tooltip {Value for the AWUSER signal in M_AXI} ${C_VALUE_AWUSER}

	ipgui::add_group $IPINST -name "Other options" -parent ${Page_0}

	set FIFOs [ipgui::add_page $IPINST -name "FIFOs"]

	set FIFO_1 [ipgui::add_group $IPINST -name "FIFO 1" -parent ${FIFOs} -layout horizontal]
	ipgui::add_param $IPINST -name "C_FIFO_TYPE_0" -parent ${FIFO_1} -widget comboBox
	ipgui::add_param $IPINST -name "C_FIFO_DEPTH_0" -parent ${FIFO_1} -widget comboBox

	set FIFO_2 [ipgui::add_group $IPINST -name "FIFO 2" -parent ${FIFOs} -layout horizontal]
	ipgui::add_param $IPINST -name "C_FIFO_TYPE_1" -parent ${FIFO_2} -widget comboBox
	ipgui::add_param $IPINST -name "C_FIFO_DEPTH_1" -parent ${FIFO_2} -widget comboBox

	set FIFO_3 [ipgui::add_group $IPINST -name "FIFO 3" -parent ${FIFOs} -layout horizontal]
	ipgui::add_param $IPINST -name "C_FIFO_TYPE_2" -parent ${FIFO_3} -widget comboBox
	ipgui::add_param $IPINST -name "C_FIFO_DEPTH_2" -parent ${FIFO_3} -widget comboBox

	set FIFO_4 [ipgui::add_group $IPINST -name "FIFO 4" -parent ${FIFOs} -layout horizontal]
	ipgui::add_param $IPINST -name "C_FIFO_TYPE_3" -parent ${FIFO_4} -widget comboBox
	ipgui::add_param $IPINST -name "C_FIFO_DEPTH_3" -parent ${FIFO_4} -widget comboBox
}

proc update_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {}
proc update_PARAM_VALUE.C_AXIS_WIDTH { PARAM_VALUE.C_AXIS_WIDTH } {}
proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {}
proc update_PARAM_VALUE.C_FIFO_DEPTH_0 { PARAM_VALUE.C_FIFO_DEPTH_0 } {}
proc update_PARAM_VALUE.C_FIFO_DEPTH_1 { PARAM_VALUE.C_FIFO_DEPTH_1 } {}
proc update_PARAM_VALUE.C_FIFO_DEPTH_2 { PARAM_VALUE.C_FIFO_DEPTH_2 } {}
proc update_PARAM_VALUE.C_FIFO_DEPTH_3 { PARAM_VALUE.C_FIFO_DEPTH_3 } {}
proc update_PARAM_VALUE.C_FIFO_TYPE_0 { PARAM_VALUE.C_FIFO_TYPE_0 } {}
proc update_PARAM_VALUE.C_FIFO_TYPE_1 { PARAM_VALUE.C_FIFO_TYPE_1 } {}
proc update_PARAM_VALUE.C_FIFO_TYPE_2 { PARAM_VALUE.C_FIFO_TYPE_2 } {}
proc update_PARAM_VALUE.C_FIFO_TYPE_3 { PARAM_VALUE.C_FIFO_TYPE_3 } {}
proc update_PARAM_VALUE.C_MAX_BURST { PARAM_VALUE.C_MAX_BURST } {}
proc update_PARAM_VALUE.C_VALUE_AWCACHE { PARAM_VALUE.C_VALUE_AWCACHE } {}
proc update_PARAM_VALUE.C_VALUE_AWPROT { PARAM_VALUE.C_VALUE_AWPROT } {}
proc update_PARAM_VALUE.C_VALUE_AWUSER { PARAM_VALUE.C_VALUE_AWUSER } {}

proc validate_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_AXIS_WIDTH { PARAM_VALUE.C_AXIS_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_FIFO_DEPTH_0 { PARAM_VALUE.C_FIFO_DEPTH_0 } {
	return true
}

proc validate_PARAM_VALUE.C_FIFO_DEPTH_1 { PARAM_VALUE.C_FIFO_DEPTH_1 } {
	return true
}

proc validate_PARAM_VALUE.C_FIFO_DEPTH_2 { PARAM_VALUE.C_FIFO_DEPTH_2 } {
	return true
}

proc validate_PARAM_VALUE.C_FIFO_DEPTH_3 { PARAM_VALUE.C_FIFO_DEPTH_3 } {
	return true
}

proc validate_PARAM_VALUE.C_FIFO_TYPE_0 { PARAM_VALUE.C_FIFO_TYPE_0 } {
	return true
}

proc validate_PARAM_VALUE.C_FIFO_TYPE_1 { PARAM_VALUE.C_FIFO_TYPE_1 } {
	return true
}

proc validate_PARAM_VALUE.C_FIFO_TYPE_2 { PARAM_VALUE.C_FIFO_TYPE_2 } {
	return true
}

proc validate_PARAM_VALUE.C_FIFO_TYPE_3 { PARAM_VALUE.C_FIFO_TYPE_3 } {
	return true
}

proc validate_PARAM_VALUE.C_MAX_BURST { PARAM_VALUE.C_MAX_BURST } {
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

proc update_MODELPARAM_VALUE.C_ADDR_WIDTH { MODELPARAM_VALUE.C_ADDR_WIDTH PARAM_VALUE.C_ADDR_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_WIDTH { MODELPARAM_VALUE.C_AXIS_WIDTH PARAM_VALUE.C_AXIS_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_WIDTH}
}

proc update_MODELPARAM_VALUE.C_MAX_BURST { MODELPARAM_VALUE.C_MAX_BURST PARAM_VALUE.C_MAX_BURST } {
	set_property value [get_property value ${PARAM_VALUE.C_MAX_BURST}] ${MODELPARAM_VALUE.C_MAX_BURST}
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

proc update_MODELPARAM_VALUE.C_FIFO_TYPE_0 { MODELPARAM_VALUE.C_FIFO_TYPE_0 PARAM_VALUE.C_FIFO_TYPE_0 } {
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_TYPE_0}] ${MODELPARAM_VALUE.C_FIFO_TYPE_0}
}

proc update_MODELPARAM_VALUE.C_FIFO_TYPE_1 { MODELPARAM_VALUE.C_FIFO_TYPE_1 PARAM_VALUE.C_FIFO_TYPE_1 } {
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_TYPE_1}] ${MODELPARAM_VALUE.C_FIFO_TYPE_1}
}

proc update_MODELPARAM_VALUE.C_FIFO_TYPE_2 { MODELPARAM_VALUE.C_FIFO_TYPE_2 PARAM_VALUE.C_FIFO_TYPE_2 } {
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_TYPE_2}] ${MODELPARAM_VALUE.C_FIFO_TYPE_2}
}

proc update_MODELPARAM_VALUE.C_FIFO_TYPE_3 { MODELPARAM_VALUE.C_FIFO_TYPE_3 PARAM_VALUE.C_FIFO_TYPE_3 } {
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_TYPE_3}] ${MODELPARAM_VALUE.C_FIFO_TYPE_3}
}

proc update_MODELPARAM_VALUE.C_FIFO_DEPTH_0 { MODELPARAM_VALUE.C_FIFO_DEPTH_0 PARAM_VALUE.C_FIFO_DEPTH_0 } {
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_DEPTH_0}] ${MODELPARAM_VALUE.C_FIFO_DEPTH_0}
}

proc update_MODELPARAM_VALUE.C_FIFO_DEPTH_1 { MODELPARAM_VALUE.C_FIFO_DEPTH_1 PARAM_VALUE.C_FIFO_DEPTH_1 } {
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_DEPTH_1}] ${MODELPARAM_VALUE.C_FIFO_DEPTH_1}
}

proc update_MODELPARAM_VALUE.C_FIFO_DEPTH_2 { MODELPARAM_VALUE.C_FIFO_DEPTH_2 PARAM_VALUE.C_FIFO_DEPTH_2 } {
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_DEPTH_2}] ${MODELPARAM_VALUE.C_FIFO_DEPTH_2}
}

proc update_MODELPARAM_VALUE.C_FIFO_DEPTH_3 { MODELPARAM_VALUE.C_FIFO_DEPTH_3 PARAM_VALUE.C_FIFO_DEPTH_3 } {
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_DEPTH_3}] ${MODELPARAM_VALUE.C_FIFO_DEPTH_3}
}

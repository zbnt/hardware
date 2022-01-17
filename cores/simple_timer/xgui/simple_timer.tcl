proc init_gui { IPINST } {
	ipgui::add_param $IPINST -name "Component_Name"

	set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
	set axi_width [ipgui::add_param $IPINST -name "axi_width" -parent ${Page_0} -layout horizontal]
	set_property tooltip {Width of the AXI bus, in bits.} ${axi_width}
}

proc update_PARAM_VALUE.axi_width { PARAM_VALUE.axi_width } {}

proc validate_PARAM_VALUE.axi_width { PARAM_VALUE.axi_width } {
	return true
}

proc update_MODELPARAM_VALUE.axi_width { MODELPARAM_VALUE.axi_width PARAM_VALUE.axi_width } {
	set_property value [get_property value ${PARAM_VALUE.axi_width}] ${MODELPARAM_VALUE.axi_width}
}

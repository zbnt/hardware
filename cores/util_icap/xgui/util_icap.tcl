proc init_gui { IPINST } {
	ipgui::add_param $IPINST -name "Component_Name"

	set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
	ipgui::add_param $IPINST -name "C_FAMILY_TYPE" -parent ${Page_0} -widget comboBox
}

proc update_PARAM_VALUE.C_FAMILY_TYPE { PARAM_VALUE.C_FAMILY_TYPE } { }

proc validate_PARAM_VALUE.C_FAMILY_TYPE { PARAM_VALUE.C_FAMILY_TYPE } {
	return true
}

proc update_MODELPARAM_VALUE.C_FAMILY_TYPE { MODELPARAM_VALUE.C_FAMILY_TYPE PARAM_VALUE.C_FAMILY_TYPE } {
	set_property value [get_property value ${PARAM_VALUE.C_FAMILY_TYPE}] ${MODELPARAM_VALUE.C_FAMILY_TYPE}
}

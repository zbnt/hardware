source [file join [file dirname [file dirname [info script]]] xgui/util_startup.gtcl]

proc init_gui { IPINST } {
	ipgui::add_param $IPINST -name "Component_Name"

	set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
	ipgui::add_param $IPINST -name "C_FAMILY_TYPE" -parent ${Page_0} -widget comboBox

	set a [ipgui::add_group $IPINST -name "a" -parent ${Page_0} -display_name {Parameters}]
	set_property tooltip {Parameters} ${a}

	set C_PROG_USR [ipgui::add_param $IPINST -name "C_PROG_USR" -parent ${a} -widget comboBox]
	set_property tooltip {Activate program event security feature} ${C_PROG_USR}

	set C_SIM_CCLK_FREQ [ipgui::add_param $IPINST -name "C_SIM_CCLK_FREQ" -parent ${a}]
	set_property tooltip {CCLK period for simulation, in nanoseconds} ${C_SIM_CCLK_FREQ}

	ipgui::add_param $IPINST -name "C_ENABLE_CLK" -parent ${a}
}

proc update_PARAM_VALUE.C_ENABLE_CLK { PARAM_VALUE.C_ENABLE_CLK PARAM_VALUE.C_FAMILY_TYPE } {
	set C_ENABLE_CLK ${PARAM_VALUE.C_ENABLE_CLK}
	set C_FAMILY_TYPE ${PARAM_VALUE.C_FAMILY_TYPE}
	set values(C_FAMILY_TYPE) [get_property value $C_FAMILY_TYPE]

	if { [gen_USERPARAMETER_C_ENABLE_CLK_ENABLEMENT $values(C_FAMILY_TYPE)] } {
		set_property enabled true $C_ENABLE_CLK
	} else {
		set_property enabled false $C_ENABLE_CLK
	}
}

proc update_PARAM_VALUE.C_FAMILY_TYPE { PARAM_VALUE.C_FAMILY_TYPE } {}
proc update_PARAM_VALUE.C_PROG_USR { PARAM_VALUE.C_PROG_USR } {}
proc update_PARAM_VALUE.C_SIM_CCLK_FREQ { PARAM_VALUE.C_SIM_CCLK_FREQ } {}

proc validate_PARAM_VALUE.C_ENABLE_CLK { PARAM_VALUE.C_ENABLE_CLK } {
	return true
}

proc validate_PARAM_VALUE.C_FAMILY_TYPE { PARAM_VALUE.C_FAMILY_TYPE } {
	return true
}

proc validate_PARAM_VALUE.C_PROG_USR { PARAM_VALUE.C_PROG_USR } {
	return true
}

proc validate_PARAM_VALUE.C_SIM_CCLK_FREQ { PARAM_VALUE.C_SIM_CCLK_FREQ } {
	return true
}

proc update_MODELPARAM_VALUE.C_FAMILY_TYPE { MODELPARAM_VALUE.C_FAMILY_TYPE PARAM_VALUE.C_FAMILY_TYPE } {
	set_property value [get_property value ${PARAM_VALUE.C_FAMILY_TYPE}] ${MODELPARAM_VALUE.C_FAMILY_TYPE}
}

proc update_MODELPARAM_VALUE.C_PROG_USR { MODELPARAM_VALUE.C_PROG_USR PARAM_VALUE.C_PROG_USR } {
	set_property value [get_property value ${PARAM_VALUE.C_PROG_USR}] ${MODELPARAM_VALUE.C_PROG_USR}
}

proc update_MODELPARAM_VALUE.C_SIM_CCLK_FREQ { MODELPARAM_VALUE.C_SIM_CCLK_FREQ PARAM_VALUE.C_SIM_CCLK_FREQ } {
	set_property value [get_property value ${PARAM_VALUE.C_SIM_CCLK_FREQ}] ${MODELPARAM_VALUE.C_SIM_CCLK_FREQ}
}

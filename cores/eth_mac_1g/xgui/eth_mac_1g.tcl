source [file join [file dirname [file dirname [info script]]] xgui/eth_mac_1g.gtcl]

proc init_gui { IPINST } {
	ipgui::add_param $IPINST -name "Component_Name"

	set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
	ipgui::add_param $IPINST -name "C_IFACE_TYPE" -parent ${Page_0} -widget comboBox

	set Interface_options [ipgui::add_group $IPINST -name "Interface options" -parent ${Page_0}]

	set C_CLK_INPUT_STYLE [ipgui::add_param $IPINST -name "C_CLK_INPUT_STYLE" -parent ${Interface_options} -widget comboBox]
	set_property tooltip {Clock buffer for the IDDR instances and the rx_clk output, respectively.} ${C_CLK_INPUT_STYLE}
	ipgui::add_param $IPINST -name "IDELAY_VALUE" -parent ${Interface_options}

	set C_USE_CLK90 [ipgui::add_param $IPINST -name "C_USE_CLK90" -parent ${Interface_options}]
	set_property tooltip {Add a 2ns delay to the TX clock output} ${C_USE_CLK90}
	ipgui::add_param $IPINST -name "C_GTX_AS_RX_CLK" -parent ${Interface_options}
}

proc update_PARAM_VALUE.C_CLK_INPUT_STYLE { PARAM_VALUE.C_CLK_INPUT_STYLE PARAM_VALUE.C_GTX_AS_RX_CLK } {
	set C_CLK_INPUT_STYLE ${PARAM_VALUE.C_CLK_INPUT_STYLE}
	set C_GTX_AS_RX_CLK ${PARAM_VALUE.C_GTX_AS_RX_CLK}
	set values(C_GTX_AS_RX_CLK) [get_property value $C_GTX_AS_RX_CLK]

	if { [gen_USERPARAMETER_C_CLK_INPUT_STYLE_ENABLEMENT $values(C_GTX_AS_RX_CLK)] } {
		set_property enabled true $C_CLK_INPUT_STYLE
	} else {
		set_property enabled false $C_CLK_INPUT_STYLE
	}
}

proc update_PARAM_VALUE.C_GTX_AS_RX_CLK { PARAM_VALUE.C_GTX_AS_RX_CLK PARAM_VALUE.C_IFACE_TYPE } {
	set C_GTX_AS_RX_CLK ${PARAM_VALUE.C_GTX_AS_RX_CLK}
	set C_IFACE_TYPE ${PARAM_VALUE.C_IFACE_TYPE}
	set values(C_IFACE_TYPE) [get_property value $C_IFACE_TYPE]

	if { [gen_USERPARAMETER_C_GTX_AS_RX_CLK_ENABLEMENT $values(C_IFACE_TYPE)] } {
		set_property enabled true $C_GTX_AS_RX_CLK
	} else {
		set_property enabled false $C_GTX_AS_RX_CLK
	}
}

proc update_PARAM_VALUE.C_USE_CLK90 { PARAM_VALUE.C_USE_CLK90 PARAM_VALUE.C_IFACE_TYPE } {
	set C_USE_CLK90 ${PARAM_VALUE.C_USE_CLK90}
	set C_IFACE_TYPE ${PARAM_VALUE.C_IFACE_TYPE}
	set values(C_IFACE_TYPE) [get_property value $C_IFACE_TYPE]

	if { [gen_USERPARAMETER_C_USE_CLK90_ENABLEMENT $values(C_IFACE_TYPE)] } {
		set_property enabled true $C_USE_CLK90
	} else {
		set_property enabled false $C_USE_CLK90
	}
}

proc update_PARAM_VALUE.IDELAY_VALUE { PARAM_VALUE.IDELAY_VALUE PARAM_VALUE.C_IFACE_TYPE } {
	set IDELAY_VALUE ${PARAM_VALUE.IDELAY_VALUE}
	set C_IFACE_TYPE ${PARAM_VALUE.C_IFACE_TYPE}
	set values(C_IFACE_TYPE) [get_property value $C_IFACE_TYPE]

	if { [gen_USERPARAMETER_IDELAY_VALUE_ENABLEMENT $values(C_IFACE_TYPE)] } {
		set_property enabled true $IDELAY_VALUE
	} else {
		set_property enabled false $IDELAY_VALUE
	}
}

proc update_PARAM_VALUE.C_IFACE_TYPE { PARAM_VALUE.C_IFACE_TYPE } {}

proc validate_PARAM_VALUE.C_CLK_INPUT_STYLE { PARAM_VALUE.C_CLK_INPUT_STYLE } {
	return true
}

proc validate_PARAM_VALUE.C_GTX_AS_RX_CLK { PARAM_VALUE.C_GTX_AS_RX_CLK } {
	return true
}

proc validate_PARAM_VALUE.C_USE_CLK90 { PARAM_VALUE.C_USE_CLK90 } {
	return true
}

proc validate_PARAM_VALUE.IDELAY_VALUE { PARAM_VALUE.IDELAY_VALUE } {
	return true
}

proc validate_PARAM_VALUE.C_IFACE_TYPE { PARAM_VALUE.C_IFACE_TYPE } {
	return true
}

proc update_MODELPARAM_VALUE.C_IFACE_TYPE { MODELPARAM_VALUE.C_IFACE_TYPE PARAM_VALUE.C_IFACE_TYPE } {
	set_property value [get_property value ${PARAM_VALUE.C_IFACE_TYPE}] ${MODELPARAM_VALUE.C_IFACE_TYPE}
}

proc update_MODELPARAM_VALUE.C_USE_CLK90 { MODELPARAM_VALUE.C_USE_CLK90 PARAM_VALUE.C_USE_CLK90 } {
	set_property value [get_property value ${PARAM_VALUE.C_USE_CLK90}] ${MODELPARAM_VALUE.C_USE_CLK90}
}

proc update_MODELPARAM_VALUE.C_CLK_INPUT_STYLE { MODELPARAM_VALUE.C_CLK_INPUT_STYLE PARAM_VALUE.C_CLK_INPUT_STYLE } {
	set_property value [get_property value ${PARAM_VALUE.C_CLK_INPUT_STYLE}] ${MODELPARAM_VALUE.C_CLK_INPUT_STYLE}
}

proc update_MODELPARAM_VALUE.C_GTX_AS_RX_CLK { MODELPARAM_VALUE.C_GTX_AS_RX_CLK PARAM_VALUE.C_GTX_AS_RX_CLK } {
	set_property value [get_property value ${PARAM_VALUE.C_GTX_AS_RX_CLK}] ${MODELPARAM_VALUE.C_GTX_AS_RX_CLK}
}

proc update_MODELPARAM_VALUE.IDELAY_VALUE { MODELPARAM_VALUE.IDELAY_VALUE PARAM_VALUE.IDELAY_VALUE } {
	set_property value [get_property value ${PARAM_VALUE.IDELAY_VALUE}] ${MODELPARAM_VALUE.IDELAY_VALUE}
}

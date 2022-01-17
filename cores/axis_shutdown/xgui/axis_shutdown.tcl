source [file join [file dirname [file dirname [info script]]] xgui/axis_shutdown.gtcl]

proc init_gui { IPINST } {
	ipgui::add_param $IPINST -name "Component_Name"

	set Page_0 [ipgui::add_page $IPINST -name "Page 0"]

	set a [ipgui::add_group $IPINST -name "a" -parent ${Page_0} -display_name {Signal availability} -layout horizontal]
	set_property tooltip {Signal availability} ${a}
	ipgui::add_param $IPINST -name "C_AXIS_HAS_TREADY" -parent ${a}
	ipgui::add_param $IPINST -name "C_AXIS_HAS_TLAST" -parent ${a}
	ipgui::add_param $IPINST -name "C_AXIS_HAS_TUSER" -parent ${a}
	ipgui::add_param $IPINST -name "C_AXIS_HAS_TSTRB" -parent ${a}
	ipgui::add_param $IPINST -name "C_AXIS_HAS_TKEEP" -parent ${a}
	ipgui::add_param $IPINST -name "C_AXIS_HAS_TDEST" -parent ${a}
	ipgui::add_param $IPINST -name "C_AXIS_HAS_TID" -parent ${a}

	set Widths [ipgui::add_group $IPINST -name "Widths" -parent ${Page_0} -display_name {Signal width}]
	set_property tooltip {Signal width} ${Widths}
	ipgui::add_param $IPINST -name "C_AXIS_TDATA_WIDTH" -parent ${Widths}
	ipgui::add_param $IPINST -name "C_AXIS_TUSER_WIDTH" -parent ${Widths}
	ipgui::add_param $IPINST -name "C_AXIS_TDEST_WIDTH" -parent ${Widths}
	ipgui::add_param $IPINST -name "C_AXIS_TID_WIDTH" -parent ${Widths}

	set CDC [ipgui::add_group $IPINST -name "CDC" -parent ${Page_0}]
	set_property tooltip {CDC} ${CDC}

	set C_CDC_STAGES [ipgui::add_param $IPINST -name "C_CDC_STAGES" -parent ${CDC}]
	set_property tooltip {Number of CDC stages} ${C_CDC_STAGES}

	set Behavior [ipgui::add_group $IPINST -name "Behavior" -parent ${Page_0}]
	ipgui::add_param $IPINST -name "C_TREADY_IN_SHUTDOWN" -parent ${Behavior}
}

proc update_PARAM_VALUE.C_AXIS_TDEST_WIDTH { PARAM_VALUE.C_AXIS_TDEST_WIDTH PARAM_VALUE.C_AXIS_HAS_TDEST } {
	set C_AXIS_TDEST_WIDTH ${PARAM_VALUE.C_AXIS_TDEST_WIDTH}
	set C_AXIS_HAS_TDEST ${PARAM_VALUE.C_AXIS_HAS_TDEST}
	set values(C_AXIS_HAS_TDEST) [get_property value $C_AXIS_HAS_TDEST]

	if { [gen_USERPARAMETER_C_AXIS_TDEST_WIDTH_ENABLEMENT $values(C_AXIS_HAS_TDEST)] } {
		set_property enabled true $C_AXIS_TDEST_WIDTH
	} else {
		set_property enabled false $C_AXIS_TDEST_WIDTH
	}
}

proc update_PARAM_VALUE.C_AXIS_TID_WIDTH { PARAM_VALUE.C_AXIS_TID_WIDTH PARAM_VALUE.C_AXIS_HAS_TID } {
	set C_AXIS_TID_WIDTH ${PARAM_VALUE.C_AXIS_TID_WIDTH}
	set C_AXIS_HAS_TID ${PARAM_VALUE.C_AXIS_HAS_TID}
	set values(C_AXIS_HAS_TID) [get_property value $C_AXIS_HAS_TID]

	if { [gen_USERPARAMETER_C_AXIS_TID_WIDTH_ENABLEMENT $values(C_AXIS_HAS_TID)] } {
		set_property enabled true $C_AXIS_TID_WIDTH
	} else {
		set_property enabled false $C_AXIS_TID_WIDTH
	}
}

proc update_PARAM_VALUE.C_AXIS_TUSER_WIDTH { PARAM_VALUE.C_AXIS_TUSER_WIDTH PARAM_VALUE.C_AXIS_HAS_TUSER } {
	set C_AXIS_TUSER_WIDTH ${PARAM_VALUE.C_AXIS_TUSER_WIDTH}
	set C_AXIS_HAS_TUSER ${PARAM_VALUE.C_AXIS_HAS_TUSER}
	set values(C_AXIS_HAS_TUSER) [get_property value $C_AXIS_HAS_TUSER]

	if { [gen_USERPARAMETER_C_AXIS_TUSER_WIDTH_ENABLEMENT $values(C_AXIS_HAS_TUSER)] } {
		set_property enabled true $C_AXIS_TUSER_WIDTH
	} else {
		set_property enabled false $C_AXIS_TUSER_WIDTH
	}
}

proc update_PARAM_VALUE.C_AXIS_HAS_TDEST { PARAM_VALUE.C_AXIS_HAS_TDEST } {}
proc update_PARAM_VALUE.C_AXIS_HAS_TID { PARAM_VALUE.C_AXIS_HAS_TID } {}
proc update_PARAM_VALUE.C_AXIS_HAS_TKEEP { PARAM_VALUE.C_AXIS_HAS_TKEEP } {}
proc update_PARAM_VALUE.C_AXIS_HAS_TLAST { PARAM_VALUE.C_AXIS_HAS_TLAST } {}
proc update_PARAM_VALUE.C_AXIS_HAS_TREADY { PARAM_VALUE.C_AXIS_HAS_TREADY } {}
proc update_PARAM_VALUE.C_AXIS_HAS_TSTRB { PARAM_VALUE.C_AXIS_HAS_TSTRB } {}
proc update_PARAM_VALUE.C_AXIS_HAS_TUSER { PARAM_VALUE.C_AXIS_HAS_TUSER } {}
proc update_PARAM_VALUE.C_AXIS_TDATA_WIDTH { PARAM_VALUE.C_AXIS_TDATA_WIDTH } {}
proc update_PARAM_VALUE.C_CDC_STAGES { PARAM_VALUE.C_CDC_STAGES } {}
proc update_PARAM_VALUE.C_TREADY_IN_SHUTDOWN { PARAM_VALUE.C_TREADY_IN_SHUTDOWN } {}

proc validate_PARAM_VALUE.C_AXIS_TDEST_WIDTH { PARAM_VALUE.C_AXIS_TDEST_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_AXIS_TID_WIDTH { PARAM_VALUE.C_AXIS_TID_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_AXIS_TUSER_WIDTH { PARAM_VALUE.C_AXIS_TUSER_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TDEST { PARAM_VALUE.C_AXIS_HAS_TDEST } {
	return true
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TID { PARAM_VALUE.C_AXIS_HAS_TID } {
	return true
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TKEEP { PARAM_VALUE.C_AXIS_HAS_TKEEP } {
	return true
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TLAST { PARAM_VALUE.C_AXIS_HAS_TLAST } {
	return true
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TREADY { PARAM_VALUE.C_AXIS_HAS_TREADY } {
	return true
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TSTRB { PARAM_VALUE.C_AXIS_HAS_TSTRB } {
	return true
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TUSER { PARAM_VALUE.C_AXIS_HAS_TUSER } {
	return true
}

proc validate_PARAM_VALUE.C_AXIS_TDATA_WIDTH { PARAM_VALUE.C_AXIS_TDATA_WIDTH } {
	return true
}

proc validate_PARAM_VALUE.C_CDC_STAGES { PARAM_VALUE.C_CDC_STAGES } {
	return true
}

proc validate_PARAM_VALUE.C_TREADY_IN_SHUTDOWN { PARAM_VALUE.C_TREADY_IN_SHUTDOWN } {
	return true
}

proc update_MODELPARAM_VALUE.C_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_AXIS_TDATA_WIDTH PARAM_VALUE.C_AXIS_TDATA_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_TUSER_WIDTH { MODELPARAM_VALUE.C_AXIS_TUSER_WIDTH PARAM_VALUE.C_AXIS_TUSER_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_TUSER_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_TUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_TDEST_WIDTH { MODELPARAM_VALUE.C_AXIS_TDEST_WIDTH PARAM_VALUE.C_AXIS_TDEST_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_TDEST_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_TDEST_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_TID_WIDTH { MODELPARAM_VALUE.C_AXIS_TID_WIDTH PARAM_VALUE.C_AXIS_TID_WIDTH } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_TID_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_TID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TREADY { MODELPARAM_VALUE.C_AXIS_HAS_TREADY PARAM_VALUE.C_AXIS_HAS_TREADY } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TREADY}] ${MODELPARAM_VALUE.C_AXIS_HAS_TREADY}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TSTRB { MODELPARAM_VALUE.C_AXIS_HAS_TSTRB PARAM_VALUE.C_AXIS_HAS_TSTRB } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TSTRB}] ${MODELPARAM_VALUE.C_AXIS_HAS_TSTRB}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TKEEP { MODELPARAM_VALUE.C_AXIS_HAS_TKEEP PARAM_VALUE.C_AXIS_HAS_TKEEP } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TKEEP}] ${MODELPARAM_VALUE.C_AXIS_HAS_TKEEP}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TLAST { MODELPARAM_VALUE.C_AXIS_HAS_TLAST PARAM_VALUE.C_AXIS_HAS_TLAST } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TLAST}] ${MODELPARAM_VALUE.C_AXIS_HAS_TLAST}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TID { MODELPARAM_VALUE.C_AXIS_HAS_TID PARAM_VALUE.C_AXIS_HAS_TID } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TID}] ${MODELPARAM_VALUE.C_AXIS_HAS_TID}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TDEST { MODELPARAM_VALUE.C_AXIS_HAS_TDEST PARAM_VALUE.C_AXIS_HAS_TDEST } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TDEST}] ${MODELPARAM_VALUE.C_AXIS_HAS_TDEST}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TUSER { MODELPARAM_VALUE.C_AXIS_HAS_TUSER PARAM_VALUE.C_AXIS_HAS_TUSER } {
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TUSER}] ${MODELPARAM_VALUE.C_AXIS_HAS_TUSER}
}

proc update_MODELPARAM_VALUE.C_CDC_STAGES { MODELPARAM_VALUE.C_CDC_STAGES PARAM_VALUE.C_CDC_STAGES } {
	set_property value [get_property value ${PARAM_VALUE.C_CDC_STAGES}] ${MODELPARAM_VALUE.C_CDC_STAGES}
}

proc update_MODELPARAM_VALUE.C_TREADY_IN_SHUTDOWN { MODELPARAM_VALUE.C_TREADY_IN_SHUTDOWN PARAM_VALUE.C_TREADY_IN_SHUTDOWN } {
	set_property value [get_property value ${PARAM_VALUE.C_TREADY_IN_SHUTDOWN}] ${MODELPARAM_VALUE.C_TREADY_IN_SHUTDOWN}
}

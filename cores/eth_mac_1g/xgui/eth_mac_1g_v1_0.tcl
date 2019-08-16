
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/eth_mac_1g_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "family_name" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "iface_type" -parent ${Page_0} -widget comboBox
  set use_clk90 [ipgui::add_param $IPINST -name "use_clk90" -parent ${Page_0}]
  set_property tooltip {Output the TX clock with a 2ns delay} ${use_clk90}


}

proc update_PARAM_VALUE.use_clk90 { PARAM_VALUE.use_clk90 PARAM_VALUE.iface_type } {
	# Procedure called to update use_clk90 when any of the dependent parameters in the arguments change
	
	set use_clk90 ${PARAM_VALUE.use_clk90}
	set iface_type ${PARAM_VALUE.iface_type}
	set values(iface_type) [get_property value $iface_type]
	if { [gen_USERPARAMETER_use_clk90_ENABLEMENT $values(iface_type)] } {
		set_property enabled true $use_clk90
	} else {
		set_property enabled false $use_clk90
	}
}

proc validate_PARAM_VALUE.use_clk90 { PARAM_VALUE.use_clk90 } {
	# Procedure called to validate use_clk90
	return true
}

proc update_PARAM_VALUE.family_name { PARAM_VALUE.family_name } {
	# Procedure called to update family_name when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.family_name { PARAM_VALUE.family_name } {
	# Procedure called to validate family_name
	return true
}

proc update_PARAM_VALUE.iface_type { PARAM_VALUE.iface_type } {
	# Procedure called to update iface_type when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.iface_type { PARAM_VALUE.iface_type } {
	# Procedure called to validate iface_type
	return true
}


proc update_MODELPARAM_VALUE.iface_type { MODELPARAM_VALUE.iface_type PARAM_VALUE.iface_type } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.iface_type}] ${MODELPARAM_VALUE.iface_type}
}

proc update_MODELPARAM_VALUE.family_name { MODELPARAM_VALUE.family_name PARAM_VALUE.family_name } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.family_name}] ${MODELPARAM_VALUE.family_name}
}

proc update_MODELPARAM_VALUE.use_clk90 { MODELPARAM_VALUE.use_clk90 PARAM_VALUE.use_clk90 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.use_clk90}] ${MODELPARAM_VALUE.use_clk90}
}


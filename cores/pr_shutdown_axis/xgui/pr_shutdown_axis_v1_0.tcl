
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/pr_shutdown_axis_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set a [ipgui::add_group $IPINST -name "a" -parent ${Page_0} -display_name {Signal availability} -layout horizontal]
  set_property tooltip {Signal availability} ${a}
  ipgui::add_param $IPINST -name "C_AXIS_HAS_TREADY" -parent ${a}
  ipgui::add_param $IPINST -name "C_AXIS_HAS_TLAST" -parent ${a}
  ipgui::add_param $IPINST -name "C_AXIS_HAS_TUSER" -parent ${a}
  ipgui::add_param $IPINST -name "C_AXIS_HAS_TSTRB" -parent ${a}
  ipgui::add_param $IPINST -name "C_AXIS_HAS_TKEEP" -parent ${a}
  ipgui::add_param $IPINST -name "C_AXIS_HAS_TDEST" -parent ${a}
  ipgui::add_param $IPINST -name "C_AXIS_HAS_TID" -parent ${a}

  #Adding Group
  set Widths [ipgui::add_group $IPINST -name "Widths" -parent ${Page_0} -display_name {Signal width}]
  set_property tooltip {Signal width} ${Widths}
  ipgui::add_param $IPINST -name "C_AXIS_TDATA_WIDTH" -parent ${Widths}
  ipgui::add_param $IPINST -name "C_AXIS_TUSER_WIDTH" -parent ${Widths}
  ipgui::add_param $IPINST -name "C_AXIS_TDEST_WIDTH" -parent ${Widths}
  ipgui::add_param $IPINST -name "C_AXIS_TID_WIDTH" -parent ${Widths}

  #Adding Group
  set CDC [ipgui::add_group $IPINST -name "CDC" -parent ${Page_0}]
  set_property tooltip {CDC} ${CDC}
  set C_CDC_STAGES [ipgui::add_param $IPINST -name "C_CDC_STAGES" -parent ${CDC}]
  set_property tooltip {Number of CDC stages} ${C_CDC_STAGES}



}

proc update_PARAM_VALUE.C_AXIS_TDEST_WIDTH { PARAM_VALUE.C_AXIS_TDEST_WIDTH PARAM_VALUE.C_AXIS_HAS_TDEST } {
	# Procedure called to update C_AXIS_TDEST_WIDTH when any of the dependent parameters in the arguments change
	
	set C_AXIS_TDEST_WIDTH ${PARAM_VALUE.C_AXIS_TDEST_WIDTH}
	set C_AXIS_HAS_TDEST ${PARAM_VALUE.C_AXIS_HAS_TDEST}
	set values(C_AXIS_HAS_TDEST) [get_property value $C_AXIS_HAS_TDEST]
	if { [gen_USERPARAMETER_C_AXIS_TDEST_WIDTH_ENABLEMENT $values(C_AXIS_HAS_TDEST)] } {
		set_property enabled true $C_AXIS_TDEST_WIDTH
	} else {
		set_property enabled false $C_AXIS_TDEST_WIDTH
	}
}

proc validate_PARAM_VALUE.C_AXIS_TDEST_WIDTH { PARAM_VALUE.C_AXIS_TDEST_WIDTH } {
	# Procedure called to validate C_AXIS_TDEST_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_TID_WIDTH { PARAM_VALUE.C_AXIS_TID_WIDTH PARAM_VALUE.C_AXIS_HAS_TID } {
	# Procedure called to update C_AXIS_TID_WIDTH when any of the dependent parameters in the arguments change
	
	set C_AXIS_TID_WIDTH ${PARAM_VALUE.C_AXIS_TID_WIDTH}
	set C_AXIS_HAS_TID ${PARAM_VALUE.C_AXIS_HAS_TID}
	set values(C_AXIS_HAS_TID) [get_property value $C_AXIS_HAS_TID]
	if { [gen_USERPARAMETER_C_AXIS_TID_WIDTH_ENABLEMENT $values(C_AXIS_HAS_TID)] } {
		set_property enabled true $C_AXIS_TID_WIDTH
	} else {
		set_property enabled false $C_AXIS_TID_WIDTH
	}
}

proc validate_PARAM_VALUE.C_AXIS_TID_WIDTH { PARAM_VALUE.C_AXIS_TID_WIDTH } {
	# Procedure called to validate C_AXIS_TID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_TUSER_WIDTH { PARAM_VALUE.C_AXIS_TUSER_WIDTH PARAM_VALUE.C_AXIS_HAS_TUSER } {
	# Procedure called to update C_AXIS_TUSER_WIDTH when any of the dependent parameters in the arguments change
	
	set C_AXIS_TUSER_WIDTH ${PARAM_VALUE.C_AXIS_TUSER_WIDTH}
	set C_AXIS_HAS_TUSER ${PARAM_VALUE.C_AXIS_HAS_TUSER}
	set values(C_AXIS_HAS_TUSER) [get_property value $C_AXIS_HAS_TUSER]
	if { [gen_USERPARAMETER_C_AXIS_TUSER_WIDTH_ENABLEMENT $values(C_AXIS_HAS_TUSER)] } {
		set_property enabled true $C_AXIS_TUSER_WIDTH
	} else {
		set_property enabled false $C_AXIS_TUSER_WIDTH
	}
}

proc validate_PARAM_VALUE.C_AXIS_TUSER_WIDTH { PARAM_VALUE.C_AXIS_TUSER_WIDTH } {
	# Procedure called to validate C_AXIS_TUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_HAS_TDEST { PARAM_VALUE.C_AXIS_HAS_TDEST } {
	# Procedure called to update C_AXIS_HAS_TDEST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TDEST { PARAM_VALUE.C_AXIS_HAS_TDEST } {
	# Procedure called to validate C_AXIS_HAS_TDEST
	return true
}

proc update_PARAM_VALUE.C_AXIS_HAS_TID { PARAM_VALUE.C_AXIS_HAS_TID } {
	# Procedure called to update C_AXIS_HAS_TID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TID { PARAM_VALUE.C_AXIS_HAS_TID } {
	# Procedure called to validate C_AXIS_HAS_TID
	return true
}

proc update_PARAM_VALUE.C_AXIS_HAS_TKEEP { PARAM_VALUE.C_AXIS_HAS_TKEEP } {
	# Procedure called to update C_AXIS_HAS_TKEEP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TKEEP { PARAM_VALUE.C_AXIS_HAS_TKEEP } {
	# Procedure called to validate C_AXIS_HAS_TKEEP
	return true
}

proc update_PARAM_VALUE.C_AXIS_HAS_TLAST { PARAM_VALUE.C_AXIS_HAS_TLAST } {
	# Procedure called to update C_AXIS_HAS_TLAST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TLAST { PARAM_VALUE.C_AXIS_HAS_TLAST } {
	# Procedure called to validate C_AXIS_HAS_TLAST
	return true
}

proc update_PARAM_VALUE.C_AXIS_HAS_TREADY { PARAM_VALUE.C_AXIS_HAS_TREADY } {
	# Procedure called to update C_AXIS_HAS_TREADY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TREADY { PARAM_VALUE.C_AXIS_HAS_TREADY } {
	# Procedure called to validate C_AXIS_HAS_TREADY
	return true
}

proc update_PARAM_VALUE.C_AXIS_HAS_TSTRB { PARAM_VALUE.C_AXIS_HAS_TSTRB } {
	# Procedure called to update C_AXIS_HAS_TSTRB when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TSTRB { PARAM_VALUE.C_AXIS_HAS_TSTRB } {
	# Procedure called to validate C_AXIS_HAS_TSTRB
	return true
}

proc update_PARAM_VALUE.C_AXIS_HAS_TUSER { PARAM_VALUE.C_AXIS_HAS_TUSER } {
	# Procedure called to update C_AXIS_HAS_TUSER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_HAS_TUSER { PARAM_VALUE.C_AXIS_HAS_TUSER } {
	# Procedure called to validate C_AXIS_HAS_TUSER
	return true
}

proc update_PARAM_VALUE.C_AXIS_TDATA_WIDTH { PARAM_VALUE.C_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_TDATA_WIDTH { PARAM_VALUE.C_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_CDC_STAGES { PARAM_VALUE.C_CDC_STAGES } {
	# Procedure called to update C_CDC_STAGES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CDC_STAGES { PARAM_VALUE.C_CDC_STAGES } {
	# Procedure called to validate C_CDC_STAGES
	return true
}


proc update_MODELPARAM_VALUE.C_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_AXIS_TDATA_WIDTH PARAM_VALUE.C_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_TUSER_WIDTH { MODELPARAM_VALUE.C_AXIS_TUSER_WIDTH PARAM_VALUE.C_AXIS_TUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_TUSER_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_TUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_TDEST_WIDTH { MODELPARAM_VALUE.C_AXIS_TDEST_WIDTH PARAM_VALUE.C_AXIS_TDEST_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_TDEST_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_TDEST_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_TID_WIDTH { MODELPARAM_VALUE.C_AXIS_TID_WIDTH PARAM_VALUE.C_AXIS_TID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_TID_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_TID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TREADY { MODELPARAM_VALUE.C_AXIS_HAS_TREADY PARAM_VALUE.C_AXIS_HAS_TREADY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TREADY}] ${MODELPARAM_VALUE.C_AXIS_HAS_TREADY}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TSTRB { MODELPARAM_VALUE.C_AXIS_HAS_TSTRB PARAM_VALUE.C_AXIS_HAS_TSTRB } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TSTRB}] ${MODELPARAM_VALUE.C_AXIS_HAS_TSTRB}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TKEEP { MODELPARAM_VALUE.C_AXIS_HAS_TKEEP PARAM_VALUE.C_AXIS_HAS_TKEEP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TKEEP}] ${MODELPARAM_VALUE.C_AXIS_HAS_TKEEP}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TLAST { MODELPARAM_VALUE.C_AXIS_HAS_TLAST PARAM_VALUE.C_AXIS_HAS_TLAST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TLAST}] ${MODELPARAM_VALUE.C_AXIS_HAS_TLAST}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TID { MODELPARAM_VALUE.C_AXIS_HAS_TID PARAM_VALUE.C_AXIS_HAS_TID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TID}] ${MODELPARAM_VALUE.C_AXIS_HAS_TID}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TDEST { MODELPARAM_VALUE.C_AXIS_HAS_TDEST PARAM_VALUE.C_AXIS_HAS_TDEST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TDEST}] ${MODELPARAM_VALUE.C_AXIS_HAS_TDEST}
}

proc update_MODELPARAM_VALUE.C_AXIS_HAS_TUSER { MODELPARAM_VALUE.C_AXIS_HAS_TUSER PARAM_VALUE.C_AXIS_HAS_TUSER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_HAS_TUSER}] ${MODELPARAM_VALUE.C_AXIS_HAS_TUSER}
}

proc update_MODELPARAM_VALUE.C_CDC_STAGES { MODELPARAM_VALUE.C_CDC_STAGES PARAM_VALUE.C_CDC_STAGES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CDC_STAGES}] ${MODELPARAM_VALUE.C_CDC_STAGES}
}


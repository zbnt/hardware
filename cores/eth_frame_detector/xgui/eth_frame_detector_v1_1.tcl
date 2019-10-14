# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_AXI_WIDTH [ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${Page_0} -layout horizontal]
  set_property tooltip {Width of the AXI bus, in bits.} ${C_AXI_WIDTH}
  #Adding Group
  set FIFO_Sizes [ipgui::add_group $IPINST -name "FIFO Sizes" -parent ${Page_0}]
  set C_LOG_FIFO_SIZE [ipgui::add_param $IPINST -name "C_LOG_FIFO_SIZE" -parent ${FIFO_Sizes} -widget comboBox]
  set_property tooltip {Maximum number of entries that can be stored in the detection log FIFO} ${C_LOG_FIFO_SIZE}
  set C_LOOP_FIFO_SIZE [ipgui::add_param $IPINST -name "C_LOOP_FIFO_SIZE" -parent ${FIFO_Sizes} -widget comboBox]
  set_property tooltip {Maximum number of bytes that can be stored in the frame loop FIFO} ${C_LOOP_FIFO_SIZE}



}

proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to update C_AXI_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to validate C_AXI_WIDTH
	return true
}

proc update_PARAM_VALUE.C_LOG_FIFO_SIZE { PARAM_VALUE.C_LOG_FIFO_SIZE } {
	# Procedure called to update C_LOG_FIFO_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LOG_FIFO_SIZE { PARAM_VALUE.C_LOG_FIFO_SIZE } {
	# Procedure called to validate C_LOG_FIFO_SIZE
	return true
}

proc update_PARAM_VALUE.C_LOOP_FIFO_SIZE { PARAM_VALUE.C_LOOP_FIFO_SIZE } {
	# Procedure called to update C_LOOP_FIFO_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LOOP_FIFO_SIZE { PARAM_VALUE.C_LOOP_FIFO_SIZE } {
	# Procedure called to validate C_LOOP_FIFO_SIZE
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_WIDTH { MODELPARAM_VALUE.C_AXI_WIDTH PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WIDTH}] ${MODELPARAM_VALUE.C_AXI_WIDTH}
}

proc update_MODELPARAM_VALUE.C_LOG_FIFO_SIZE { MODELPARAM_VALUE.C_LOG_FIFO_SIZE PARAM_VALUE.C_LOG_FIFO_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LOG_FIFO_SIZE}] ${MODELPARAM_VALUE.C_LOG_FIFO_SIZE}
}

proc update_MODELPARAM_VALUE.C_LOOP_FIFO_SIZE { MODELPARAM_VALUE.C_LOOP_FIFO_SIZE PARAM_VALUE.C_LOOP_FIFO_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LOOP_FIFO_SIZE}] ${MODELPARAM_VALUE.C_LOOP_FIFO_SIZE}
}


# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_AXI_WIDTH [ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${Page_0} -layout horizontal]
  set_property tooltip {Width of the AXI bus, in bits.} ${C_AXI_WIDTH}
  #Adding Group
  set DMA_Options [ipgui::add_group $IPINST -name "DMA Options" -parent ${Page_0}]
  set C_AXIS_WIDTH [ipgui::add_param $IPINST -name "C_AXIS_WIDTH" -parent ${DMA_Options} -widget comboBox]
  set_property tooltip {Width of the AXIS interface, in bits.} ${C_AXIS_WIDTH}
  set C_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_ADDR_WIDTH" -parent ${DMA_Options} -widget comboBox]
  set_property tooltip {Width of the memory addresses, in bits.} ${C_ADDR_WIDTH}
  ipgui::add_param $IPINST -name "C_MAX_BURST" -parent ${DMA_Options} -widget comboBox



}

proc update_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to update C_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to validate C_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_WIDTH { PARAM_VALUE.C_AXIS_WIDTH } {
	# Procedure called to update C_AXIS_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_WIDTH { PARAM_VALUE.C_AXIS_WIDTH } {
	# Procedure called to validate C_AXIS_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to update C_AXI_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to validate C_AXI_WIDTH
	return true
}

proc update_PARAM_VALUE.C_MAX_BURST { PARAM_VALUE.C_MAX_BURST } {
	# Procedure called to update C_MAX_BURST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MAX_BURST { PARAM_VALUE.C_MAX_BURST } {
	# Procedure called to validate C_MAX_BURST
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_WIDTH { MODELPARAM_VALUE.C_AXI_WIDTH PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WIDTH}] ${MODELPARAM_VALUE.C_AXI_WIDTH}
}

proc update_MODELPARAM_VALUE.C_ADDR_WIDTH { MODELPARAM_VALUE.C_ADDR_WIDTH PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_WIDTH { MODELPARAM_VALUE.C_AXIS_WIDTH PARAM_VALUE.C_AXIS_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_WIDTH}
}

proc update_MODELPARAM_VALUE.C_MAX_BURST { MODELPARAM_VALUE.C_MAX_BURST PARAM_VALUE.C_MAX_BURST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_BURST}] ${MODELPARAM_VALUE.C_MAX_BURST}
}


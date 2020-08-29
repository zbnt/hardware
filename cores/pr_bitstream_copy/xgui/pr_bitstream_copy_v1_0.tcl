# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set AXI [ipgui::add_group $IPINST -name "AXI" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${AXI} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_ADDR_WIDTH" -parent ${AXI}
  ipgui::add_param $IPINST -name "C_SOURCE_ADDR" -parent ${AXI}
  ipgui::add_param $IPINST -name "C_DESTINATION_ADDR" -parent ${AXI}
  set C_MEMORY_SIZE [ipgui::add_param $IPINST -name "C_MEMORY_SIZE" -parent ${AXI}]
  set_property tooltip {Memory size, in bytes} ${C_MEMORY_SIZE}



}

proc update_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to update C_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to update C_AXI_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to validate C_AXI_WIDTH
	return true
}

proc update_PARAM_VALUE.C_DESTINATION_ADDR { PARAM_VALUE.C_DESTINATION_ADDR } {
	# Procedure called to update C_DESTINATION_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DESTINATION_ADDR { PARAM_VALUE.C_DESTINATION_ADDR } {
	# Procedure called to validate C_DESTINATION_ADDR
	return true
}

proc update_PARAM_VALUE.C_MEMORY_SIZE { PARAM_VALUE.C_MEMORY_SIZE } {
	# Procedure called to update C_MEMORY_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MEMORY_SIZE { PARAM_VALUE.C_MEMORY_SIZE } {
	# Procedure called to validate C_MEMORY_SIZE
	return true
}

proc update_PARAM_VALUE.C_SOURCE_ADDR { PARAM_VALUE.C_SOURCE_ADDR } {
	# Procedure called to update C_SOURCE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SOURCE_ADDR { PARAM_VALUE.C_SOURCE_ADDR } {
	# Procedure called to validate C_SOURCE_ADDR
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_WIDTH { MODELPARAM_VALUE.C_AXI_WIDTH PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WIDTH}] ${MODELPARAM_VALUE.C_AXI_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_ADDR_WIDTH PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_SOURCE_ADDR { MODELPARAM_VALUE.C_SOURCE_ADDR PARAM_VALUE.C_SOURCE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SOURCE_ADDR}] ${MODELPARAM_VALUE.C_SOURCE_ADDR}
}

proc update_MODELPARAM_VALUE.C_DESTINATION_ADDR { MODELPARAM_VALUE.C_DESTINATION_ADDR PARAM_VALUE.C_DESTINATION_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DESTINATION_ADDR}] ${MODELPARAM_VALUE.C_DESTINATION_ADDR}
}

proc update_MODELPARAM_VALUE.C_MEMORY_SIZE { MODELPARAM_VALUE.C_MEMORY_SIZE PARAM_VALUE.C_MEMORY_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MEMORY_SIZE}] ${MODELPARAM_VALUE.C_MEMORY_SIZE}
}


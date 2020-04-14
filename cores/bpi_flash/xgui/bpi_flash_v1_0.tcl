# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_INTERNAL_IOBUF" -parent ${Page_0}
  #Adding Group
  set AXI [ipgui::add_group $IPINST -name "AXI" -parent ${Page_0}]
  set C_AXI_WIDTH [ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${AXI} -widget comboBox]
  set_property tooltip {Width of the AXI bus, in bits.} ${C_AXI_WIDTH}

  #Adding Group
  set Memory [ipgui::add_group $IPINST -name "Memory" -parent ${Page_0}]
  set C_MEM_WIDTH [ipgui::add_param $IPINST -name "C_MEM_WIDTH" -parent ${Memory} -widget comboBox]
  set_property tooltip {Width of the memory data, in bits} ${C_MEM_WIDTH}
  set C_MEM_SIZE [ipgui::add_param $IPINST -name "C_MEM_SIZE" -parent ${Memory} -widget comboBox]
  set_property tooltip {Size of the memory, in bytes} ${C_MEM_SIZE}

  #Adding Group
  set Timing [ipgui::add_group $IPINST -name "Timing" -parent ${Page_0}]
  set C_ADDR_TO_CEL_TIME [ipgui::add_param $IPINST -name "C_ADDR_TO_CEL_TIME" -parent ${Timing}]
  set_property tooltip {Number of clock cycles between ADDR valid and CE_N low} ${C_ADDR_TO_CEL_TIME}
  set C_OEH_TO_DONE_TIME [ipgui::add_param $IPINST -name "C_OEH_TO_DONE_TIME" -parent ${Timing}]
  set_property tooltip {Number of clock cycles between OE_N high and DONE high} ${C_OEH_TO_DONE_TIME}
  #Adding Group
  set Read [ipgui::add_group $IPINST -name "Read" -parent ${Timing}]
  set C_OEL_TO_OEH_TIME [ipgui::add_param $IPINST -name "C_OEL_TO_OEH_TIME" -parent ${Read}]
  set_property tooltip {Number of clock cycles between OE_N low and OE_N high} ${C_OEL_TO_OEH_TIME}

  #Adding Group
  set Write [ipgui::add_group $IPINST -name "Write" -parent ${Timing}]
  set C_WEL_TO_DQ_TIME [ipgui::add_param $IPINST -name "C_WEL_TO_DQ_TIME" -parent ${Write}]
  set_property tooltip {Number of clock cycles between WE_N low and DQ output} ${C_WEL_TO_DQ_TIME}
  set C_DQ_TO_WEH_TIME [ipgui::add_param $IPINST -name "C_DQ_TO_WEH_TIME" -parent ${Write}]
  set_property tooltip {Number of clock cycles between DQ output and WE_N high} ${C_DQ_TO_WEH_TIME}




}

proc update_PARAM_VALUE.C_ADDR_TO_CEL_TIME { PARAM_VALUE.C_ADDR_TO_CEL_TIME } {
	# Procedure called to update C_ADDR_TO_CEL_TIME when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_TO_CEL_TIME { PARAM_VALUE.C_ADDR_TO_CEL_TIME } {
	# Procedure called to validate C_ADDR_TO_CEL_TIME
	return true
}

proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to update C_AXI_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to validate C_AXI_WIDTH
	return true
}

proc update_PARAM_VALUE.C_DQ_TO_WEH_TIME { PARAM_VALUE.C_DQ_TO_WEH_TIME } {
	# Procedure called to update C_DQ_TO_WEH_TIME when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DQ_TO_WEH_TIME { PARAM_VALUE.C_DQ_TO_WEH_TIME } {
	# Procedure called to validate C_DQ_TO_WEH_TIME
	return true
}

proc update_PARAM_VALUE.C_INTERNAL_IOBUF { PARAM_VALUE.C_INTERNAL_IOBUF } {
	# Procedure called to update C_INTERNAL_IOBUF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_INTERNAL_IOBUF { PARAM_VALUE.C_INTERNAL_IOBUF } {
	# Procedure called to validate C_INTERNAL_IOBUF
	return true
}

proc update_PARAM_VALUE.C_MEM_SIZE { PARAM_VALUE.C_MEM_SIZE } {
	# Procedure called to update C_MEM_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MEM_SIZE { PARAM_VALUE.C_MEM_SIZE } {
	# Procedure called to validate C_MEM_SIZE
	return true
}

proc update_PARAM_VALUE.C_MEM_WIDTH { PARAM_VALUE.C_MEM_WIDTH } {
	# Procedure called to update C_MEM_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MEM_WIDTH { PARAM_VALUE.C_MEM_WIDTH } {
	# Procedure called to validate C_MEM_WIDTH
	return true
}

proc update_PARAM_VALUE.C_OEH_TO_DONE_TIME { PARAM_VALUE.C_OEH_TO_DONE_TIME } {
	# Procedure called to update C_OEH_TO_DONE_TIME when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OEH_TO_DONE_TIME { PARAM_VALUE.C_OEH_TO_DONE_TIME } {
	# Procedure called to validate C_OEH_TO_DONE_TIME
	return true
}

proc update_PARAM_VALUE.C_OEL_TO_OEH_TIME { PARAM_VALUE.C_OEL_TO_OEH_TIME } {
	# Procedure called to update C_OEL_TO_OEH_TIME when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OEL_TO_OEH_TIME { PARAM_VALUE.C_OEL_TO_OEH_TIME } {
	# Procedure called to validate C_OEL_TO_OEH_TIME
	return true
}

proc update_PARAM_VALUE.C_WEL_TO_DQ_TIME { PARAM_VALUE.C_WEL_TO_DQ_TIME } {
	# Procedure called to update C_WEL_TO_DQ_TIME when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_WEL_TO_DQ_TIME { PARAM_VALUE.C_WEL_TO_DQ_TIME } {
	# Procedure called to validate C_WEL_TO_DQ_TIME
	return true
}


proc update_MODELPARAM_VALUE.C_MEM_WIDTH { MODELPARAM_VALUE.C_MEM_WIDTH PARAM_VALUE.C_MEM_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MEM_WIDTH}] ${MODELPARAM_VALUE.C_MEM_WIDTH}
}

proc update_MODELPARAM_VALUE.C_MEM_SIZE { MODELPARAM_VALUE.C_MEM_SIZE PARAM_VALUE.C_MEM_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MEM_SIZE}] ${MODELPARAM_VALUE.C_MEM_SIZE}
}

proc update_MODELPARAM_VALUE.C_INTERNAL_IOBUF { MODELPARAM_VALUE.C_INTERNAL_IOBUF PARAM_VALUE.C_INTERNAL_IOBUF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_INTERNAL_IOBUF}] ${MODELPARAM_VALUE.C_INTERNAL_IOBUF}
}

proc update_MODELPARAM_VALUE.C_AXI_WIDTH { MODELPARAM_VALUE.C_AXI_WIDTH PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WIDTH}] ${MODELPARAM_VALUE.C_AXI_WIDTH}
}

proc update_MODELPARAM_VALUE.C_ADDR_TO_CEL_TIME { MODELPARAM_VALUE.C_ADDR_TO_CEL_TIME PARAM_VALUE.C_ADDR_TO_CEL_TIME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_TO_CEL_TIME}] ${MODELPARAM_VALUE.C_ADDR_TO_CEL_TIME}
}

proc update_MODELPARAM_VALUE.C_OEL_TO_OEH_TIME { MODELPARAM_VALUE.C_OEL_TO_OEH_TIME PARAM_VALUE.C_OEL_TO_OEH_TIME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OEL_TO_OEH_TIME}] ${MODELPARAM_VALUE.C_OEL_TO_OEH_TIME}
}

proc update_MODELPARAM_VALUE.C_WEL_TO_DQ_TIME { MODELPARAM_VALUE.C_WEL_TO_DQ_TIME PARAM_VALUE.C_WEL_TO_DQ_TIME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_WEL_TO_DQ_TIME}] ${MODELPARAM_VALUE.C_WEL_TO_DQ_TIME}
}

proc update_MODELPARAM_VALUE.C_DQ_TO_WEH_TIME { MODELPARAM_VALUE.C_DQ_TO_WEH_TIME PARAM_VALUE.C_DQ_TO_WEH_TIME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DQ_TO_WEH_TIME}] ${MODELPARAM_VALUE.C_DQ_TO_WEH_TIME}
}

proc update_MODELPARAM_VALUE.C_OEH_TO_DONE_TIME { MODELPARAM_VALUE.C_OEH_TO_DONE_TIME PARAM_VALUE.C_OEH_TO_DONE_TIME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OEH_TO_DONE_TIME}] ${MODELPARAM_VALUE.C_OEH_TO_DONE_TIME}
}


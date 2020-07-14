# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set AXI [ipgui::add_group $IPINST -name "AXI" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "C_AXI_ADDR_WIDTH" -parent ${AXI} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${AXI} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_MAX_BURST" -parent ${AXI}
  ipgui::add_param $IPINST -name "C_VALUE_ARCACHE" -parent ${AXI}
  ipgui::add_param $IPINST -name "C_VALUE_ARUSER" -parent ${AXI}
  ipgui::add_param $IPINST -name "C_VALUE_ARPROT" -parent ${AXI}

  #Adding Group
  set FIFO [ipgui::add_group $IPINST -name "FIFO" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "C_FIFO_TYPE" -parent ${FIFO} -widget comboBox
  ipgui::add_param $IPINST -name "C_FIFO_SIZE" -parent ${FIFO}



}

proc update_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to update C_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_MAX_BURST { PARAM_VALUE.C_AXI_MAX_BURST } {
	# Procedure called to update C_AXI_MAX_BURST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_MAX_BURST { PARAM_VALUE.C_AXI_MAX_BURST } {
	# Procedure called to validate C_AXI_MAX_BURST
	return true
}

proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to update C_AXI_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to validate C_AXI_WIDTH
	return true
}

proc update_PARAM_VALUE.C_FIFO_SIZE { PARAM_VALUE.C_FIFO_SIZE } {
	# Procedure called to update C_FIFO_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIFO_SIZE { PARAM_VALUE.C_FIFO_SIZE } {
	# Procedure called to validate C_FIFO_SIZE
	return true
}

proc update_PARAM_VALUE.C_FIFO_TYPE { PARAM_VALUE.C_FIFO_TYPE } {
	# Procedure called to update C_FIFO_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIFO_TYPE { PARAM_VALUE.C_FIFO_TYPE } {
	# Procedure called to validate C_FIFO_TYPE
	return true
}

proc update_PARAM_VALUE.C_VALUE_ARCACHE { PARAM_VALUE.C_VALUE_ARCACHE } {
	# Procedure called to update C_VALUE_ARCACHE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VALUE_ARCACHE { PARAM_VALUE.C_VALUE_ARCACHE } {
	# Procedure called to validate C_VALUE_ARCACHE
	return true
}

proc update_PARAM_VALUE.C_VALUE_ARPROT { PARAM_VALUE.C_VALUE_ARPROT } {
	# Procedure called to update C_VALUE_ARPROT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VALUE_ARPROT { PARAM_VALUE.C_VALUE_ARPROT } {
	# Procedure called to validate C_VALUE_ARPROT
	return true
}

proc update_PARAM_VALUE.C_VALUE_ARUSER { PARAM_VALUE.C_VALUE_ARUSER } {
	# Procedure called to update C_VALUE_ARUSER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VALUE_ARUSER { PARAM_VALUE.C_VALUE_ARUSER } {
	# Procedure called to validate C_VALUE_ARUSER
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

proc update_MODELPARAM_VALUE.C_AXI_MAX_BURST { MODELPARAM_VALUE.C_AXI_MAX_BURST PARAM_VALUE.C_AXI_MAX_BURST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_MAX_BURST}] ${MODELPARAM_VALUE.C_AXI_MAX_BURST}
}

proc update_MODELPARAM_VALUE.C_FIFO_SIZE { MODELPARAM_VALUE.C_FIFO_SIZE PARAM_VALUE.C_FIFO_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_SIZE}] ${MODELPARAM_VALUE.C_FIFO_SIZE}
}

proc update_MODELPARAM_VALUE.C_FIFO_TYPE { MODELPARAM_VALUE.C_FIFO_TYPE PARAM_VALUE.C_FIFO_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_TYPE}] ${MODELPARAM_VALUE.C_FIFO_TYPE}
}

proc update_MODELPARAM_VALUE.C_VALUE_ARPROT { MODELPARAM_VALUE.C_VALUE_ARPROT PARAM_VALUE.C_VALUE_ARPROT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VALUE_ARPROT}] ${MODELPARAM_VALUE.C_VALUE_ARPROT}
}

proc update_MODELPARAM_VALUE.C_VALUE_ARCACHE { MODELPARAM_VALUE.C_VALUE_ARCACHE PARAM_VALUE.C_VALUE_ARCACHE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VALUE_ARCACHE}] ${MODELPARAM_VALUE.C_VALUE_ARCACHE}
}

proc update_MODELPARAM_VALUE.C_VALUE_ARUSER { MODELPARAM_VALUE.C_VALUE_ARUSER PARAM_VALUE.C_VALUE_ARUSER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VALUE_ARUSER}] ${MODELPARAM_VALUE.C_VALUE_ARUSER}
}


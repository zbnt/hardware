# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_AXI_WIDTH [ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${Page_0} -layout horizontal]
  set_property tooltip {Width of the AXI bus, in bits.} ${C_AXI_WIDTH}
  #Adding Group
  set Other_options [ipgui::add_group $IPINST -name "Other options" -parent ${Page_0}]
  set C_ENABLE_FIFO [ipgui::add_param $IPINST -name "C_ENABLE_FIFO" -parent ${Other_options}]
  set_property tooltip {Use a FIFO for storing statistics.} ${C_ENABLE_FIFO}
  set C_USE_TIMER [ipgui::add_param $IPINST -name "C_USE_TIMER" -parent ${Other_options}]
  set_property tooltip {Use a reference 64 bit timer for keeping track of time. If enabled, statistics will be collected only if the timer is running.} ${C_USE_TIMER}
  set C_SHARED_TX_CLK [ipgui::add_param $IPINST -name "C_SHARED_TX_CLK" -parent ${Other_options}]
  set_property tooltip {Enable if S_AXI and AXIS_TX are part of the same clock domain.} ${C_SHARED_TX_CLK}



}

proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to update C_AXI_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to validate C_AXI_WIDTH
	return true
}

proc update_PARAM_VALUE.C_ENABLE_FIFO { PARAM_VALUE.C_ENABLE_FIFO } {
	# Procedure called to update C_ENABLE_FIFO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ENABLE_FIFO { PARAM_VALUE.C_ENABLE_FIFO } {
	# Procedure called to validate C_ENABLE_FIFO
	return true
}

proc update_PARAM_VALUE.C_SHARED_TX_CLK { PARAM_VALUE.C_SHARED_TX_CLK } {
	# Procedure called to update C_SHARED_TX_CLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SHARED_TX_CLK { PARAM_VALUE.C_SHARED_TX_CLK } {
	# Procedure called to validate C_SHARED_TX_CLK
	return true
}

proc update_PARAM_VALUE.C_USE_TIMER { PARAM_VALUE.C_USE_TIMER } {
	# Procedure called to update C_USE_TIMER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_USE_TIMER { PARAM_VALUE.C_USE_TIMER } {
	# Procedure called to validate C_USE_TIMER
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_WIDTH { MODELPARAM_VALUE.C_AXI_WIDTH PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WIDTH}] ${MODELPARAM_VALUE.C_AXI_WIDTH}
}

proc update_MODELPARAM_VALUE.C_USE_TIMER { MODELPARAM_VALUE.C_USE_TIMER PARAM_VALUE.C_USE_TIMER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_USE_TIMER}] ${MODELPARAM_VALUE.C_USE_TIMER}
}

proc update_MODELPARAM_VALUE.C_ENABLE_FIFO { MODELPARAM_VALUE.C_ENABLE_FIFO PARAM_VALUE.C_ENABLE_FIFO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ENABLE_FIFO}] ${MODELPARAM_VALUE.C_ENABLE_FIFO}
}

proc update_MODELPARAM_VALUE.C_SHARED_TX_CLK { MODELPARAM_VALUE.C_SHARED_TX_CLK PARAM_VALUE.C_SHARED_TX_CLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SHARED_TX_CLK}] ${MODELPARAM_VALUE.C_SHARED_TX_CLK}
}


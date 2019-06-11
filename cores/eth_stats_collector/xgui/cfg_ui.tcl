# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set use_time [ipgui::add_param $IPINST -name "use_time" -parent ${Page_0}]
  set_property tooltip {Enables the use of a reference 64 bit timer for keeping track of time. If enabled, statistics will be collected only if the timer is running.} ${use_time}
  set use_fifo [ipgui::add_param $IPINST -name "use_fifo" -parent ${Page_0}]
  set_property tooltip {Enables the use of a FIFO for storing statistics.} ${use_fifo}


}

proc update_PARAM_VALUE.use_fifo { PARAM_VALUE.use_fifo } {
	# Procedure called to update use_fifo when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.use_fifo { PARAM_VALUE.use_fifo } {
	# Procedure called to validate use_fifo
	return true
}

proc update_PARAM_VALUE.use_time { PARAM_VALUE.use_time } {
	# Procedure called to update use_time when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.use_time { PARAM_VALUE.use_time } {
	# Procedure called to validate use_time
	return true
}


proc update_MODELPARAM_VALUE.use_time { MODELPARAM_VALUE.use_time PARAM_VALUE.use_time } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.use_time}] ${MODELPARAM_VALUE.use_time}
}

proc update_MODELPARAM_VALUE.use_fifo { MODELPARAM_VALUE.use_fifo PARAM_VALUE.use_fifo } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.use_fifo}] ${MODELPARAM_VALUE.use_fifo}
}


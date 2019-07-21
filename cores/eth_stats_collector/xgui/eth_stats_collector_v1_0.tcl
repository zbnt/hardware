# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set axi_width [ipgui::add_param $IPINST -name "axi_width" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Width of the AXI bus, in bytes.} ${axi_width}
  set use_timer [ipgui::add_param $IPINST -name "use_timer" -parent ${Page_0}]
  set_property tooltip {Enables the use of a reference 64 bit timer for keeping track of time. If enabled, statistics will be collected only if the timer is running.} ${use_timer}
  set enable_fifo [ipgui::add_param $IPINST -name "enable_fifo" -parent ${Page_0}]
  set_property tooltip {Enables the use of a FIFO for storing statistics.} ${enable_fifo}


}

proc update_PARAM_VALUE.axi_width { PARAM_VALUE.axi_width } {
	# Procedure called to update axi_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.axi_width { PARAM_VALUE.axi_width } {
	# Procedure called to validate axi_width
	return true
}

proc update_PARAM_VALUE.enable_fifo { PARAM_VALUE.enable_fifo } {
	# Procedure called to update enable_fifo when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.enable_fifo { PARAM_VALUE.enable_fifo } {
	# Procedure called to validate enable_fifo
	return true
}

proc update_PARAM_VALUE.use_timer { PARAM_VALUE.use_timer } {
	# Procedure called to update use_timer when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.use_timer { PARAM_VALUE.use_timer } {
	# Procedure called to validate use_timer
	return true
}


proc update_MODELPARAM_VALUE.use_timer { MODELPARAM_VALUE.use_timer PARAM_VALUE.use_timer } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.use_timer}] ${MODELPARAM_VALUE.use_timer}
}

proc update_MODELPARAM_VALUE.enable_fifo { MODELPARAM_VALUE.enable_fifo PARAM_VALUE.enable_fifo } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.enable_fifo}] ${MODELPARAM_VALUE.enable_fifo}
}

proc update_MODELPARAM_VALUE.axi_width { MODELPARAM_VALUE.axi_width PARAM_VALUE.axi_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.axi_width}] ${MODELPARAM_VALUE.axi_width}
}


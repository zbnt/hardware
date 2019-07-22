# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set axi_width [ipgui::add_param $IPINST -name "axi_width" -parent ${Page_0} -layout horizontal]
  set_property tooltip {Width of the AXI bus, in bits.} ${axi_width}
  #Adding Group
  set Frame_options [ipgui::add_group $IPINST -name "Frame options" -parent ${Page_0}]
  set main_mac [ipgui::add_param $IPINST -name "main_mac" -parent ${Frame_options}]
  set_property tooltip {MAC address for the main interface} ${main_mac}
  set loop_mac [ipgui::add_param $IPINST -name "loop_mac" -parent ${Frame_options}]
  set_property tooltip {MAC address for the loopback interface} ${loop_mac}
  set identifier [ipgui::add_param $IPINST -name "identifier" -parent ${Frame_options}]
  set_property tooltip {Identifier for the ping/pong frames} ${identifier}



}

proc update_PARAM_VALUE.axi_width { PARAM_VALUE.axi_width } {
	# Procedure called to update axi_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.axi_width { PARAM_VALUE.axi_width } {
	# Procedure called to validate axi_width
	return true
}

proc update_PARAM_VALUE.identifier { PARAM_VALUE.identifier } {
	# Procedure called to update identifier when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.identifier { PARAM_VALUE.identifier } {
	# Procedure called to validate identifier
	return true
}

proc update_PARAM_VALUE.loop_mac { PARAM_VALUE.loop_mac } {
	# Procedure called to update loop_mac when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.loop_mac { PARAM_VALUE.loop_mac } {
	# Procedure called to validate loop_mac
	return true
}

proc update_PARAM_VALUE.main_mac { PARAM_VALUE.main_mac } {
	# Procedure called to update main_mac when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.main_mac { PARAM_VALUE.main_mac } {
	# Procedure called to validate main_mac
	return true
}


proc update_MODELPARAM_VALUE.main_mac { MODELPARAM_VALUE.main_mac PARAM_VALUE.main_mac } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.main_mac}] ${MODELPARAM_VALUE.main_mac}
}

proc update_MODELPARAM_VALUE.loop_mac { MODELPARAM_VALUE.loop_mac PARAM_VALUE.loop_mac } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.loop_mac}] ${MODELPARAM_VALUE.loop_mac}
}

proc update_MODELPARAM_VALUE.identifier { MODELPARAM_VALUE.identifier PARAM_VALUE.identifier } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.identifier}] ${MODELPARAM_VALUE.identifier}
}

proc update_MODELPARAM_VALUE.axi_width { MODELPARAM_VALUE.axi_width PARAM_VALUE.axi_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.axi_width}] ${MODELPARAM_VALUE.axi_width}
}


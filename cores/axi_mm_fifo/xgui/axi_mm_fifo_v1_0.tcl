
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/axi_mm_fifo_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set FIFO [ipgui::add_group $IPINST -name "FIFO" -parent ${Page_0}]
  set C_WIDTH [ipgui::add_param $IPINST -name "C_WIDTH" -parent ${FIFO} -widget comboBox]
  set_property tooltip {Width of the data, in bits.} ${C_WIDTH}
  set C_MAX_OCCUPANCY [ipgui::add_param $IPINST -name "C_MAX_OCCUPANCY" -parent ${FIFO}]
  set_property tooltip {Maximum number of words stored.} ${C_MAX_OCCUPANCY}

  #Adding Group
  set Memory [ipgui::add_group $IPINST -name "Memory" -parent ${Page_0}]
  set_property tooltip {Memory} ${Memory}
  set C_BASE_ADDR [ipgui::add_param $IPINST -name "C_BASE_ADDR" -parent ${Memory}]
  set_property tooltip {Base address,} ${C_BASE_ADDR}
  set C_MEM_SIZE [ipgui::add_param $IPINST -name "C_MEM_SIZE" -parent ${Memory} -widget comboBox]
  set_property tooltip {Size of the memory block, in bytes.} ${C_MEM_SIZE}



}

proc update_PARAM_VALUE.C_END_ADDR { PARAM_VALUE.C_END_ADDR PARAM_VALUE.C_BASE_ADDR PARAM_VALUE.C_MEM_SIZE } {
	# Procedure called to update C_END_ADDR when any of the dependent parameters in the arguments change
	
	set C_END_ADDR ${PARAM_VALUE.C_END_ADDR}
	set C_BASE_ADDR ${PARAM_VALUE.C_BASE_ADDR}
	set C_MEM_SIZE ${PARAM_VALUE.C_MEM_SIZE}
	set values(C_BASE_ADDR) [get_property value $C_BASE_ADDR]
	set values(C_MEM_SIZE) [get_property value $C_MEM_SIZE]
	set_property value [gen_USERPARAMETER_C_END_ADDR_VALUE $values(C_BASE_ADDR) $values(C_MEM_SIZE)] $C_END_ADDR
}

proc validate_PARAM_VALUE.C_END_ADDR { PARAM_VALUE.C_END_ADDR } {
	# Procedure called to validate C_END_ADDR
	return true
}

proc update_PARAM_VALUE.C_MAX_OCCUPANCY { PARAM_VALUE.C_MAX_OCCUPANCY PARAM_VALUE.C_MEM_SIZE PARAM_VALUE.C_WIDTH } {
	# Procedure called to update C_MAX_OCCUPANCY when any of the dependent parameters in the arguments change
	
	set C_MAX_OCCUPANCY ${PARAM_VALUE.C_MAX_OCCUPANCY}
	set C_MEM_SIZE ${PARAM_VALUE.C_MEM_SIZE}
	set C_WIDTH ${PARAM_VALUE.C_WIDTH}
	set values(C_MEM_SIZE) [get_property value $C_MEM_SIZE]
	set values(C_WIDTH) [get_property value $C_WIDTH]
	set_property value [gen_USERPARAMETER_C_MAX_OCCUPANCY_VALUE $values(C_MEM_SIZE) $values(C_WIDTH)] $C_MAX_OCCUPANCY
}

proc validate_PARAM_VALUE.C_MAX_OCCUPANCY { PARAM_VALUE.C_MAX_OCCUPANCY } {
	# Procedure called to validate C_MAX_OCCUPANCY
	return true
}

proc update_PARAM_VALUE.C_BASE_ADDR { PARAM_VALUE.C_BASE_ADDR } {
	# Procedure called to update C_BASE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_BASE_ADDR { PARAM_VALUE.C_BASE_ADDR } {
	# Procedure called to validate C_BASE_ADDR
	return true
}

proc update_PARAM_VALUE.C_MEM_SIZE { PARAM_VALUE.C_MEM_SIZE } {
	# Procedure called to update C_MEM_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MEM_SIZE { PARAM_VALUE.C_MEM_SIZE } {
	# Procedure called to validate C_MEM_SIZE
	return true
}

proc update_PARAM_VALUE.C_WIDTH { PARAM_VALUE.C_WIDTH } {
	# Procedure called to update C_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_WIDTH { PARAM_VALUE.C_WIDTH } {
	# Procedure called to validate C_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_WIDTH { MODELPARAM_VALUE.C_WIDTH PARAM_VALUE.C_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_WIDTH}] ${MODELPARAM_VALUE.C_WIDTH}
}

proc update_MODELPARAM_VALUE.C_BASE_ADDR { MODELPARAM_VALUE.C_BASE_ADDR PARAM_VALUE.C_BASE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_BASE_ADDR}] ${MODELPARAM_VALUE.C_BASE_ADDR}
}

proc update_MODELPARAM_VALUE.C_MEM_SIZE { MODELPARAM_VALUE.C_MEM_SIZE PARAM_VALUE.C_MEM_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MEM_SIZE}] ${MODELPARAM_VALUE.C_MEM_SIZE}
}

proc update_MODELPARAM_VALUE.C_END_ADDR { MODELPARAM_VALUE.C_END_ADDR PARAM_VALUE.C_END_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_END_ADDR}] ${MODELPARAM_VALUE.C_END_ADDR}
}

proc update_MODELPARAM_VALUE.C_MAX_OCCUPANCY { MODELPARAM_VALUE.C_MAX_OCCUPANCY PARAM_VALUE.C_MAX_OCCUPANCY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_OCCUPANCY}] ${MODELPARAM_VALUE.C_MAX_OCCUPANCY}
}


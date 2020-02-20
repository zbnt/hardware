
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/eth_frame_detector_v1_1.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {General}]
  set_property tooltip {General} ${Page_0}
  set C_AXI_WIDTH [ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${Page_0} -layout horizontal]
  set_property tooltip {Width of the AXI bus, in bits.} ${C_AXI_WIDTH}
  #Adding Group
  set Clocking [ipgui::add_group $IPINST -name "Clocking" -parent ${Page_0}]
  set_property tooltip {Clocking} ${Clocking}
  ipgui::add_param $IPINST -name "C_SHARED_RX_CLK" -parent ${Clocking}
  ipgui::add_param $IPINST -name "C_SHARED_TX_CLK" -parent ${Clocking}


  #Adding Page
  set Features [ipgui::add_page $IPINST -name "Features"]
  set_property tooltip {Features} ${Features}
  #Adding Group
  set Units [ipgui::add_group $IPINST -name "Units" -parent ${Features}]
  ipgui::add_param $IPINST -name "C_ENABLE_COMPARE" -parent ${Units}
  set C_AXIS_LOG_ENABLE [ipgui::add_param $IPINST -name "C_AXIS_LOG_ENABLE" -parent ${Units}]
  set_property tooltip {Enable AXIS interface for saving frames and metadata to external memory.} ${C_AXIS_LOG_ENABLE}
  ipgui::add_param $IPINST -name "C_ENABLE_EDIT" -parent ${Units}
  ipgui::add_param $IPINST -name "C_ENABLE_CHECKSUM" -parent ${Units}

  #Adding Group
  set Scripts [ipgui::add_group $IPINST -name "Scripts" -parent ${Features}]
  set C_NUM_SCRIPTS [ipgui::add_param $IPINST -name "C_NUM_SCRIPTS" -parent ${Scripts}]
  set_property tooltip {Number of scripts available per traffic direction} ${C_NUM_SCRIPTS}
  set C_MAX_SCRIPT_SIZE [ipgui::add_param $IPINST -name "C_MAX_SCRIPT_SIZE" -parent ${Scripts} -widget comboBox]
  set_property tooltip {Maximum number of instructions for each script} ${C_MAX_SCRIPT_SIZE}

  #Adding Group
  set Log_options [ipgui::add_group $IPINST -name "Log options" -parent ${Features} -display_name {Extraction unit}]
  set_property tooltip {Extraction unit} ${Log_options}
  set C_AXIS_LOG_WIDTH [ipgui::add_param $IPINST -name "C_AXIS_LOG_WIDTH" -parent ${Log_options} -widget comboBox]
  set_property tooltip {Width of the AXIS interface, in bits.} ${C_AXIS_LOG_WIDTH}


  #Adding Page
  set FIFOs [ipgui::add_page $IPINST -name "FIFOs" -display_name {FIFO}]
  set_property tooltip {FIFO} ${FIFOs}
  #Adding Group
  set FIFO_Sizes [ipgui::add_group $IPINST -name "FIFO Sizes" -parent ${FIFOs} -display_name {Sizes}]
  set_property tooltip {Sizes} ${FIFO_Sizes}
  set C_LOOP_FIFO_A_SIZE [ipgui::add_param $IPINST -name "C_LOOP_FIFO_A_SIZE" -parent ${FIFO_Sizes} -widget comboBox]
  set_property tooltip {Maximum number of bytes that can be stored in the primary transmission FIFO.} ${C_LOOP_FIFO_A_SIZE}
  set C_LOOP_FIFO_B_SIZE [ipgui::add_param $IPINST -name "C_LOOP_FIFO_B_SIZE" -parent ${FIFO_Sizes} -widget comboBox]
  set_property tooltip {Maximum number of bytes that can be stored in the secondary transmission FIFO.} ${C_LOOP_FIFO_B_SIZE}
  set C_EXTRACT_FIFO_SIZE [ipgui::add_param $IPINST -name "C_EXTRACT_FIFO_SIZE" -parent ${FIFO_Sizes} -widget comboBox]
  set_property tooltip {Maximum number of bytes that can be stored in the extraction FIFO.} ${C_EXTRACT_FIFO_SIZE}



}

proc update_PARAM_VALUE.C_AXIS_LOG_WIDTH { PARAM_VALUE.C_AXIS_LOG_WIDTH PARAM_VALUE.C_AXIS_LOG_ENABLE } {
	# Procedure called to update C_AXIS_LOG_WIDTH when any of the dependent parameters in the arguments change
	
	set C_AXIS_LOG_WIDTH ${PARAM_VALUE.C_AXIS_LOG_WIDTH}
	set C_AXIS_LOG_ENABLE ${PARAM_VALUE.C_AXIS_LOG_ENABLE}
	set values(C_AXIS_LOG_ENABLE) [get_property value $C_AXIS_LOG_ENABLE]
	if { [gen_USERPARAMETER_C_AXIS_LOG_WIDTH_ENABLEMENT $values(C_AXIS_LOG_ENABLE)] } {
		set_property enabled true $C_AXIS_LOG_WIDTH
	} else {
		set_property enabled false $C_AXIS_LOG_WIDTH
	}
}

proc validate_PARAM_VALUE.C_AXIS_LOG_WIDTH { PARAM_VALUE.C_AXIS_LOG_WIDTH } {
	# Procedure called to validate C_AXIS_LOG_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_LOG_ENABLE { PARAM_VALUE.C_AXIS_LOG_ENABLE } {
	# Procedure called to update C_AXIS_LOG_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_LOG_ENABLE { PARAM_VALUE.C_AXIS_LOG_ENABLE } {
	# Procedure called to validate C_AXIS_LOG_ENABLE
	return true
}

proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to update C_AXI_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to validate C_AXI_WIDTH
	return true
}

proc update_PARAM_VALUE.C_ENABLE_CHECKSUM { PARAM_VALUE.C_ENABLE_CHECKSUM } {
	# Procedure called to update C_ENABLE_CHECKSUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ENABLE_CHECKSUM { PARAM_VALUE.C_ENABLE_CHECKSUM } {
	# Procedure called to validate C_ENABLE_CHECKSUM
	return true
}

proc update_PARAM_VALUE.C_ENABLE_COMPARE { PARAM_VALUE.C_ENABLE_COMPARE } {
	# Procedure called to update C_ENABLE_COMPARE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ENABLE_COMPARE { PARAM_VALUE.C_ENABLE_COMPARE } {
	# Procedure called to validate C_ENABLE_COMPARE
	return true
}

proc update_PARAM_VALUE.C_ENABLE_EDIT { PARAM_VALUE.C_ENABLE_EDIT } {
	# Procedure called to update C_ENABLE_EDIT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ENABLE_EDIT { PARAM_VALUE.C_ENABLE_EDIT } {
	# Procedure called to validate C_ENABLE_EDIT
	return true
}

proc update_PARAM_VALUE.C_EXTRACT_FIFO_SIZE { PARAM_VALUE.C_EXTRACT_FIFO_SIZE } {
	# Procedure called to update C_EXTRACT_FIFO_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_EXTRACT_FIFO_SIZE { PARAM_VALUE.C_EXTRACT_FIFO_SIZE } {
	# Procedure called to validate C_EXTRACT_FIFO_SIZE
	return true
}

proc update_PARAM_VALUE.C_LOOP_FIFO_A_SIZE { PARAM_VALUE.C_LOOP_FIFO_A_SIZE } {
	# Procedure called to update C_LOOP_FIFO_A_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LOOP_FIFO_A_SIZE { PARAM_VALUE.C_LOOP_FIFO_A_SIZE } {
	# Procedure called to validate C_LOOP_FIFO_A_SIZE
	return true
}

proc update_PARAM_VALUE.C_LOOP_FIFO_B_SIZE { PARAM_VALUE.C_LOOP_FIFO_B_SIZE } {
	# Procedure called to update C_LOOP_FIFO_B_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LOOP_FIFO_B_SIZE { PARAM_VALUE.C_LOOP_FIFO_B_SIZE } {
	# Procedure called to validate C_LOOP_FIFO_B_SIZE
	return true
}

proc update_PARAM_VALUE.C_MAX_SCRIPT_SIZE { PARAM_VALUE.C_MAX_SCRIPT_SIZE } {
	# Procedure called to update C_MAX_SCRIPT_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MAX_SCRIPT_SIZE { PARAM_VALUE.C_MAX_SCRIPT_SIZE } {
	# Procedure called to validate C_MAX_SCRIPT_SIZE
	return true
}

proc update_PARAM_VALUE.C_NUM_SCRIPTS { PARAM_VALUE.C_NUM_SCRIPTS } {
	# Procedure called to update C_NUM_SCRIPTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_NUM_SCRIPTS { PARAM_VALUE.C_NUM_SCRIPTS } {
	# Procedure called to validate C_NUM_SCRIPTS
	return true
}

proc update_PARAM_VALUE.C_SHARED_RX_CLK { PARAM_VALUE.C_SHARED_RX_CLK } {
	# Procedure called to update C_SHARED_RX_CLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SHARED_RX_CLK { PARAM_VALUE.C_SHARED_RX_CLK } {
	# Procedure called to validate C_SHARED_RX_CLK
	return true
}

proc update_PARAM_VALUE.C_SHARED_TX_CLK { PARAM_VALUE.C_SHARED_TX_CLK } {
	# Procedure called to update C_SHARED_TX_CLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SHARED_TX_CLK { PARAM_VALUE.C_SHARED_TX_CLK } {
	# Procedure called to validate C_SHARED_TX_CLK
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_WIDTH { MODELPARAM_VALUE.C_AXI_WIDTH PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WIDTH}] ${MODELPARAM_VALUE.C_AXI_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_LOG_ENABLE { MODELPARAM_VALUE.C_AXIS_LOG_ENABLE PARAM_VALUE.C_AXIS_LOG_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_LOG_ENABLE}] ${MODELPARAM_VALUE.C_AXIS_LOG_ENABLE}
}

proc update_MODELPARAM_VALUE.C_AXIS_LOG_WIDTH { MODELPARAM_VALUE.C_AXIS_LOG_WIDTH PARAM_VALUE.C_AXIS_LOG_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_LOG_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_LOG_WIDTH}
}

proc update_MODELPARAM_VALUE.C_ENABLE_COMPARE { MODELPARAM_VALUE.C_ENABLE_COMPARE PARAM_VALUE.C_ENABLE_COMPARE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ENABLE_COMPARE}] ${MODELPARAM_VALUE.C_ENABLE_COMPARE}
}

proc update_MODELPARAM_VALUE.C_ENABLE_EDIT { MODELPARAM_VALUE.C_ENABLE_EDIT PARAM_VALUE.C_ENABLE_EDIT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ENABLE_EDIT}] ${MODELPARAM_VALUE.C_ENABLE_EDIT}
}

proc update_MODELPARAM_VALUE.C_ENABLE_CHECKSUM { MODELPARAM_VALUE.C_ENABLE_CHECKSUM PARAM_VALUE.C_ENABLE_CHECKSUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ENABLE_CHECKSUM}] ${MODELPARAM_VALUE.C_ENABLE_CHECKSUM}
}

proc update_MODELPARAM_VALUE.C_NUM_SCRIPTS { MODELPARAM_VALUE.C_NUM_SCRIPTS PARAM_VALUE.C_NUM_SCRIPTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_NUM_SCRIPTS}] ${MODELPARAM_VALUE.C_NUM_SCRIPTS}
}

proc update_MODELPARAM_VALUE.C_MAX_SCRIPT_SIZE { MODELPARAM_VALUE.C_MAX_SCRIPT_SIZE PARAM_VALUE.C_MAX_SCRIPT_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_SCRIPT_SIZE}] ${MODELPARAM_VALUE.C_MAX_SCRIPT_SIZE}
}

proc update_MODELPARAM_VALUE.C_EXTRACT_FIFO_SIZE { MODELPARAM_VALUE.C_EXTRACT_FIFO_SIZE PARAM_VALUE.C_EXTRACT_FIFO_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_EXTRACT_FIFO_SIZE}] ${MODELPARAM_VALUE.C_EXTRACT_FIFO_SIZE}
}

proc update_MODELPARAM_VALUE.C_SHARED_RX_CLK { MODELPARAM_VALUE.C_SHARED_RX_CLK PARAM_VALUE.C_SHARED_RX_CLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SHARED_RX_CLK}] ${MODELPARAM_VALUE.C_SHARED_RX_CLK}
}

proc update_MODELPARAM_VALUE.C_SHARED_TX_CLK { MODELPARAM_VALUE.C_SHARED_TX_CLK PARAM_VALUE.C_SHARED_TX_CLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SHARED_TX_CLK}] ${MODELPARAM_VALUE.C_SHARED_TX_CLK}
}

proc update_MODELPARAM_VALUE.C_LOOP_FIFO_A_SIZE { MODELPARAM_VALUE.C_LOOP_FIFO_A_SIZE PARAM_VALUE.C_LOOP_FIFO_A_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LOOP_FIFO_A_SIZE}] ${MODELPARAM_VALUE.C_LOOP_FIFO_A_SIZE}
}

proc update_MODELPARAM_VALUE.C_LOOP_FIFO_B_SIZE { MODELPARAM_VALUE.C_LOOP_FIFO_B_SIZE PARAM_VALUE.C_LOOP_FIFO_B_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LOOP_FIFO_B_SIZE}] ${MODELPARAM_VALUE.C_LOOP_FIFO_B_SIZE}
}


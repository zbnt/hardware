# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set General [ipgui::add_page $IPINST -name "General"]
  #Adding Group
  set S_AXI_Options [ipgui::add_group $IPINST -name "S_AXI Options" -parent ${General} -display_name {AXI}]
  set_property tooltip {M_AXI Options} ${S_AXI_Options}
  set C_AXI_WIDTH [ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${S_AXI_Options} -widget comboBox]
  set_property tooltip {Width of the S_AXI bus, in bits.} ${C_AXI_WIDTH}
  ipgui::add_param $IPINST -name "C_AXI_MAX_BURST" -parent ${S_AXI_Options}

  #Adding Group
  set FIFO [ipgui::add_group $IPINST -name "FIFO" -parent ${General} -display_name {FIFOs}]
  #Adding Group
  set IO [ipgui::add_group $IPINST -name "IO" -parent ${FIFO} -display_name {IO Cache} -layout horizontal]
  ipgui::add_param $IPINST -name "C_IO_FIFO_TYPE" -parent ${IO} -widget comboBox
  ipgui::add_param $IPINST -name "C_IO_FIFO_SIZE" -parent ${IO}

  #Adding Group
  set Scatterlist [ipgui::add_group $IPINST -name "Scatterlist" -parent ${FIFO} -display_name {Scatterlist queue} -layout horizontal]
  ipgui::add_param $IPINST -name "C_SG_FIFO_TYPE" -parent ${Scatterlist} -widget comboBox
  ipgui::add_param $IPINST -name "C_SG_FIFO_SIZE" -parent ${Scatterlist}



  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {M_AXI_HOST}]
  #Adding Group
  set AXI_to_Host [ipgui::add_group $IPINST -name "AXI to Host" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "C_AXI_ADDR_WIDTH_H" -parent ${AXI_to_Host} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_AXCACHE_H" -parent ${AXI_to_Host}
  ipgui::add_param $IPINST -name "C_AXI_AXUSER_H" -parent ${AXI_to_Host}
  ipgui::add_param $IPINST -name "C_AXI_AXPROT_H" -parent ${AXI_to_Host}


  #Adding Page
  set M_AXI_FPGA [ipgui::add_page $IPINST -name "M_AXI_FPGA" -display_name {M_AXI_FPGA}]
  #Adding Group
  set AXI [ipgui::add_group $IPINST -name "AXI" -parent ${M_AXI_FPGA} -display_name {AXI to FPGA}]
  ipgui::add_param $IPINST -name "C_AXI_ADDR_WIDTH_F" -parent ${AXI}
  ipgui::add_param $IPINST -name "C_AXI_AXCACHE_F" -parent ${AXI}
  ipgui::add_param $IPINST -name "C_AXI_AXUSER_F" -parent ${AXI}
  ipgui::add_param $IPINST -name "C_AXI_AXPROT_F" -parent ${AXI}


  #Adding Page
  set Configuration_interface [ipgui::add_page $IPINST -name "Configuration interface" -display_name {S_AXI_CFG}]
  #Adding Group
  set AXI_from_Host [ipgui::add_group $IPINST -name "AXI from Host" -parent ${Configuration_interface}]
  ipgui::add_param $IPINST -name "C_AXI_CFG_WIDTH" -parent ${AXI_from_Host} -widget comboBox



}

proc update_PARAM_VALUE.C_AXI_ADDR_WIDTH_F { PARAM_VALUE.C_AXI_ADDR_WIDTH_F } {
	# Procedure called to update C_AXI_ADDR_WIDTH_F when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ADDR_WIDTH_F { PARAM_VALUE.C_AXI_ADDR_WIDTH_F } {
	# Procedure called to validate C_AXI_ADDR_WIDTH_F
	return true
}

proc update_PARAM_VALUE.C_AXI_ADDR_WIDTH_H { PARAM_VALUE.C_AXI_ADDR_WIDTH_H } {
	# Procedure called to update C_AXI_ADDR_WIDTH_H when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ADDR_WIDTH_H { PARAM_VALUE.C_AXI_ADDR_WIDTH_H } {
	# Procedure called to validate C_AXI_ADDR_WIDTH_H
	return true
}

proc update_PARAM_VALUE.C_AXI_AXCACHE_F { PARAM_VALUE.C_AXI_AXCACHE_F } {
	# Procedure called to update C_AXI_AXCACHE_F when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_AXCACHE_F { PARAM_VALUE.C_AXI_AXCACHE_F } {
	# Procedure called to validate C_AXI_AXCACHE_F
	return true
}

proc update_PARAM_VALUE.C_AXI_AXCACHE_H { PARAM_VALUE.C_AXI_AXCACHE_H } {
	# Procedure called to update C_AXI_AXCACHE_H when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_AXCACHE_H { PARAM_VALUE.C_AXI_AXCACHE_H } {
	# Procedure called to validate C_AXI_AXCACHE_H
	return true
}

proc update_PARAM_VALUE.C_AXI_AXPROT_F { PARAM_VALUE.C_AXI_AXPROT_F } {
	# Procedure called to update C_AXI_AXPROT_F when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_AXPROT_F { PARAM_VALUE.C_AXI_AXPROT_F } {
	# Procedure called to validate C_AXI_AXPROT_F
	return true
}

proc update_PARAM_VALUE.C_AXI_AXPROT_H { PARAM_VALUE.C_AXI_AXPROT_H } {
	# Procedure called to update C_AXI_AXPROT_H when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_AXPROT_H { PARAM_VALUE.C_AXI_AXPROT_H } {
	# Procedure called to validate C_AXI_AXPROT_H
	return true
}

proc update_PARAM_VALUE.C_AXI_AXUSER_F { PARAM_VALUE.C_AXI_AXUSER_F } {
	# Procedure called to update C_AXI_AXUSER_F when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_AXUSER_F { PARAM_VALUE.C_AXI_AXUSER_F } {
	# Procedure called to validate C_AXI_AXUSER_F
	return true
}

proc update_PARAM_VALUE.C_AXI_AXUSER_H { PARAM_VALUE.C_AXI_AXUSER_H } {
	# Procedure called to update C_AXI_AXUSER_H when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_AXUSER_H { PARAM_VALUE.C_AXI_AXUSER_H } {
	# Procedure called to validate C_AXI_AXUSER_H
	return true
}

proc update_PARAM_VALUE.C_AXI_CFG_ADDR_WIDTH { PARAM_VALUE.C_AXI_CFG_ADDR_WIDTH } {
	# Procedure called to update C_AXI_CFG_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_CFG_ADDR_WIDTH { PARAM_VALUE.C_AXI_CFG_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_CFG_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_CFG_WIDTH { PARAM_VALUE.C_AXI_CFG_WIDTH } {
	# Procedure called to update C_AXI_CFG_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_CFG_WIDTH { PARAM_VALUE.C_AXI_CFG_WIDTH } {
	# Procedure called to validate C_AXI_CFG_WIDTH
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

proc update_PARAM_VALUE.C_IO_FIFO_SIZE { PARAM_VALUE.C_IO_FIFO_SIZE } {
	# Procedure called to update C_IO_FIFO_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_IO_FIFO_SIZE { PARAM_VALUE.C_IO_FIFO_SIZE } {
	# Procedure called to validate C_IO_FIFO_SIZE
	return true
}

proc update_PARAM_VALUE.C_IO_FIFO_TYPE { PARAM_VALUE.C_IO_FIFO_TYPE } {
	# Procedure called to update C_IO_FIFO_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_IO_FIFO_TYPE { PARAM_VALUE.C_IO_FIFO_TYPE } {
	# Procedure called to validate C_IO_FIFO_TYPE
	return true
}

proc update_PARAM_VALUE.C_SG_FIFO_SIZE { PARAM_VALUE.C_SG_FIFO_SIZE } {
	# Procedure called to update C_SG_FIFO_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SG_FIFO_SIZE { PARAM_VALUE.C_SG_FIFO_SIZE } {
	# Procedure called to validate C_SG_FIFO_SIZE
	return true
}

proc update_PARAM_VALUE.C_SG_FIFO_TYPE { PARAM_VALUE.C_SG_FIFO_TYPE } {
	# Procedure called to update C_SG_FIFO_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SG_FIFO_TYPE { PARAM_VALUE.C_SG_FIFO_TYPE } {
	# Procedure called to validate C_SG_FIFO_TYPE
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_WIDTH { MODELPARAM_VALUE.C_AXI_WIDTH PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WIDTH}] ${MODELPARAM_VALUE.C_AXI_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_ADDR_WIDTH_H { MODELPARAM_VALUE.C_AXI_ADDR_WIDTH_H PARAM_VALUE.C_AXI_ADDR_WIDTH_H } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ADDR_WIDTH_H}] ${MODELPARAM_VALUE.C_AXI_ADDR_WIDTH_H}
}

proc update_MODELPARAM_VALUE.C_AXI_ADDR_WIDTH_F { MODELPARAM_VALUE.C_AXI_ADDR_WIDTH_F PARAM_VALUE.C_AXI_ADDR_WIDTH_F } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ADDR_WIDTH_F}] ${MODELPARAM_VALUE.C_AXI_ADDR_WIDTH_F}
}

proc update_MODELPARAM_VALUE.C_AXI_MAX_BURST { MODELPARAM_VALUE.C_AXI_MAX_BURST PARAM_VALUE.C_AXI_MAX_BURST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_MAX_BURST}] ${MODELPARAM_VALUE.C_AXI_MAX_BURST}
}

proc update_MODELPARAM_VALUE.C_AXI_CFG_WIDTH { MODELPARAM_VALUE.C_AXI_CFG_WIDTH PARAM_VALUE.C_AXI_CFG_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_CFG_WIDTH}] ${MODELPARAM_VALUE.C_AXI_CFG_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_CFG_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_CFG_ADDR_WIDTH PARAM_VALUE.C_AXI_CFG_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_CFG_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_CFG_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_IO_FIFO_TYPE { MODELPARAM_VALUE.C_IO_FIFO_TYPE PARAM_VALUE.C_IO_FIFO_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_IO_FIFO_TYPE}] ${MODELPARAM_VALUE.C_IO_FIFO_TYPE}
}

proc update_MODELPARAM_VALUE.C_IO_FIFO_SIZE { MODELPARAM_VALUE.C_IO_FIFO_SIZE PARAM_VALUE.C_IO_FIFO_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_IO_FIFO_SIZE}] ${MODELPARAM_VALUE.C_IO_FIFO_SIZE}
}

proc update_MODELPARAM_VALUE.C_SG_FIFO_TYPE { MODELPARAM_VALUE.C_SG_FIFO_TYPE PARAM_VALUE.C_SG_FIFO_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SG_FIFO_TYPE}] ${MODELPARAM_VALUE.C_SG_FIFO_TYPE}
}

proc update_MODELPARAM_VALUE.C_SG_FIFO_SIZE { MODELPARAM_VALUE.C_SG_FIFO_SIZE PARAM_VALUE.C_SG_FIFO_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SG_FIFO_SIZE}] ${MODELPARAM_VALUE.C_SG_FIFO_SIZE}
}

proc update_MODELPARAM_VALUE.C_AXI_AXPROT_F { MODELPARAM_VALUE.C_AXI_AXPROT_F PARAM_VALUE.C_AXI_AXPROT_F } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_AXPROT_F}] ${MODELPARAM_VALUE.C_AXI_AXPROT_F}
}

proc update_MODELPARAM_VALUE.C_AXI_AXCACHE_F { MODELPARAM_VALUE.C_AXI_AXCACHE_F PARAM_VALUE.C_AXI_AXCACHE_F } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_AXCACHE_F}] ${MODELPARAM_VALUE.C_AXI_AXCACHE_F}
}

proc update_MODELPARAM_VALUE.C_AXI_AXUSER_F { MODELPARAM_VALUE.C_AXI_AXUSER_F PARAM_VALUE.C_AXI_AXUSER_F } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_AXUSER_F}] ${MODELPARAM_VALUE.C_AXI_AXUSER_F}
}

proc update_MODELPARAM_VALUE.C_AXI_AXPROT_H { MODELPARAM_VALUE.C_AXI_AXPROT_H PARAM_VALUE.C_AXI_AXPROT_H } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_AXPROT_H}] ${MODELPARAM_VALUE.C_AXI_AXPROT_H}
}

proc update_MODELPARAM_VALUE.C_AXI_AXCACHE_H { MODELPARAM_VALUE.C_AXI_AXCACHE_H PARAM_VALUE.C_AXI_AXCACHE_H } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_AXCACHE_H}] ${MODELPARAM_VALUE.C_AXI_AXCACHE_H}
}

proc update_MODELPARAM_VALUE.C_AXI_AXUSER_H { MODELPARAM_VALUE.C_AXI_AXUSER_H PARAM_VALUE.C_AXI_AXUSER_H } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_AXUSER_H}] ${MODELPARAM_VALUE.C_AXI_AXUSER_H}
}


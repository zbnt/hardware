# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {AXI}]
  set_property tooltip {AXI} ${Page_0}
  #Adding Group
  set AXI [ipgui::add_group $IPINST -name "AXI" -parent ${Page_0} -display_name {Size} -layout horizontal]
  set_property tooltip {Size} ${AXI}
  set C_AXI_WIDTH [ipgui::add_param $IPINST -name "C_AXI_WIDTH" -parent ${AXI} -widget comboBox]
  set_property tooltip {Width of the AXI bus, in bits.} ${C_AXI_WIDTH}

  #Adding Group
  set FIFOs [ipgui::add_group $IPINST -name "FIFOs" -parent ${Page_0}]
  set C_AXI_RD_FIFO_DEPTH [ipgui::add_param $IPINST -name "C_AXI_RD_FIFO_DEPTH" -parent ${FIFOs} -widget comboBox]
  set_property tooltip {Maximum number of read values that can be buffered.} ${C_AXI_RD_FIFO_DEPTH}
  set C_AXI_WR_FIFO_DEPTH [ipgui::add_param $IPINST -name "C_AXI_WR_FIFO_DEPTH" -parent ${FIFOs} -widget comboBox]
  set_property tooltip {Maximum number of written values that can be buffered.} ${C_AXI_WR_FIFO_DEPTH}


  #Adding Page
  set Page_1 [ipgui::add_page $IPINST -name "Page 1" -display_name {Memory}]
  set_property tooltip {Memory} ${Page_1}
  #Adding Group
  set IO [ipgui::add_group $IPINST -name "IO" -parent ${Page_1}]
  ipgui::add_param $IPINST -name "C_INTERNAL_IOBUF" -parent ${IO}

  #Adding Group
  set Memory [ipgui::add_group $IPINST -name "Memory" -parent ${Page_1} -display_name {Size} -layout horizontal]
  set_property tooltip {Size} ${Memory}
  set C_MEM_WIDTH [ipgui::add_param $IPINST -name "C_MEM_WIDTH" -parent ${Memory} -widget comboBox]
  set_property tooltip {Width of the memory data, in bits} ${C_MEM_WIDTH}
  set C_MEM_SIZE [ipgui::add_param $IPINST -name "C_MEM_SIZE" -parent ${Memory} -widget comboBox]
  set_property tooltip {Size of the memory, in bytes} ${C_MEM_SIZE}

  #Adding Group
  set Alignment [ipgui::add_group $IPINST -name "Alignment" -parent ${Page_1}]
  set C_READ_BURST_ALIGNMENT [ipgui::add_param $IPINST -name "C_READ_BURST_ALIGNMENT" -parent ${Alignment} -widget comboBox]
  set_property tooltip {Alignment required for read bursts} ${C_READ_BURST_ALIGNMENT}

  #Adding Group
  set Timing [ipgui::add_group $IPINST -name "Timing" -parent ${Page_1}]
  set C_ADDR_TO_CEL_TIME [ipgui::add_param $IPINST -name "C_ADDR_TO_CEL_TIME" -parent ${Timing}]
  set_property tooltip {Number of clock cycles between ADDR valid and CE_N low} ${C_ADDR_TO_CEL_TIME}
  set C_IO_TO_IO_TIME [ipgui::add_param $IPINST -name "C_IO_TO_IO_TIME" -parent ${Timing}]
  set_property tooltip {Minimum amount of clock cycles between IO operations} ${C_IO_TO_IO_TIME}
  #Adding Group
  set Read [ipgui::add_group $IPINST -name "Read" -parent ${Timing}]
  set C_OEL_TO_DQ_TIME [ipgui::add_param $IPINST -name "C_OEL_TO_DQ_TIME" -parent ${Read}]
  set_property tooltip {Number of clock cycles between OE_N low and first DQ input sample} ${C_OEL_TO_DQ_TIME}

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

proc update_PARAM_VALUE.C_AXI_RD_FIFO_DEPTH { PARAM_VALUE.C_AXI_RD_FIFO_DEPTH } {
	# Procedure called to update C_AXI_RD_FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_RD_FIFO_DEPTH { PARAM_VALUE.C_AXI_RD_FIFO_DEPTH } {
	# Procedure called to validate C_AXI_RD_FIFO_DEPTH
	return true
}

proc update_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to update C_AXI_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_WIDTH { PARAM_VALUE.C_AXI_WIDTH } {
	# Procedure called to validate C_AXI_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_WR_FIFO_DEPTH { PARAM_VALUE.C_AXI_WR_FIFO_DEPTH } {
	# Procedure called to update C_AXI_WR_FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_WR_FIFO_DEPTH { PARAM_VALUE.C_AXI_WR_FIFO_DEPTH } {
	# Procedure called to validate C_AXI_WR_FIFO_DEPTH
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

proc update_PARAM_VALUE.C_IO_TO_IO_TIME { PARAM_VALUE.C_IO_TO_IO_TIME } {
	# Procedure called to update C_IO_TO_IO_TIME when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_IO_TO_IO_TIME { PARAM_VALUE.C_IO_TO_IO_TIME } {
	# Procedure called to validate C_IO_TO_IO_TIME
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

proc update_PARAM_VALUE.C_OEL_TO_DQ_TIME { PARAM_VALUE.C_OEL_TO_DQ_TIME } {
	# Procedure called to update C_OEL_TO_DQ_TIME when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OEL_TO_DQ_TIME { PARAM_VALUE.C_OEL_TO_DQ_TIME } {
	# Procedure called to validate C_OEL_TO_DQ_TIME
	return true
}

proc update_PARAM_VALUE.C_READ_BURST_ALIGNMENT { PARAM_VALUE.C_READ_BURST_ALIGNMENT } {
	# Procedure called to update C_READ_BURST_ALIGNMENT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_READ_BURST_ALIGNMENT { PARAM_VALUE.C_READ_BURST_ALIGNMENT } {
	# Procedure called to validate C_READ_BURST_ALIGNMENT
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

proc update_MODELPARAM_VALUE.C_WEL_TO_DQ_TIME { MODELPARAM_VALUE.C_WEL_TO_DQ_TIME PARAM_VALUE.C_WEL_TO_DQ_TIME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_WEL_TO_DQ_TIME}] ${MODELPARAM_VALUE.C_WEL_TO_DQ_TIME}
}

proc update_MODELPARAM_VALUE.C_DQ_TO_WEH_TIME { MODELPARAM_VALUE.C_DQ_TO_WEH_TIME PARAM_VALUE.C_DQ_TO_WEH_TIME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DQ_TO_WEH_TIME}] ${MODELPARAM_VALUE.C_DQ_TO_WEH_TIME}
}

proc update_MODELPARAM_VALUE.C_OEL_TO_DQ_TIME { MODELPARAM_VALUE.C_OEL_TO_DQ_TIME PARAM_VALUE.C_OEL_TO_DQ_TIME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OEL_TO_DQ_TIME}] ${MODELPARAM_VALUE.C_OEL_TO_DQ_TIME}
}

proc update_MODELPARAM_VALUE.C_IO_TO_IO_TIME { MODELPARAM_VALUE.C_IO_TO_IO_TIME PARAM_VALUE.C_IO_TO_IO_TIME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_IO_TO_IO_TIME}] ${MODELPARAM_VALUE.C_IO_TO_IO_TIME}
}

proc update_MODELPARAM_VALUE.C_AXI_RD_FIFO_DEPTH { MODELPARAM_VALUE.C_AXI_RD_FIFO_DEPTH PARAM_VALUE.C_AXI_RD_FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_RD_FIFO_DEPTH}] ${MODELPARAM_VALUE.C_AXI_RD_FIFO_DEPTH}
}

proc update_MODELPARAM_VALUE.C_AXI_WR_FIFO_DEPTH { MODELPARAM_VALUE.C_AXI_WR_FIFO_DEPTH PARAM_VALUE.C_AXI_WR_FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_WR_FIFO_DEPTH}] ${MODELPARAM_VALUE.C_AXI_WR_FIFO_DEPTH}
}

proc update_MODELPARAM_VALUE.C_READ_BURST_ALIGNMENT { MODELPARAM_VALUE.C_READ_BURST_ALIGNMENT PARAM_VALUE.C_READ_BURST_ALIGNMENT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_READ_BURST_ALIGNMENT}] ${MODELPARAM_VALUE.C_READ_BURST_ALIGNMENT}
}


cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt axi_mm2s 1.0]

ip::set_disp_name   $core "AXI Memory-Mapped to Stream"
ip::set_description $core "AXI Memory-Mapped to Stream"
ip::set_categories  $core /AXI_Infrastructure

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/axi_mm2s_wrapper.v
	hdl/axi_mm2s.sv
	hdl/axi_mm2s_io.sv
}

ip::add_subcore    $core "oscar-rc.dev:zbnt:common:1.0"
ip::add_gui_script $core xgui/axi_mm2s.tcl

ip::set_top $core axi_mm2s_w hdl/axi_mm2s_wrapper.v

# Parameters

ip::set_param_disp_name $core C_AXI_WIDTH "Data Width"
ip::set_param_list      $core C_AXI_WIDTH {32 64 128 256}

ip::set_param_disp_name $core C_AXI_ADDR_WIDTH "Address Width"
ip::set_param_list      $core C_AXI_ADDR_WIDTH {16 24 32 40 48 56 64}

ip::set_param_disp_name $core C_AXI_MAX_BURST "Maximum burst"
ip::set_param_range     $core C_AXI_MAX_BURST 0 255

ip::set_param_disp_name $core C_FIFO_SIZE "Size"
ip::set_param_range     $core C_FIFO_SIZE 16 256

ip::set_param_disp_name $core C_FIFO_TYPE "Type"
ip::set_param_pairs     $core C_FIFO_TYPE {
	{Disabled}        none
	{Distributed RAM} distributed
	{Block RAM}       block
	{Ultra RAM}       ultra
}

ip::set_param_disp_name $core C_VALUE_ARPROT "ARPROT"
ip::set_param_format    $core C_VALUE_ARPROT bitString
ip::set_param_value     $core C_VALUE_ARPROT {"000"}
ip::set_param_bit_len   $core C_VALUE_ARPROT 3

ip::set_param_disp_name $core C_VALUE_ARCACHE "ARCACHE"
ip::set_param_format    $core C_VALUE_ARCACHE bitString
ip::set_param_value     $core C_VALUE_ARCACHE {"1111"}
ip::set_param_bit_len   $core C_VALUE_ARCACHE 4

ip::set_param_disp_name $core C_VALUE_ARUSER "ARUSER"
ip::set_param_format    $core C_VALUE_ARUSER bitString
ip::set_param_value     $core C_VALUE_ARUSER {"1111"}
ip::set_param_bit_len   $core C_VALUE_ARUSER 4

# Interfaces

ip::add_axi_interface $core M_AXI master {
	AR {ADDR LEN SIZE BURST CACHE PROT USER VALID READY}
	R  {DATA RESP LAST VALID READY}
}

ip::add_axis_interface $core M_AXIS     master {DATA STRB LAST VALID READY}
ip::add_axis_interface $core S_AXIS_CTL slave  {DATA VALID READY}
ip::add_axis_interface $core M_AXIS_ST  master {DATA VALID READY}

ip::add_clk_interface $core clk   slave {} rst_n M_AXI:M_AXIS:S_AXIS_CTL:M_AXIS_ST
ip::add_rst_interface $core rst_n slave ACTIVE_LOW

ip::save_core $core

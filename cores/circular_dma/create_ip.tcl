cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt circular_dma 1.1]

ip::set_disp_name   $core "Circular DMA"
ip::set_description $core "Writes data into a circular buffer"
ip::set_categories  $core /AXI_Peripheral

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/circular_dma_wrapper.v
	hdl/circular_dma.sv
	hdl/circular_dma_axi.sv
	hdl/circular_dma_fifos.sv
	hdl/circular_dma_fsm.sv
}

ip::add_synth_sources $core xdc/memory_opt.xdc

ip::add_subcore    $core "oscar-rc.dev:zbnt:common:1.0"
ip::add_subcore    $core "oscar-rc.dev:zbnt:axis_shutdown:1.0"
ip::add_gui_script $core xgui/circular_dma.tcl

ip::set_top $core circular_dma_w hdl/circular_dma_wrapper.v

# Parameters

ip::set_param_disp_name $core C_AXI_WIDTH "Data Width"
ip::set_param_list      $core C_AXI_WIDTH {32 64}

ip::set_param_disp_name $core C_ADDR_WIDTH "Address Width"
ip::set_param_list      $core C_ADDR_WIDTH {32 64}

ip::set_param_disp_name $core C_AXIS_WIDTH "Data Width"
ip::set_param_list      $core C_AXIS_WIDTH {64 128 256 512}

ip::set_param_disp_name $core C_MAX_BURST "Maximum Burst"
ip::set_param_list      $core C_MAX_BURST {2 4 8 16 32 64}

ip::set_param_disp_name $core C_VALUE_AWPROT "AWPROT"
ip::set_param_format    $core C_VALUE_AWPROT bitString
ip::set_param_value     $core C_VALUE_AWPROT {"000"}
ip::set_param_bit_len   $core C_VALUE_AWPROT 3

ip::set_param_disp_name $core C_VALUE_AWCACHE "AWCACHE"
ip::set_param_format    $core C_VALUE_AWCACHE bitString
ip::set_param_value     $core C_VALUE_AWCACHE {"1111"}
ip::set_param_bit_len   $core C_VALUE_AWCACHE 4

ip::set_param_disp_name $core C_VALUE_AWUSER "AWUSER"
ip::set_param_format    $core C_VALUE_AWUSER bitString
ip::set_param_value     $core C_VALUE_AWUSER {"1111"}
ip::set_param_bit_len   $core C_VALUE_AWUSER 4

for {set i 0} {$i < 4} {incr i} {
	ip::set_param_disp_name $core C_FIFO_TYPE_$i  "Type"
	ip::set_param_disp_name $core C_FIFO_DEPTH_$i "Depth"

	if {$i == 0} {
		ip::set_param_pairs $core C_FIFO_TYPE_$i {
			{Distributed RAM} distributed
			{Block RAM}       block
			{Ultra RAM}       ultra
		}
	} else {
		ip::set_param_pairs $core C_FIFO_TYPE_$i {
			{Disabled}        none
			{Distributed RAM} distributed
			{Block RAM}       block
			{Ultra RAM}       ultra
		}
	}

	ip::set_param_list $core C_FIFO_DEPTH_$i {16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536}
}

# Interfaces

ip::add_axi_interface $core S_AXI slave {
	AW {ADDR PROT VALID READY}
	W  {DATA STRB VALID READY}
	B  {RESP VALID READY}
	AR {ADDR PROT VALID READY}
	R  {DATA RESP VALID READY}
}

ip::add_axi_interface $core M_AXI master {
	AW {ADDR LEN SIZE BURST CACHE PROT USER VALID READY}
	W  {DATA STRB LAST VALID READY}
	B  {RESP VALID READY}
}

ip::add_axis_interface $core S_AXIS slave  {DATA LAST VALID READY}
ip::add_irq_interface  $core irq    master LEVEL_HIGH

ip::add_clk_interface $core clk   slave {} rst_n S_AXI:M_AXI:S_AXIS
ip::add_rst_interface $core rst_n slave ACTIVE_LOW

ip::save_core $core

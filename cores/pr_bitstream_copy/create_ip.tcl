cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt pr_bitstream_copy 1.0]

ip::set_disp_name   $core "AXI Partial Bitstream Copy"
ip::set_description $core "AXI Partial Bitstream Copy"
ip::set_categories  $core /AXI_Infrastructure

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/pr_bitstream_copy_wrapper.v
	hdl/pr_bitstream_copy.sv
	hdl/pr_bitstream_copy_rom.sv
}

ip::add_subcore    $core "oscar-rc.dev:zbnt:common:1.0"
ip::add_subcore    $core "oscar-rc.dev:zbnt:axi_mm2s:1.0"
ip::add_subcore    $core "oscar-rc.dev:zbnt:axi_s2mm:1.0"
ip::add_gui_script $core xgui/pr_bitstream_copy.tcl

ip::set_top $core pr_bitstream_copy_w hdl/pr_bitstream_copy_wrapper.v

# Parameters

ip::set_param_disp_name $core C_AXI_WIDTH "Data Width"
ip::set_param_list      $core C_AXI_WIDTH {32 64 128}

ip::set_param_disp_name $core C_AXI_ADDR_WIDTH "Address Width"
ip::set_param_range     $core C_AXI_ADDR_WIDTH 16 32

ip::set_param_disp_name $core C_SOURCE_ADDR "Source address"
ip::set_param_format    $core C_SOURCE_ADDR bitString
ip::set_param_value     $core C_SOURCE_ADDR 0x01000000

ip::set_param_disp_name $core C_DESTINATION_ADDR "Destination address"
ip::set_param_format    $core C_DESTINATION_ADDR bitString
ip::set_param_value     $core C_DESTINATION_ADDR 0x00000000
ip::set_param_bit_len   $core C_DESTINATION_ADDR 32

ip::set_param_disp_name $core C_MEMORY_SIZE "Memory size"
ip::set_param_format    $core C_MEMORY_SIZE bitString
ip::set_param_value     $core C_MEMORY_SIZE 0x00000000
ip::set_param_bit_len   $core C_MEMORY_SIZE 32

# Interfaces

ip::add_axi_interface $core M_AXI_SRC master {
	AR {ADDR LEN SIZE BURST VALID READY}
	R  {DATA RESP LAST VALID READY}
}

ip::add_axi_interface $core M_AXI_DST master {
	AW {ADDR LEN SIZE BURST VALID READY}
	W  {DATA STRB LAST VALID READY}
	B  {RESP VALID READY}
}

ip::add_axi_interface $core M_AXI_PRC master {
	AR {ADDR LEN SIZE BURST VALID READY}
	R  {DATA RESP LAST VALID READY}
}

ip::add_axi_interface $core S_AXI_PRC slave {
	AR {ADDR LEN SIZE BURST VALID READY}
	R  {DATA RESP LAST VALID READY}
}

ip::add_clk_interface $core clk   slave {} rst_n M_AXI_SRC:M_AXI_DST:M_AXI_PRC:S_AXI_PRC
ip::add_rst_interface $core rst_n slave ACTIVE_LOW

ipx::remove_address_block S_AXI_PRC_ADDR [ipx::get_memory_maps S_AXI_PRC -of_objects $core]

ip::save_core $core

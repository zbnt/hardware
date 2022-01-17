cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt bpi_flash 1.0]

ip::set_disp_name   $core "BPI Flash"
ip::set_description $core "Allows accessing a BPI Flash memory using an AXI4 interface"
ip::set_categories  $core {/AXI_Peripheral /Embedded_Processing/Memory_and_Memory_Controller}

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/bpi_flash_wrapper.v
	hdl/bpi_flash.sv
	hdl/bpi_flash_ctrl.sv
	hdl/bpi_flash_read_fsm.sv
	hdl/bpi_flash_write_fifo.sv
	hdl/bpi_flash_write_fsm.sv
}

ip::add_subcore    $core "oscar-rc.dev:zbnt:common:1.0"
ip::add_gui_script $core xgui/bpi_flash.tcl

ip::set_top $core bpi_flash_w hdl/bpi_flash_wrapper.v

# Parameters

ip::set_param_disp_name $core C_AXI_WIDTH "Data width"
ip::set_param_list      $core C_AXI_WIDTH {32 64 128 256 512}

ip::set_param_disp_name $core C_MEM_WIDTH "Data width"
ip::set_param_list      $core C_MEM_WIDTH {8 16}

ip::set_param_disp_name $core C_MEM_SIZE "Size"
ip::set_param_list      $core C_MEM_SIZE {
	8MB   8388608
	16MB  16777216
	32MB  33554432
	64MB  67108864
	128MB 134217728
	256MB 268435456
	512MB 536870912
	1GB   1073741824
}

ip::set_param_disp_name $core C_INTERNAL_IOBUF "Use internal IOBUF for data lines"
ip::set_param_format    $core C_INTERNAL_IOBUF bool
ip::set_param_value     $core C_INTERNAL_IOBUF true

ip::set_param_disp_name $core C_ADDR_TO_CEL_TIME "ADDR valid to CE_N low"
ip::set_param_range     $core C_ADDR_TO_CEL_TIME 1 8192

ip::set_param_disp_name $core C_WEL_TO_DQ_TIME "WE_N low to DQ output"
ip::set_param_range     $core C_WEL_TO_DQ_TIME 1 8192

ip::set_param_disp_name $core C_DQ_TO_WEH_TIME "DQ output to WE_N high"
ip::set_param_range     $core C_DQ_TO_WEH_TIME 1 8192

ip::set_param_disp_name $core C_OEL_TO_DQ_TIME "OE_N low to DQ input"
ip::set_param_range     $core C_OEL_TO_DQ_TIME 1 8192

ip::set_param_disp_name $core C_IO_TO_IO_TIME "IO completed to BUSY low"
ip::set_param_range     $core C_IO_TO_IO_TIME 1 8192

ip::set_param_disp_name $core C_AXI_RD_FIFO_DEPTH "Read FIFO depth"
ip::set_param_list      $core C_AXI_RD_FIFO_DEPTH {32 64 128 256 512 1024 2048 4096 8192}

ip::set_param_disp_name $core C_AXI_WR_FIFO_DEPTH "Write FIFO depth"
ip::set_param_list      $core C_AXI_WR_FIFO_DEPTH {32 64 128 256 512 1024 2048 4096 8192}

ip::set_param_disp_name $core C_READ_BURST_ALIGNMENT "Read burst"
ip::set_param_pairs     $core C_READ_BURST_ALIGNMENT {
	{1 word}   0
	{2 words}  1
	{4 words}  2
	{8 words}  3
	{16 words} 4
	{32 words} 5
}

# Interfaces

ip::add_axi_interface $core S_AXI slave {
	AW {ADDR LEN SIZE BURST VALID READY}
	W  {DATA STRB LAST VALID READY}
	B  {RESP VALID READY}
	AR {ADDR LEN SIZE BURST VALID READY}
	R  {DATA RESP LAST VALID READY}
}

ip::add_bus_interface $core BPI master "xilinx.com:interface:emc_rtl:1.0" "xilinx.com:interface:emc:1.0" {
	ADDR    bpi_a
	ADV_LDN bpi_adv
	CE_N    bpi_ce_n
	DQ_I    bpi_dq_i
	DQ_O    bpi_dq_o
	DQ_T    bpi_dq_t
	OEN     bpi_oe_n
	WEN     bpi_we_n
}

ip::add_clk_interface $core clk   slave {} rst_n S_AXI
ip::add_rst_interface $core rst_n slave ACTIVE_LOW

ip::set_port_dependencies $core {
	bpi_dq_i  {$C_INTERNAL_IOBUF == 0}
	bpi_dq_o  {$C_INTERNAL_IOBUF == 0}
	bpi_dq_t  {$C_INTERNAL_IOBUF == 0}
	bpi_dq_io {$C_INTERNAL_IOBUF != 0}
}

ip::save_core $core

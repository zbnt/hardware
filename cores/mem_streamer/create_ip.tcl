cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt mem_streamer 1.0]

ip::set_disp_name   $core "Memory Streamer"
ip::set_description $core "Stream data from BRAM using AXI4-Stream."
ip::set_categories  $core /AXI_Peripheral

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/mem_streamer_wrapper.v
	hdl/mem_streamer.sv
}

ip::add_gui_script $core xgui/mem_streamer.tcl

ip::set_top $core mem_streamer_w hdl/mem_streamer_wrapper.v

# Parameters

ip::set_param_disp_name $core C_MEM_SIZE   "Memory size"
ip::set_param_disp_name $core C_DELAY_TIME "Delay time"

ip::set_param_disp_name $core C_DATA_WIDTH "Data width"
ip::set_param_list      $core C_DATA_WIDTH {8 16 24 32 48 64}

# Interfaces

ip::add_axis_interface $core M_AXIS master {DATA LAST VALID READY}

ip::add_bus_interface $core MEM master "xilinx.com:interface:bram_rtl:1.0" "xilinx.com:interface:bram:1.0" {
	CLK  mem_clk
	RST  mem_rst

	ADDR mem_addr
	DOUT mem_rdata
	EN   mem_en
	WE   mem_we
}

ip::add_clk_interface $core clk slave {} rst_n M_AXIS
ip::add_rst_interface $core rst_n slave ACTIVE_LOW

ip::save_core $core

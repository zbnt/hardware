cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt eth_traffic_gen 1.1]

ip::set_disp_name   $core "Ethernet Traffic Generator"
ip::set_description $core "Configurable Ethernet traffic generator"
ip::set_categories  $core /AXI_Peripheral

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/eth_traffic_gen_wrapper.v
	hdl/eth_traffic_gen.sv
	hdl/eth_traffic_gen_axi.sv
	hdl/eth_traffic_gen_axis.sv
	hdl/eth_traffic_gen_burst.sv
	hdl/frame_dram.sv
	hdl/lfsr.v
	hdl/pattern_dram.sv
}

ip::add_subcore    $core "oscar-rc.dev:zbnt:common:1.0"
ip::add_gui_script $core xgui/eth_traffic_gen.tcl

ip::set_top $core eth_traffic_gen_w hdl/eth_traffic_gen_wrapper.v

# Parameters

ip::set_param_disp_name $core C_AXI_WIDTH "AXI Data Width"
ip::set_param_list      $core C_AXI_WIDTH {32 64}

ip::add_param           $core C_EXT_ENABLE bool true
ip::set_param_disp_name $core C_EXT_ENABLE "Use external enable"

# Interfaces

ip::add_axi_interface $core S_AXI slave {
	AW {ADDR PROT VALID READY}
	W  {DATA STRB VALID READY}
	B  {RESP VALID READY}
	AR {ADDR PROT VALID READY}
	R  {DATA RESP VALID READY}
}

ip::add_axis_interface $core M_AXIS master {DATA USER LAST VALID READY}

ip::add_clk_interface $core clk   slave {} rst_n S_AXI:M_AXIS
ip::add_rst_interface $core rst_n slave ACTIVE_LOW

ip::set_port_dependencies $core {
	ext_enable {$C_EXT_ENABLE == 1}
}

ip::set_port_drivers $core {
	ext_enable 1
}

ip::save_core $core

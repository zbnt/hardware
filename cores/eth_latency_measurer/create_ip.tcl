cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt eth_latency_measurer 1.1]

ip::set_disp_name   $core "Ethernet Latency Measurer"
ip::set_description $core "Measures the latency between two interfaces"
ip::set_categories  $core /AXI_Peripheral

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/eth_latency_measurer_wrapper.v
	hdl/eth_latency_measurer.sv
	hdl/checksum_calculator.sv
	hdl/eth_latency_measurer_axi.sv
	hdl/eth_latency_measurer_axis_log.sv
	hdl/eth_latency_measurer_coord.sv
	hdl/eth_latency_measurer_rx.sv
	hdl/eth_latency_measurer_tx.sv
	hdl/lfsr.v
}

ip::add_implementation_sources $core xdc/cdc_timing.xdc

ip::add_subcore    $core "oscar-rc.dev:zbnt:common:1.0"
ip::add_gui_script $core xgui/eth_latency_measurer.tcl
ip::add_gui_utils  $core xgui/eth_latency_measurer.gtcl

ip::set_top $core eth_latency_measurer_w hdl/eth_latency_measurer_wrapper.v

# Parameters

ip::set_param_disp_name $core C_AXI_WIDTH "AXI Data Width"
ip::set_param_list      $core C_AXI_WIDTH {32 64}

ip::set_param_disp_name $core C_AXIS_LOG_ENABLE "Enable log"
ip::set_param_format    $core C_AXIS_LOG_ENABLE bool
ip::set_param_value     $core C_AXIS_LOG_ENABLE true

ip::set_param_disp_name $core C_AXIS_LOG_WIDTH "Width"
ip::set_param_list      $core C_AXIS_LOG_WIDTH {64 128 256}

# Interfaces

ip::add_axi_interface $core S_AXI slave {
	AW {ADDR PROT VALID READY}
	W  {DATA STRB VALID READY}
	B  {RESP VALID READY}
	AR {ADDR PROT VALID READY}
	R  {DATA RESP VALID READY}
}

ip::add_axis_interface $core M_AXIS_LOG  master {DATA LAST VALID READY}
ip::add_axis_interface $core M_AXIS_MAIN master {DATA USER LAST VALID READY}
ip::add_axis_interface $core M_AXIS_LOOP master {DATA USER LAST VALID READY}
ip::add_axis_interface $core S_AXIS_MAIN slave  {DATA USER LAST VALID}
ip::add_axis_interface $core S_AXIS_LOOP slave  {DATA USER LAST VALID}

ip::add_clk_interface $core s_axi_clk       slave {} s_axi_resetn S_AXI:M_AXIS_LOG:M_AXIS_MAIN:M_AXIS_LOOP
ip::add_clk_interface $core s_axis_main_clk slave {} {}           S_AXIS_MAIN
ip::add_clk_interface $core s_axis_loop_clk slave {} {}           S_AXIS_LOOP
ip::add_rst_interface $core s_axi_resetn    slave ACTIVE_LOW

ip::set_iface_dependency $core M_AXIS_LOG {$C_AXIS_LOG_ENABLE != 0}

ip::save_core $core

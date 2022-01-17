cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt eth_stats_collector 1.1]

ip::set_disp_name   $core "Ethernet Statistics Collector"
ip::set_description $core "Counts the number of frames and bytes transferred"
ip::set_categories  $core /AXI_Peripheral

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/eth_stats_collector_wrapper.v
	hdl/eth_stats_collector.sv
	hdl/eth_stats_adder.sv
	hdl/eth_stats_collector_axi.sv
	hdl/eth_stats_collector_axis_log.sv
	hdl/eth_stats_counter_rx.sv
	hdl/eth_stats_counter_tx.sv
}

ip::add_implementation_sources $core xdc/cdc_timing.xdc

ip::add_subcore    $core "oscar-rc.dev:zbnt:common:1.0"
ip::add_gui_script $core xgui/eth_stats_collector.tcl
ip::add_gui_utils  $core xgui/eth_stats_collector.gtcl

ip::set_top $core eth_stats_collector_w hdl/eth_stats_collector_wrapper.v

# Parameters

ip::set_param_disp_name $core C_AXI_WIDTH "AXI Data Width"
ip::set_param_list      $core C_AXI_WIDTH {32 64}

ip::set_param_disp_name $core C_USE_TIMER "Use timer"
ip::set_param_format    $core C_USE_TIMER bool
ip::set_param_value     $core C_USE_TIMER true

ip::set_param_disp_name $core C_SHARED_TX_CLK "S_AXI and AXIS_TX in same clock domain"
ip::set_param_format    $core C_SHARED_TX_CLK bool
ip::set_param_value     $core C_SHARED_TX_CLK true

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

ip::add_axis_interface $core M_AXIS_LOG master  {DATA LAST VALID READY}
ip::add_axis_interface $core AXIS_TX    monitor {USER LAST VALID READY}
ip::add_axis_interface $core AXIS_RX    monitor {USER LAST VALID}

ip::add_clk_interface $core clk    slave {} rst_n S_AXI:M_AXIS_LOG
ip::add_clk_interface $core clk_tx slave {} {}    AXIS_TX
ip::add_clk_interface $core clk_rx slave {} {}    AXIS_RX
ip::add_rst_interface $core rst_n  slave ACTIVE_LOW

ip::set_iface_parameters $core AXIS_TX    {TDATA_NUM_BYTES 1}
ip::set_iface_parameters $core AXIS_RX    {TDATA_NUM_BYTES 1}
ip::set_iface_dependency $core M_AXIS_LOG {$C_AXIS_LOG_ENABLE != 0}

ip::set_port_dependencies $core {
	current_time {$C_USE_TIMER != 0}
	time_running {$C_USE_TIMER != 0}
}

ip::set_port_drivers $core {
	axis_tx_tuser  0
	axis_tx_tlast  0
	axis_tx_tready 1

	axis_rx_tuser  0
	axis_rx_tlast  0

	current_time   0
	time_running   1
}

ip::save_core $core

cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt eth_frame_detector 1.1]

ip::set_disp_name   $core "Ethernet Frame Detector"
ip::set_description $core "Detects and captures or modifies frames based on configurable scripts"
ip::set_categories  $core /AXI_Peripheral

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/eth_frame_detector_wrapper.v
	hdl/eth_frame_detector.sv
	hdl/alu.sv
	hdl/eth_frame_detector_axi.sv
	hdl/eth_frame_detector_axi_dram.sv
	hdl/eth_frame_detector_axis_log.sv
	hdl/eth_frame_loop.sv
	hdl/eth_frame_loop_compare.sv
	hdl/eth_frame_loop_csum.sv
	hdl/eth_frame_loop_edit.sv
	hdl/eth_frame_loop_extract.sv
	hdl/eth_frame_loop_fifo.sv
	hdl/eth_frame_loop_rx.sv
	hdl/eth_frame_loop_tx.sv
	hdl/lfsr.v
	hdl/multiplier.sv
	hdl/script_mem.sv
}

ip::add_synth_sources          $core xdc/memory_opt.xdc
ip::add_implementation_sources $core xdc/cdc_timing.xdc

ip::add_subcore    $core "oscar-rc.dev:zbnt:common:1.0"
ip::add_gui_script $core xgui/eth_frame_detector.tcl
ip::add_gui_utils  $core xgui/eth_frame_detector.gtcl

ip::set_top $core eth_frame_detector_w hdl/eth_frame_detector_wrapper.v

# Parameters

ip::set_param_disp_name $core C_AXI_WIDTH "AXI Data Width"
ip::set_param_list      $core C_AXI_WIDTH {32 64}

ip::set_param_disp_name $core C_AXIS_LOG_ENABLE "Enable capture unit"
ip::set_param_format    $core C_AXIS_LOG_ENABLE bool
ip::set_param_value     $core C_AXIS_LOG_ENABLE true

ip::set_param_disp_name $core C_AXIS_LOG_WIDTH "AXIS Width"
ip::set_param_list      $core C_AXIS_LOG_WIDTH {64 128 256}

ip::set_param_disp_name $core C_ENABLE_COMPARE "Enable comparison unit"
ip::set_param_format    $core C_ENABLE_COMPARE bool
ip::set_param_value     $core C_ENABLE_COMPARE true

ip::set_param_disp_name $core C_ENABLE_EDIT "Enable editing unit"
ip::set_param_format    $core C_ENABLE_EDIT bool
ip::set_param_value     $core C_ENABLE_EDIT true

ip::set_param_disp_name $core C_ENABLE_CHECKSUM "Enable checksum correction unit"
ip::set_param_format    $core C_ENABLE_CHECKSUM bool
ip::set_param_value     $core C_ENABLE_CHECKSUM true

ip::set_param_disp_name $core C_NUM_SCRIPTS "Number of scripts"
ip::set_param_range     $core C_NUM_SCRIPTS 1 8

ip::set_param_disp_name $core C_MAX_SCRIPT_SIZE "Maximum script size"
ip::set_param_list      $core C_MAX_SCRIPT_SIZE {2048 4096 8192 16384}

ip::set_param_disp_name $core C_EXTRACT_FIFO_SIZE "Extraction FIFO"
ip::set_param_list      $core C_EXTRACT_FIFO_SIZE {2048 4096 8192 16384 32768 65536}

ip::set_param_disp_name $core C_SHARED_RX_CLK "S_AXI and S_AXIS_A/B share clock domain"
ip::set_param_format    $core C_SHARED_RX_CLK bool
ip::set_param_value     $core C_SHARED_RX_CLK false

ip::set_param_disp_name $core C_SHARED_TX_CLK "S_AXI and M_AXIS_A/B share clock domain"
ip::set_param_format    $core C_SHARED_TX_CLK bool
ip::set_param_value     $core C_SHARED_TX_CLK false

ip::set_param_disp_name $core C_LOOP_FIFO_A_SIZE "Transmission FIFO A"
ip::set_param_list      $core C_LOOP_FIFO_A_SIZE {2048 4096 8192 16384 32768 65536}

ip::set_param_disp_name $core C_LOOP_FIFO_B_SIZE "Transmission FIFO B"
ip::set_param_list      $core C_LOOP_FIFO_B_SIZE {128 256 512 1024}

ip::set_param_disp_name $core C_DEBUG_OUTPUTS "Enable debug outputs"
ip::set_param_format    $core C_DEBUG_OUTPUTS bool
ip::set_param_value     $core C_DEBUG_OUTPUTS false

# Interfaces

ip::add_axi_interface $core S_AXI slave {
	AW {ADDR PROT VALID READY}
	W  {DATA STRB VALID READY}
	B  {RESP VALID READY}
	AR {ADDR PROT VALID READY}
	R  {DATA RESP VALID READY}
}

ip::add_axis_interface $core M_AXIS_LOG_A    master {DATA LAST VALID READY}
ip::add_axis_interface $core M_AXIS_LOG_B    master {DATA LAST VALID READY}
ip::add_axis_interface $core M_AXIS_A        master {DATA USER LAST VALID READY}
ip::add_axis_interface $core M_AXIS_B        master {DATA USER LAST VALID READY}
ip::add_axis_interface $core S_AXIS_A        slave  {DATA USER LAST VALID}
ip::add_axis_interface $core S_AXIS_B        slave  {DATA USER LAST VALID}
ip::add_axis_interface $core DBG_A_RX2CMP    master {DATA USER LAST VALID}
ip::add_axis_interface $core DBG_A_CMP2EDIT  master {DATA USER LAST VALID}
ip::add_axis_interface $core DBG_A_EDIT2CSUM master {DATA USER LAST VALID}
ip::add_axis_interface $core DBG_A_CSUM2FIFO master {DATA USER LAST VALID}
ip::add_axis_interface $core DBG_B_RX2CMP    master {DATA USER LAST VALID}
ip::add_axis_interface $core DBG_B_CMP2EDIT  master {DATA USER LAST VALID}
ip::add_axis_interface $core DBG_B_EDIT2CSUM master {DATA USER LAST VALID}
ip::add_axis_interface $core DBG_B_CSUM2FIFO master {DATA USER LAST VALID}

ip::add_clk_interface $core s_axi_clk    slave {} s_axi_resetn S_AXI:M_AXIS_LOG_A:M_AXIS_LOG_B
ip::add_clk_interface $core m_axis_a_clk slave {} {}           M_AXIS_A
ip::add_clk_interface $core m_axis_b_clk slave {} {}           M_AXIS_B
ip::add_clk_interface $core s_axis_a_clk slave {} {}           S_AXIS_A:DBG_A_RX2CMP:DBG_A_CMP2EDIT:DBG_A_EDIT2CSUM:DBG_A_CSUM2FIFO
ip::add_clk_interface $core s_axis_b_clk slave {} {}           S_AXIS_B:DBG_B_RX2CMP:DBG_B_CMP2EDIT:DBG_B_EDIT2CSUM:DBG_B_CSUM2FIFO
ip::add_rst_interface $core s_axi_resetn slave ACTIVE_LOW

ip::set_iface_dependencies $core {
	M_AXIS_LOG_A    {$C_AXIS_LOG_ENABLE != 0}
	M_AXIS_LOG_B    {$C_AXIS_LOG_ENABLE != 0}
	DBG_A_RX2CMP    {$C_DEBUG_OUTPUTS}
	DBG_A_CMP2EDIT  {$C_DEBUG_OUTPUTS}
	DBG_A_EDIT2CSUM {$C_DEBUG_OUTPUTS}
	DBG_A_CSUM2FIFO {$C_DEBUG_OUTPUTS}
	DBG_B_RX2CMP    {$C_DEBUG_OUTPUTS}
	DBG_B_CMP2EDIT  {$C_DEBUG_OUTPUTS}
	DBG_B_EDIT2CSUM {$C_DEBUG_OUTPUTS}
	DBG_B_CSUM2FIFO {$C_DEBUG_OUTPUTS}
}

ip::save_core $core

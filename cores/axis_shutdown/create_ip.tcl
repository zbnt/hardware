cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt axis_shutdown 1.0]

ip::set_disp_name   $core "AXIS Shutdown"
ip::set_description $core "Allows disabling an AXIS interface without interrupting a packet"
ip::set_categories  $core /AXI_Infrastructure

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/axis_shutdown_wrapper.v
	hdl/axis_shutdown.sv
}

ip::add_gui_script $core xgui/axis_shutdown.tcl
ip::add_gui_utils  $core xgui/axis_shutdown.gtcl

ip::set_top $core axis_shutdown_w hdl/axis_shutdown_wrapper.v

# Parameters

ip::set_param_disp_name $core C_CDC_STAGES "Stages"
ip::set_param_range     $core C_CDC_STAGES 0 16

ip::set_param_disp_name $core C_AXIS_TID_WIDTH "tid"
ip::set_param_range     $core C_AXIS_TID_WIDTH 1 8

ip::set_param_disp_name $core C_AXIS_TDATA_WIDTH "tdata"
ip::set_param_range     $core C_AXIS_TDATA_WIDTH 8 65536

ip::set_param_disp_name $core C_AXIS_TUSER_WIDTH "tuser"
ip::set_param_range     $core C_AXIS_TUSER_WIDTH 1 65536

ip::set_param_disp_name $core C_AXIS_TDEST_WIDTH "tdest"
ip::set_param_range     $core C_AXIS_TDEST_WIDTH 1 4

ip::set_param_disp_name $core C_AXIS_HAS_TID "tid"
ip::set_param_format    $core C_AXIS_HAS_TID bool
ip::set_param_value     $core C_AXIS_HAS_TID false

ip::set_param_disp_name $core C_AXIS_HAS_TUSER "tuser"
ip::set_param_format    $core C_AXIS_HAS_TUSER bool
ip::set_param_value     $core C_AXIS_HAS_TUSER false

ip::set_param_disp_name $core C_AXIS_HAS_TDEST "tdest"
ip::set_param_format    $core C_AXIS_HAS_TDEST bool
ip::set_param_value     $core C_AXIS_HAS_TDEST false

ip::set_param_disp_name $core C_AXIS_HAS_TSTRB "tstrb"
ip::set_param_format    $core C_AXIS_HAS_TSTRB bool
ip::set_param_value     $core C_AXIS_HAS_TSTRB false

ip::set_param_disp_name $core C_AXIS_HAS_TKEEP "tkeep"
ip::set_param_format    $core C_AXIS_HAS_TKEEP bool
ip::set_param_value     $core C_AXIS_HAS_TKEEP false

ip::set_param_disp_name $core C_AXIS_HAS_TLAST "tlast"
ip::set_param_format    $core C_AXIS_HAS_TLAST bool
ip::set_param_value     $core C_AXIS_HAS_TLAST true

ip::set_param_disp_name $core C_AXIS_HAS_TREADY "tready"
ip::set_param_format    $core C_AXIS_HAS_TREADY bool
ip::set_param_value     $core C_AXIS_HAS_TREADY true

ip::set_param_disp_name $core C_TREADY_IN_SHUTDOWN "Assert TREADY while in shutdown"
ip::set_param_format    $core C_TREADY_IN_SHUTDOWN bool
ip::set_param_value     $core C_TREADY_IN_SHUTDOWN false

# Interfaces

ip::add_axis_interface $core M_AXIS master {ID DATA USER DEST STRB KEEP LAST VALID READY}
ip::add_axis_interface $core S_AXIS slave  {ID DATA USER DEST STRB KEEP LAST VALID READY}

ip::add_clk_interface $core clk          slave {} rst_n M_AXIS:S_AXIS
ip::add_clk_interface $core shutdown_clk slave {} {}    {}
ip::add_rst_interface $core rst_n        slave ACTIVE_LOW

ip::set_iface_dependency $core shutdown_clk {$C_CDC_STAGES != 0}

foreach i {m s} {
	ip::set_port_dependencies $core [list       \
		${i}_axis_tid    {$C_AXIS_HAS_TID}    \
		${i}_axis_tuser  {$C_AXIS_HAS_TUSER}  \
		${i}_axis_tdest  {$C_AXIS_HAS_TDEST}  \
		${i}_axis_tstrb  {$C_AXIS_HAS_TSTRB}  \
		${i}_axis_tkeep  {$C_AXIS_HAS_TKEEP}  \
		${i}_axis_tlast  {$C_AXIS_HAS_TLAST}  \
		${i}_axis_tready {$C_AXIS_HAS_TREADY} \
	]
}

ip::save_core $core

cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt util_irq2axis 1.0]

ip::set_disp_name   $core "IRQ to AXI-Stream"
ip::set_description $core "IRQ to AXI-Stream"
ip::set_categories  $core /AXI_Infrastructure

ip::set_supported_families $core {
	kintex7 Production
}

# Sources

ip::add_sources $core {
	hdl/util_irq2axis.v
}

ip::add_gui_script $core xgui/util_irq2axis.tcl

ip::set_top $core util_irq2axis hdl/util_irq2axis.v

# Parameters

ip::set_param_disp_name $core C_IRQ_NUMBER "IRQ Number"
ip::set_param_range     $core C_IRQ_NUMBER 0 31

# Interfaces

ip::add_axis_interface $core M_AXIS master {DATA VALID READY}
ip::add_irq_interface  $core irq    slave  LEVEL_HIGH
ip::add_clk_interface  $core clk    slave  {} rst_n M_AXIS
ip::add_rst_interface  $core rst_n  slave  ACTIVE_LOW

ip::save_core $core

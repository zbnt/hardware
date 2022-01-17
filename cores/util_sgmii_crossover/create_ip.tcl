cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt util_sgmii_crossover 1.0]

ip::set_disp_name   $core "SGMII RX Crossover"
ip::set_description $core "SGMII RX Crossover"
ip::set_categories  $core /BaseIP

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/util_sgmii_crossover.v
}

ip::add_gui_script $core xgui/util_sgmii_crossover.tcl

ip::set_top $core util_sgmii_crossover hdl/util_sgmii_crossover.v

# Interfaces

ip::add_sgmii_interface $core S_SGMII_A slave  {TXP TXN RXP RXN}
ip::add_sgmii_interface $core S_SGMII_B slave  {TXP TXN RXP RXN}
ip::add_sgmii_interface $core M_SGMII_A master {TXP TXN RXP RXN}
ip::add_sgmii_interface $core M_SGMII_B master {TXP TXN RXP RXN}

ip::save_core $core

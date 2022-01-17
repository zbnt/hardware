cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt util_gmii_slice 1.0]

ip::set_disp_name   $core "GMII Slice"
ip::set_description $core "GMII Slice"
ip::set_categories  $core /BaseIP

ip::set_supported_families $core {
	kintex7   Production
	zynq      Production
	zynquplus Production
}

# Sources

ip::add_sources $core {
	hdl/util_gmii_slice.v
}

ip::add_gui_script $core xgui/util_gmii_slice.tcl

ip::set_top $core util_gmii_slice hdl/util_gmii_slice.v

# Interfaces

ip::add_gmii_interface $core S_GMII    slave  {RXD RX_DV RX_ER TXD TX_EN TX_ER}
ip::add_gmii_interface $core M_GMII_RX master {RXD RX_DV RX_ER TXD TX_EN TX_ER}
ip::add_gmii_interface $core M_GMII_TX master {RXD RX_DV RX_ER TXD TX_EN TX_ER}

ip::set_port_drivers $core {
	m_gmii_rx_rxd   0
	m_gmii_rx_rx_dv 0
	m_gmii_rx_rx_er 0
	m_gmii_tx_rxd   0
	m_gmii_tx_rx_dv 0
	m_gmii_tx_rx_er 0
}

ip::save_core $core


# Voltage

set_property INTERNAL_VREF 0.60 [get_iobanks 65]

# Reference clock

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets */gmii_to_sgmii/sgmii_port3_rx/inst/clock_reset_i/iclkbuf/O]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD DIFF_SSTL12 ODT RTT_48} [get_ports eth96_clk_p]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD DIFF_SSTL12 ODT RTT_48} [get_ports eth96_clk_n]

# MDIO

set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS18} [get_ports mdio]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS18} [get_ports mdc]

# ETH0

set_property -dict {PACKAGE_PIN N2 IOSTANDARD DIFF_SSTL12 ODT RTT_48} [get_ports eth96_p0_rxp]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD DIFF_SSTL12 ODT RTT_48} [get_ports eth96_p0_rxn]
set_property -dict {PACKAGE_PIN M5 IOSTANDARD DIFF_SSTL12} [get_ports eth96_p0_txp]
set_property -dict {PACKAGE_PIN M4 IOSTANDARD DIFF_SSTL12} [get_ports eth96_p0_txn]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS18} [get_ports eth96_p0_rst_n]

# ETH1

set_property -dict {PACKAGE_PIN N5 IOSTANDARD DIFF_SSTL12 ODT RTT_48} [get_ports eth96_p1_rxp]
set_property -dict {PACKAGE_PIN N4 IOSTANDARD DIFF_SSTL12 ODT RTT_48} [get_ports eth96_p1_rxn]
set_property -dict {PACKAGE_PIN L2 IOSTANDARD DIFF_SSTL12} [get_ports eth96_p1_txp]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD DIFF_SSTL12} [get_ports eth96_p1_txn]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS18} [get_ports eth96_p1_rst_n]

# ETH2

set_property -dict {PACKAGE_PIN G1 IOSTANDARD DIFF_SSTL12 ODT RTT_48} [get_ports eth96_p2_rxp]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD DIFF_SSTL12 ODT RTT_48} [get_ports eth96_p2_rxn]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD DIFF_SSTL12} [get_ports eth96_p2_txp]
set_property -dict {PACKAGE_PIN C3 IOSTANDARD DIFF_SSTL12} [get_ports eth96_p2_txn]
set_property -dict {PACKAGE_PIN A7 IOSTANDARD LVCMOS18} [get_ports eth96_p2_rst_n]

# ETH3

set_property -dict {PACKAGE_PIN T3 IOSTANDARD DIFF_SSTL12 ODT RTT_48} [get_ports eth96_p3_rxp]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD DIFF_SSTL12 ODT RTT_48} [get_ports eth96_p3_rxn]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD DIFF_SSTL12} [get_ports eth96_p3_txp]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD DIFF_SSTL12} [get_ports eth96_p3_txn]
set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVCMOS18} [get_ports eth96_p3_rst_n]

# Unused lanes

set_property -dict {PACKAGE_PIN J3 IOSTANDARD DIFF_SSTL12} [get_ports eth96_unused_rxp]
set_property -dict {PACKAGE_PIN J2 IOSTANDARD DIFF_SSTL12} [get_ports eth96_unused_rxn]
set_property -dict {PACKAGE_PIN R4 IOSTANDARD DIFF_SSTL12} [get_ports eth96_unused_txp]
set_property -dict {PACKAGE_PIN T4 IOSTANDARD DIFF_SSTL12} [get_ports eth96_unused_txn]

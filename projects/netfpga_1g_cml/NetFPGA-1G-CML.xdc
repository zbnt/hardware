
# Voltage config

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property config_mode BPI16 [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE TYPE1 [current_design]

# System clock and reset

create_clock -add -name system_clk_p -period 5.0 -waveform {0 2.5} [get_ports system_clk_p]
set_property -dict { PACKAGE_PIN AA3   IOSTANDARD LVDS } [get_ports system_clk_p]
set_property -dict { PACKAGE_PIN AA2   IOSTANDARD LVDS } [get_ports system_clk_n]
set_property -dict { PACKAGE_PIN AA8   IOSTANDARD LVCMOS18 } [get_ports rst_n]

# LEDs

set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { led_0 }]
set_property -dict { PACKAGE_PIN AF14  IOSTANDARD LVCMOS18 } [get_ports { led_1 }]
set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS33 } [get_ports { led_2 }]
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS18 } [get_ports { led_3 }]

# PCIe

create_clock -add -name pcie_clk_p -period 10.0 -waveform {0 5} [get_ports pcie_clk_p]
set_property -dict { PACKAGE_PIN H6 } [get_ports { pcie_clk_p }]
set_property -dict { PACKAGE_PIN H5 } [get_ports { pcie_clk_n }]

set_property -dict { PACKAGE_PIN H2 } [get_ports { pcie_txp[0] }]
set_property -dict { PACKAGE_PIN H1 } [get_ports { pcie_txn[0] }]
set_property -dict { PACKAGE_PIN J4 } [get_ports { pcie_rxp[0] }]
set_property -dict { PACKAGE_PIN J3 } [get_ports { pcie_rxn[0] }]

set_property -dict { PACKAGE_PIN K2 } [get_ports { pcie_txp[1] }]
set_property -dict { PACKAGE_PIN K1 } [get_ports { pcie_txn[1] }]
set_property -dict { PACKAGE_PIN L4 } [get_ports { pcie_rxp[1] }]
set_property -dict { PACKAGE_PIN L3 } [get_ports { pcie_rxn[1] }]

set_property -dict { PACKAGE_PIN M2 } [get_ports { pcie_txp[2] }]
set_property -dict { PACKAGE_PIN M1 } [get_ports { pcie_txn[2] }]
set_property -dict { PACKAGE_PIN N4 } [get_ports { pcie_rxp[2] }]
set_property -dict { PACKAGE_PIN N3 } [get_ports { pcie_rxn[2] }]

set_property -dict { PACKAGE_PIN P2 } [get_ports { pcie_txp[3] }]
set_property -dict { PACKAGE_PIN P1 } [get_ports { pcie_txn[3] }]
set_property -dict { PACKAGE_PIN R4 } [get_ports { pcie_rxp[3] }]
set_property -dict { PACKAGE_PIN R3 } [get_ports { pcie_rxn[3] }]

set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33  PULLUP TRUE } [get_ports pcie_perstn]

# BPI Flash

set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports bpi_wen]
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports bpi_oen]
set_property -dict { PACKAGE_PIN C23   IOSTANDARD LVCMOS33 } [get_ports bpi_ce_n]
set_property -dict { PACKAGE_PIN D20   IOSTANDARD LVCMOS33 } [get_ports bpi_adv_ldn]
set_property -dict { PACKAGE_PIN J23   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[0] }]
set_property -dict { PACKAGE_PIN K23   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[1] }]
set_property -dict { PACKAGE_PIN K22   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[2] }]
set_property -dict { PACKAGE_PIN L22   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[3] }]
set_property -dict { PACKAGE_PIN J25   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[4] }]
set_property -dict { PACKAGE_PIN J24   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[5] }]
set_property -dict { PACKAGE_PIN H22   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[6] }]
set_property -dict { PACKAGE_PIN H24   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[7] }]
set_property -dict { PACKAGE_PIN H23   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[8] }]
set_property -dict { PACKAGE_PIN G21   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[9] }]
set_property -dict { PACKAGE_PIN H21   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[10] }]
set_property -dict { PACKAGE_PIN H26   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[11] }]
set_property -dict { PACKAGE_PIN J26   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[12] }]
set_property -dict { PACKAGE_PIN E26   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[13] }]
set_property -dict { PACKAGE_PIN F25   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[14] }]
set_property -dict { PACKAGE_PIN G26   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[15] }]
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[16] }]
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[17] }]
set_property -dict { PACKAGE_PIN L20   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[18] }]
set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[19] }]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[20] }]
set_property -dict { PACKAGE_PIN J20   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[21] }]
set_property -dict { PACKAGE_PIN K20   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[22] }]
set_property -dict { PACKAGE_PIN G20   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[23] }]
set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[24] }]
set_property -dict { PACKAGE_PIN E20   IOSTANDARD LVCMOS33 } [get_ports { bpi_addr[25] }]
set_property -dict { PACKAGE_PIN B24   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[0] }]
set_property -dict { PACKAGE_PIN A25   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[1] }]
set_property -dict { PACKAGE_PIN B22   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[2] }]
set_property -dict { PACKAGE_PIN A22   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[3] }]
set_property -dict { PACKAGE_PIN A23   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[4] }]
set_property -dict { PACKAGE_PIN A24   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[5] }]
set_property -dict { PACKAGE_PIN D26   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[6] }]
set_property -dict { PACKAGE_PIN C26   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[7] }]
set_property -dict { PACKAGE_PIN C24   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[8] }]
set_property -dict { PACKAGE_PIN D21   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[9] }]
set_property -dict { PACKAGE_PIN C22   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[10] }]
set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[11] }]
set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[12] }]
set_property -dict { PACKAGE_PIN E22   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[13] }]
set_property -dict { PACKAGE_PIN C21   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[14] }]
set_property -dict { PACKAGE_PIN B21   IOSTANDARD LVCMOS33 } [get_ports { bpi_dq[15] }]

# ETH0

set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports phy0_rstn]

set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS18 } [get_ports { phy0_rgmii_td[0] }]
set_property -dict { PACKAGE_PIN D8    IOSTANDARD LVCMOS18 } [get_ports { phy0_rgmii_td[1] }]
set_property -dict { PACKAGE_PIN G9    IOSTANDARD LVCMOS18 } [get_ports { phy0_rgmii_td[2] }]
set_property -dict { PACKAGE_PIN H9    IOSTANDARD LVCMOS18 } [get_ports { phy0_rgmii_td[3] }]
set_property -dict { PACKAGE_PIN H8    IOSTANDARD LVCMOS18 } [get_ports phy0_rgmii_tx_ctl]
set_property -dict { PACKAGE_PIN B9    IOSTANDARD LVCMOS18 } [get_ports phy0_rgmii_txc]

set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS18 } [get_ports { phy0_rgmii_rd[0] }]
set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS18 } [get_ports { phy0_rgmii_rd[1] }]
set_property -dict { PACKAGE_PIN B10   IOSTANDARD LVCMOS18 } [get_ports { phy0_rgmii_rd[2] }]
set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS18 } [get_ports { phy0_rgmii_rd[3] }]
set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS18 } [get_ports phy0_rgmii_rx_ctl]
set_property -dict { PACKAGE_PIN E10   IOSTANDARD LVCMOS18 } [get_ports phy0_rgmii_rxc]

# ETH1

set_property -dict { PACKAGE_PIN E25   IOSTANDARD LVCMOS33 } [get_ports phy1_rstn]

set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS18 } [get_ports { phy1_rgmii_td[0] }]
set_property -dict { PACKAGE_PIN G10   IOSTANDARD LVCMOS18 } [get_ports { phy1_rgmii_td[1] }]
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS18 } [get_ports { phy1_rgmii_td[2] }]
set_property -dict { PACKAGE_PIN F9    IOSTANDARD LVCMOS18 } [get_ports { phy1_rgmii_td[3] }]
set_property -dict { PACKAGE_PIN F8    IOSTANDARD LVCMOS18 } [get_ports phy1_rgmii_tx_ctl]
set_property -dict { PACKAGE_PIN J10   IOSTANDARD LVCMOS18 } [get_ports phy1_rgmii_txc]

set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS18 } [get_ports { phy1_rgmii_rd[0] }]
set_property -dict { PACKAGE_PIN C9    IOSTANDARD LVCMOS18 } [get_ports { phy1_rgmii_rd[1] }]
set_property -dict { PACKAGE_PIN D11   IOSTANDARD LVCMOS18 } [get_ports { phy1_rgmii_rd[2] }]
set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS18 } [get_ports { phy1_rgmii_rd[3] }]
set_property -dict { PACKAGE_PIN A12   IOSTANDARD LVCMOS18 } [get_ports phy1_rgmii_rx_ctl]
set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS18 } [get_ports phy1_rgmii_rxc]

# ETH2

set_property -dict { PACKAGE_PIN K21   IOSTANDARD LVCMOS33 } [get_ports phy2_rstn]

set_property -dict { PACKAGE_PIN G12   IOSTANDARD LVCMOS18 } [get_ports { phy2_rgmii_td[0] }]
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS18 } [get_ports { phy2_rgmii_td[1] }]
set_property -dict { PACKAGE_PIN F12   IOSTANDARD LVCMOS18 } [get_ports { phy2_rgmii_td[2] }]
set_property -dict { PACKAGE_PIN H11   IOSTANDARD LVCMOS18 } [get_ports { phy2_rgmii_td[3] }]
set_property -dict { PACKAGE_PIN F10   IOSTANDARD LVCMOS18 } [get_ports phy2_rgmii_tx_ctl]
set_property -dict { PACKAGE_PIN E13   IOSTANDARD LVCMOS18 } [get_ports phy2_rgmii_txc]

set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS18 } [get_ports { phy2_rgmii_rd[0] }]
set_property -dict { PACKAGE_PIN B14   IOSTANDARD LVCMOS18 } [get_ports { phy2_rgmii_rd[1] }]
set_property -dict { PACKAGE_PIN E12   IOSTANDARD LVCMOS18 } [get_ports { phy2_rgmii_rd[2] }]
set_property -dict { PACKAGE_PIN D13   IOSTANDARD LVCMOS18 } [get_ports { phy2_rgmii_rd[3] }]
set_property -dict { PACKAGE_PIN C13   IOSTANDARD LVCMOS18 } [get_ports phy2_rgmii_rx_ctl]
set_property -dict { PACKAGE_PIN E11   IOSTANDARD LVCMOS18 } [get_ports phy2_rgmii_rxc]

# ETH3

set_property -dict { PACKAGE_PIN L23   IOSTANDARD LVCMOS33 } [get_ports phy3_rstn]

set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS18 } [get_ports { phy3_rgmii_td[0] }]
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS18 } [get_ports { phy3_rgmii_td[1] }]
set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS18 } [get_ports { phy3_rgmii_td[2] }]
set_property -dict { PACKAGE_PIN H13   IOSTANDARD LVCMOS18 } [get_ports { phy3_rgmii_td[3] }]
set_property -dict { PACKAGE_PIN J11   IOSTANDARD LVCMOS18 } [get_ports phy3_rgmii_tx_ctl]
set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS18 } [get_ports phy3_rgmii_txc]

set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS18 } [get_ports { phy3_rgmii_rd[0] }]
set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS18 } [get_ports { phy3_rgmii_rd[1] }]
set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS18 } [get_ports { phy3_rgmii_rd[2] }]
set_property -dict { PACKAGE_PIN H12   IOSTANDARD LVCMOS18 } [get_ports { phy3_rgmii_rd[3] }]
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS18 } [get_ports phy3_rgmii_rx_ctl]
set_property -dict { PACKAGE_PIN G11   IOSTANDARD LVCMOS18 } [get_ports phy3_rgmii_rxc]

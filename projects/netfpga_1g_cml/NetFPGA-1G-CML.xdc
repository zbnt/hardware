
# Voltage config

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property config_mode BPI16 [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE TYPE1 [current_design]

# System clock and reset

set_property -dict { PACKAGE_PIN AA3   IOSTANDARD LVDS } [get_ports system_clk_p]
set_property -dict { PACKAGE_PIN AA2   IOSTANDARD LVDS } [get_ports system_clk_n]
set_property -dict { PACKAGE_PIN AA8   IOSTANDARD LVCMOS18 } [get_ports rst_n]

# LEDs

set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN AF14  IOSTANDARD LVCMOS18 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS33 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS18 } [get_ports { led[3] }]

# PCIe

set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33  PULLUP TRUE } [get_ports pcie_perstn]

set_property LOC IBUFDS_GTE2_X0Y0 [get_cells -hier -filter { NAME =~ */pcie_refclk_ibufds/*/*IBUFDS_GTE2_I }]
set_property LOC GTXE2_CHANNEL_X0Y3 [get_cells -hier -filter { NAME =~ */pipe_lane[0].gt_wrapper_i/gtx_channel.gtxe2_channel_i }]
set_property LOC GTXE2_CHANNEL_X0Y2 [get_cells -hier -filter { NAME =~ */pipe_lane[1].gt_wrapper_i/gtx_channel.gtxe2_channel_i }]
set_property LOC GTXE2_CHANNEL_X0Y1 [get_cells -hier -filter { NAME =~ */pipe_lane[2].gt_wrapper_i/gtx_channel.gtxe2_channel_i }]
set_property LOC GTXE2_CHANNEL_X0Y0 [get_cells -hier -filter { NAME =~ */pipe_lane[3].gt_wrapper_i/gtx_channel.gtxe2_channel_i }]

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

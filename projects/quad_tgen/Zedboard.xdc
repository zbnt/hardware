
# Fix double clock delay

set_property CLKOUT1_PHASE 0 [get_cells -hier -filter { NAME =~ */tri_mode_ethernet_mac_support_clocking_i/mmcm_adv_inst }]

# Reference clock

set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVDS_25   DIFF_TERM TRUE } [get_ports ethfmc_clk_p]
set_property -dict { PACKAGE_PIN L19   IOSTANDARD LVDS_25   DIFF_TERM TRUE } [get_ports ethfmc_clk_n]
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS25 } [get_ports ethfmc_clk_oe]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS25 } [get_ports ethfmc_clk_fsel]

# LEDs

set_property -dict { PACKAGE_PIN T22   IOSTANDARD LVCMOS33 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN T21   IOSTANDARD LVCMOS33 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN U22   IOSTANDARD LVCMOS33 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN U21   IOSTANDARD LVCMOS33 } [get_ports { led[3] }]
set_property -dict { PACKAGE_PIN V22   IOSTANDARD LVCMOS33 } [get_ports { led[4] }]
set_property -dict { PACKAGE_PIN W22   IOSTANDARD LVCMOS33 } [get_ports { led[5] }]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports { led[6] }]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { led[7] }]

# ETH0

set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p0_rst]
set_property -dict { PACKAGE_PIN L22   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p0_mdio_mdio_io]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p0_mdio_mdc]
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p0_rgmii_rxc]
set_property -dict { PACKAGE_PIN M22   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p0_rgmii_txc]
set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p0_rgmii_rx_ctl]
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p0_rgmii_tx_ctl]
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p0_rgmii_rd[0] }]
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p0_rgmii_rd[1] }]
set_property -dict { PACKAGE_PIN N22   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p0_rgmii_rd[2] }]
set_property -dict { PACKAGE_PIN P22   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p0_rgmii_rd[3] }]
set_property -dict { PACKAGE_PIN M21   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p0_rgmii_td[0] }]
set_property -dict { PACKAGE_PIN J21   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p0_rgmii_td[1] }]
set_property -dict { PACKAGE_PIN J22   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p0_rgmii_td[2] }]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p0_rgmii_td[3] }]

# ETH1

set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p1_rst]
set_property -dict { PACKAGE_PIN K20   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p1_mdio_mdio_io]
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p1_mdio_mdc]
set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p1_rgmii_rxc]
set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p1_rgmii_txc]
set_property -dict { PACKAGE_PIN N20   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p1_rgmii_rx_ctl]
set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p1_rgmii_tx_ctl]
set_property -dict { PACKAGE_PIN L21   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p1_rgmii_rd[0] }]
set_property -dict { PACKAGE_PIN R20   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p1_rgmii_rd[1] }]
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p1_rgmii_rd[2] }]
set_property -dict { PACKAGE_PIN R21   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p1_rgmii_rd[3] }]
set_property -dict { PACKAGE_PIN P21   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p1_rgmii_td[0] }]
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p1_rgmii_td[1] }]
set_property -dict { PACKAGE_PIN J20   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p1_rgmii_td[2] }]
set_property -dict { PACKAGE_PIN K21   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p1_rgmii_td[3] }]

# ETH2

set_property -dict { PACKAGE_PIN A19   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p2_rst]
set_property -dict { PACKAGE_PIN C22   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p2_mdio_mdio_io]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p2_mdio_mdc]
set_property -dict { PACKAGE_PIN B19   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p2_rgmii_rxc]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p2_rgmii_txc]
set_property -dict { PACKAGE_PIN G20   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p2_rgmii_rx_ctl]
set_property -dict { PACKAGE_PIN D22   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p2_rgmii_tx_ctl]
set_property -dict { PACKAGE_PIN G21   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p2_rgmii_rd[0] }]
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p2_rgmii_rd[1] }]
set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p2_rgmii_rd[2] }]
set_property -dict { PACKAGE_PIN D15   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p2_rgmii_rd[3] }]
set_property -dict { PACKAGE_PIN G16   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p2_rgmii_td[0] }]
set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p2_rgmii_td[1] }]
set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p2_rgmii_td[2] }]
set_property -dict { PACKAGE_PIN E20   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p2_rgmii_td[3] }]

# ETH3

set_property -dict { PACKAGE_PIN A22   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p3_rst]
set_property -dict { PACKAGE_PIN A21   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p3_mdio_mdio_io]
set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p3_mdio_mdc]
set_property -dict { PACKAGE_PIN D20   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p3_rgmii_rxc]
set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p3_rgmii_txc]
set_property -dict { PACKAGE_PIN C20   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p3_rgmii_rx_ctl]
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS25 } [get_ports ethfmc_p3_rgmii_tx_ctl]
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p3_rgmii_rd[0] }]
set_property -dict { PACKAGE_PIN E21   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p3_rgmii_rd[1] }]
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p3_rgmii_rd[2] }]
set_property -dict { PACKAGE_PIN D21   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p3_rgmii_rd[3] }]
set_property -dict { PACKAGE_PIN C18   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p3_rgmii_td[0] }]
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p3_rgmii_td[1] }]
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p3_rgmii_td[2] }]
set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS25 } [get_ports { ethfmc_p3_rgmii_td[3] }]

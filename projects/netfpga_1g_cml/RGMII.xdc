
## RX constraints

# Port 0

create_clock -period 8.000 -name phy0_rgmii_rxc [get_ports phy0_rgmii_rxc]
create_clock -period 8.000 -name rgmii_rx_clk_0

set_input_delay -clock [get_clocks rgmii_rx_clk_0] -max -1.4 [get_ports { phy0_rgmii_rd[*] phy0_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_0] -min -2.8 [get_ports { phy0_rgmii_rd[*] phy0_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_0] -max -1.4 -clock_fall -add_delay [get_ports { phy0_rgmii_rd[*] phy0_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_0] -min -2.8 -clock_fall -add_delay [get_ports { phy0_rgmii_rd[*] phy0_rgmii_rx_ctl }]

set_false_path -rise_from [get_clocks rgmii_rx_clk_0] -fall_to [get_clocks phy0_rgmii_rxc] -setup
set_false_path -fall_from [get_clocks rgmii_rx_clk_0] -rise_to [get_clocks phy0_rgmii_rxc] -setup
set_false_path -rise_from [get_clocks rgmii_rx_clk_0] -rise_to [get_clocks phy0_rgmii_rxc] -hold
set_false_path -fall_from [get_clocks rgmii_rx_clk_0] -fall_to [get_clocks phy0_rgmii_rxc] -hold

set_multicycle_path -from [get_clocks rgmii_rx_clk_0] -to [get_clocks phy0_rgmii_rxc] -setup 0
set_multicycle_path -from [get_clocks rgmii_rx_clk_0] -to [get_clocks phy0_rgmii_rxc] -hold -1

# Port 1

create_clock -period 8.000 -name phy1_rgmii_rxc [get_ports phy1_rgmii_rxc]
create_clock -period 8.000 -name rgmii_rx_clk_1

set_input_delay -clock [get_clocks rgmii_rx_clk_1] -max -1.4 [get_ports { phy1_rgmii_rd[*] phy1_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_1] -min -2.8 [get_ports { phy1_rgmii_rd[*] phy1_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_1] -max -1.4 -clock_fall -add_delay [get_ports { phy1_rgmii_rd[*] phy1_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_1] -min -2.8 -clock_fall -add_delay [get_ports { phy1_rgmii_rd[*] phy1_rgmii_rx_ctl }]

set_false_path -rise_from [get_clocks rgmii_rx_clk_1] -fall_to [get_clocks phy1_rgmii_rxc] -setup
set_false_path -fall_from [get_clocks rgmii_rx_clk_1] -rise_to [get_clocks phy1_rgmii_rxc] -setup
set_false_path -rise_from [get_clocks rgmii_rx_clk_1] -rise_to [get_clocks phy1_rgmii_rxc] -hold
set_false_path -fall_from [get_clocks rgmii_rx_clk_1] -fall_to [get_clocks phy1_rgmii_rxc] -hold

set_multicycle_path -from [get_clocks rgmii_rx_clk_1] -to [get_clocks phy1_rgmii_rxc] -setup 0
set_multicycle_path -from [get_clocks rgmii_rx_clk_1] -to [get_clocks phy1_rgmii_rxc] -hold -1

# Port 2

create_clock -period 8.000 -name phy2_rgmii_rxc [get_ports phy2_rgmii_rxc]
create_clock -period 8.000 -name rgmii_rx_clk_2

set_input_delay -clock [get_clocks rgmii_rx_clk_2] -max -1.4 [get_ports { phy2_rgmii_rd[*] phy2_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_2] -min -2.8 [get_ports { phy2_rgmii_rd[*] phy2_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_2] -max -1.4 -clock_fall -add_delay [get_ports { phy2_rgmii_rd[*] phy2_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_2] -min -2.8 -clock_fall -add_delay [get_ports { phy2_rgmii_rd[*] phy2_rgmii_rx_ctl }]

set_false_path -rise_from [get_clocks rgmii_rx_clk_2] -fall_to [get_clocks phy2_rgmii_rxc] -setup
set_false_path -fall_from [get_clocks rgmii_rx_clk_2] -rise_to [get_clocks phy2_rgmii_rxc] -setup
set_false_path -rise_from [get_clocks rgmii_rx_clk_2] -rise_to [get_clocks phy2_rgmii_rxc] -hold
set_false_path -fall_from [get_clocks rgmii_rx_clk_2] -fall_to [get_clocks phy2_rgmii_rxc] -hold

set_multicycle_path -from [get_clocks rgmii_rx_clk_2] -to [get_clocks phy2_rgmii_rxc] -setup 0
set_multicycle_path -from [get_clocks rgmii_rx_clk_2] -to [get_clocks phy2_rgmii_rxc] -hold -1

# Port 3

create_clock -period 8.000 -name phy3_rgmii_rxc [get_ports phy3_rgmii_rxc]
create_clock -period 8.000 -name rgmii_rx_clk_3

set_input_delay -clock [get_clocks rgmii_rx_clk_3] -max -1.4 [get_ports { phy3_rgmii_rd[*] phy3_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_3] -min -2.8 [get_ports { phy3_rgmii_rd[*] phy3_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_3] -max -1.4 -clock_fall -add_delay [get_ports { phy3_rgmii_rd[*] phy3_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_3] -min -2.8 -clock_fall -add_delay [get_ports { phy3_rgmii_rd[*] phy3_rgmii_rx_ctl }]

set_false_path -rise_from [get_clocks rgmii_rx_clk_3] -fall_to [get_clocks phy3_rgmii_rxc] -setup
set_false_path -fall_from [get_clocks rgmii_rx_clk_3] -rise_to [get_clocks phy3_rgmii_rxc] -setup
set_false_path -rise_from [get_clocks rgmii_rx_clk_3] -rise_to [get_clocks phy3_rgmii_rxc] -hold
set_false_path -fall_from [get_clocks rgmii_rx_clk_3] -fall_to [get_clocks phy3_rgmii_rxc] -hold

set_multicycle_path -from [get_clocks rgmii_rx_clk_3] -to [get_clocks phy3_rgmii_rxc] -setup 0
set_multicycle_path -from [get_clocks rgmii_rx_clk_3] -to [get_clocks phy3_rgmii_rxc] -hold -1

## TX constraints

# Port 0

set oddr_clk_pin [filter [all_fanin -flat -pin_levels 4 [get_ports phy0_rgmii_txc]] {name =~ *C}]
set oddr_clk [get_clocks -include_generated_clocks -of $oddr_clk_pin]

create_generated_clock -name phy0_rgmii_txc -divide_by 1 -source $oddr_clk_pin [get_ports phy0_rgmii_txc]

set_output_delay -clock phy0_rgmii_txc -max 1.0 -add_delay [get_ports { phy0_rgmii_td[*] phy0_rgmii_tx_ctl }]
set_output_delay -clock phy0_rgmii_txc -min -1.0 -add_delay [get_ports { phy0_rgmii_td[*] phy0_rgmii_tx_ctl }]
set_output_delay -clock phy0_rgmii_txc -max 1.0 -add_delay -clock_fall [get_ports { phy0_rgmii_td[*] phy0_rgmii_tx_ctl }]
set_output_delay -clock phy0_rgmii_txc -min -1.0 -add_delay -clock_fall [get_ports { phy0_rgmii_td[*] phy0_rgmii_tx_ctl }]

set_false_path -rise_from $oddr_clk -fall_to phy0_rgmii_txc -setup
set_false_path -fall_from $oddr_clk -rise_to phy0_rgmii_txc -setup
set_false_path -rise_from $oddr_clk -rise_to phy0_rgmii_txc -hold
set_false_path -fall_from $oddr_clk -fall_to phy0_rgmii_txc -hold

# Port 1

set oddr_clk_pin [filter [all_fanin -flat -pin_levels 4 [get_ports phy1_rgmii_txc]] {name =~ *C}]
set oddr_clk [get_clocks -include_generated_clocks -of $oddr_clk_pin]

create_generated_clock -name phy1_rgmii_txc -divide_by 1 -source $oddr_clk_pin [get_ports phy1_rgmii_txc]

set_output_delay -clock phy1_rgmii_txc -max 1.0 -add_delay [get_ports { phy1_rgmii_td[*] phy1_rgmii_tx_ctl }]
set_output_delay -clock phy1_rgmii_txc -min -1.0 -add_delay [get_ports { phy1_rgmii_td[*] phy1_rgmii_tx_ctl }]
set_output_delay -clock phy1_rgmii_txc -max 1.0 -add_delay -clock_fall [get_ports { phy1_rgmii_td[*] phy1_rgmii_tx_ctl }]
set_output_delay -clock phy1_rgmii_txc -min -1.0 -add_delay -clock_fall [get_ports { phy1_rgmii_td[*] phy1_rgmii_tx_ctl }]

set_false_path -rise_from $oddr_clk -fall_to phy1_rgmii_txc -setup
set_false_path -fall_from $oddr_clk -rise_to phy1_rgmii_txc -setup
set_false_path -rise_from $oddr_clk -rise_to phy1_rgmii_txc -hold
set_false_path -fall_from $oddr_clk -fall_to phy1_rgmii_txc -hold

# Port 2

set oddr_clk_pin [filter [all_fanin -flat -pin_levels 4 [get_ports phy2_rgmii_txc]] {name =~ *C}]
set oddr_clk [get_clocks -include_generated_clocks -of $oddr_clk_pin]

create_generated_clock -name phy2_rgmii_txc -divide_by 1 -source $oddr_clk_pin [get_ports phy2_rgmii_txc]

set_output_delay -clock phy2_rgmii_txc -max 1.0 -add_delay [get_ports { phy2_rgmii_td[*] phy2_rgmii_tx_ctl }]
set_output_delay -clock phy2_rgmii_txc -min -1.0 -add_delay [get_ports { phy2_rgmii_td[*] phy2_rgmii_tx_ctl }]
set_output_delay -clock phy2_rgmii_txc -max 1.0 -add_delay -clock_fall [get_ports { phy2_rgmii_td[*] phy2_rgmii_tx_ctl }]
set_output_delay -clock phy2_rgmii_txc -min -1.0 -add_delay -clock_fall [get_ports { phy2_rgmii_td[*] phy2_rgmii_tx_ctl }]

set_false_path -rise_from $oddr_clk -fall_to phy2_rgmii_txc -setup
set_false_path -fall_from $oddr_clk -rise_to phy2_rgmii_txc -setup
set_false_path -rise_from $oddr_clk -rise_to phy2_rgmii_txc -hold
set_false_path -fall_from $oddr_clk -fall_to phy2_rgmii_txc -hold

# Port 3

set oddr_clk_pin [filter [all_fanin -flat -pin_levels 4 [get_ports phy3_rgmii_txc]] {name =~ *C}]
set oddr_clk [get_clocks -include_generated_clocks -of $oddr_clk_pin]

create_generated_clock -name phy3_rgmii_txc -divide_by 1 -source $oddr_clk_pin [get_ports phy3_rgmii_txc]

set_output_delay -clock phy3_rgmii_txc -max 1.0 -add_delay [get_ports { phy3_rgmii_td[*] phy3_rgmii_tx_ctl }]
set_output_delay -clock phy3_rgmii_txc -min -1.0 -add_delay [get_ports { phy3_rgmii_td[*] phy3_rgmii_tx_ctl }]
set_output_delay -clock phy3_rgmii_txc -max 1.0 -add_delay -clock_fall [get_ports { phy3_rgmii_td[*] phy3_rgmii_tx_ctl }]
set_output_delay -clock phy3_rgmii_txc -min -1.0 -add_delay -clock_fall [get_ports { phy3_rgmii_td[*] phy3_rgmii_tx_ctl }]

set_false_path -rise_from $oddr_clk -fall_to phy3_rgmii_txc -setup
set_false_path -fall_from $oddr_clk -rise_to phy3_rgmii_txc -setup
set_false_path -rise_from $oddr_clk -rise_to phy3_rgmii_txc -hold
set_false_path -fall_from $oddr_clk -fall_to phy3_rgmii_txc -hold

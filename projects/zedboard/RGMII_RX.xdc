
# Port 0

create_clock -period 8.000 -name ethfmc_p0_rgmii_rxc [get_ports ethfmc_p0_rgmii_rxc]
create_clock -period 8.000 -name rgmii_rx_clk_0

set_input_delay -clock [get_clocks rgmii_rx_clk_0] -max -1.4 [get_ports { ethfmc_p0_rgmii_rd[*] ethfmc_p0_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_0] -min -2.8 [get_ports { ethfmc_p0_rgmii_rd[*] ethfmc_p0_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_0] -max -1.4 -clock_fall -add_delay [get_ports { ethfmc_p0_rgmii_rd[*] ethfmc_p0_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_0] -min -2.8 -clock_fall -add_delay [get_ports { ethfmc_p0_rgmii_rd[*] ethfmc_p0_rgmii_rx_ctl }]

set_false_path -rise_from [get_clocks rgmii_rx_clk_0] -fall_to [get_clocks ethfmc_p0_rgmii_rxc] -setup
set_false_path -fall_from [get_clocks rgmii_rx_clk_0] -rise_to [get_clocks ethfmc_p0_rgmii_rxc] -setup
set_false_path -rise_from [get_clocks rgmii_rx_clk_0] -rise_to [get_clocks ethfmc_p0_rgmii_rxc] -hold
set_false_path -fall_from [get_clocks rgmii_rx_clk_0] -fall_to [get_clocks ethfmc_p0_rgmii_rxc] -hold

set_multicycle_path -from [get_clocks rgmii_rx_clk_0] -to [get_clocks ethfmc_p0_rgmii_rxc] -setup 0
set_multicycle_path -from [get_clocks rgmii_rx_clk_0] -to [get_clocks ethfmc_p0_rgmii_rxc] -hold -1

# Port 1

create_clock -period 8.000 -name ethfmc_p1_rgmii_rxc [get_ports ethfmc_p1_rgmii_rxc]
create_clock -period 8.000 -name rgmii_rx_clk_1

set_input_delay -clock [get_clocks rgmii_rx_clk_1] -max -1.4 [get_ports { ethfmc_p1_rgmii_rd[*] ethfmc_p1_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_1] -min -2.8 [get_ports { ethfmc_p1_rgmii_rd[*] ethfmc_p1_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_1] -max -1.4 -clock_fall -add_delay [get_ports { ethfmc_p1_rgmii_rd[*] ethfmc_p1_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_1] -min -2.8 -clock_fall -add_delay [get_ports { ethfmc_p1_rgmii_rd[*] ethfmc_p1_rgmii_rx_ctl }]

set_false_path -rise_from [get_clocks rgmii_rx_clk_1] -fall_to [get_clocks ethfmc_p1_rgmii_rxc] -setup
set_false_path -fall_from [get_clocks rgmii_rx_clk_1] -rise_to [get_clocks ethfmc_p1_rgmii_rxc] -setup
set_false_path -rise_from [get_clocks rgmii_rx_clk_1] -rise_to [get_clocks ethfmc_p1_rgmii_rxc] -hold
set_false_path -fall_from [get_clocks rgmii_rx_clk_1] -fall_to [get_clocks ethfmc_p1_rgmii_rxc] -hold

set_multicycle_path -from [get_clocks rgmii_rx_clk_1] -to [get_clocks ethfmc_p1_rgmii_rxc] -setup 0
set_multicycle_path -from [get_clocks rgmii_rx_clk_1] -to [get_clocks ethfmc_p1_rgmii_rxc] -hold -1

# Port 2

create_clock -period 8.000 -name ethfmc_p2_rgmii_rxc [get_ports ethfmc_p2_rgmii_rxc]
create_clock -period 8.000 -name rgmii_rx_clk_2

set_input_delay -clock [get_clocks rgmii_rx_clk_2] -max -1.4 [get_ports { ethfmc_p2_rgmii_rd[*] ethfmc_p2_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_2] -min -2.8 [get_ports { ethfmc_p2_rgmii_rd[*] ethfmc_p2_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_2] -max -1.4 -clock_fall -add_delay [get_ports { ethfmc_p2_rgmii_rd[*] ethfmc_p2_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_2] -min -2.8 -clock_fall -add_delay [get_ports { ethfmc_p2_rgmii_rd[*] ethfmc_p2_rgmii_rx_ctl }]

set_false_path -rise_from [get_clocks rgmii_rx_clk_2] -fall_to [get_clocks ethfmc_p2_rgmii_rxc] -setup
set_false_path -fall_from [get_clocks rgmii_rx_clk_2] -rise_to [get_clocks ethfmc_p2_rgmii_rxc] -setup
set_false_path -rise_from [get_clocks rgmii_rx_clk_2] -rise_to [get_clocks ethfmc_p2_rgmii_rxc] -hold
set_false_path -fall_from [get_clocks rgmii_rx_clk_2] -fall_to [get_clocks ethfmc_p2_rgmii_rxc] -hold

set_multicycle_path -from [get_clocks rgmii_rx_clk_2] -to [get_clocks ethfmc_p2_rgmii_rxc] -setup 0
set_multicycle_path -from [get_clocks rgmii_rx_clk_2] -to [get_clocks ethfmc_p2_rgmii_rxc] -hold -1

# Port 3

create_clock -period 8.000 -name ethfmc_p3_rgmii_rxc [get_ports ethfmc_p3_rgmii_rxc]
create_clock -period 8.000 -name rgmii_rx_clk_3

set_input_delay -clock [get_clocks rgmii_rx_clk_3] -max -1.4 [get_ports { ethfmc_p3_rgmii_rd[*] ethfmc_p3_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_3] -min -2.8 [get_ports { ethfmc_p3_rgmii_rd[*] ethfmc_p3_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_3] -max -1.4 -clock_fall -add_delay [get_ports { ethfmc_p3_rgmii_rd[*] ethfmc_p3_rgmii_rx_ctl }]
set_input_delay -clock [get_clocks rgmii_rx_clk_3] -min -2.8 -clock_fall -add_delay [get_ports { ethfmc_p3_rgmii_rd[*] ethfmc_p3_rgmii_rx_ctl }]

set_false_path -rise_from [get_clocks rgmii_rx_clk_3] -fall_to [get_clocks ethfmc_p3_rgmii_rxc] -setup
set_false_path -fall_from [get_clocks rgmii_rx_clk_3] -rise_to [get_clocks ethfmc_p3_rgmii_rxc] -setup
set_false_path -rise_from [get_clocks rgmii_rx_clk_3] -rise_to [get_clocks ethfmc_p3_rgmii_rxc] -hold
set_false_path -fall_from [get_clocks rgmii_rx_clk_3] -fall_to [get_clocks ethfmc_p3_rgmii_rxc] -hold

set_multicycle_path -from [get_clocks rgmii_rx_clk_3] -to [get_clocks ethfmc_p3_rgmii_rxc] -setup 0
set_multicycle_path -from [get_clocks rgmii_rx_clk_3] -to [get_clocks ethfmc_p3_rgmii_rxc] -hold -1

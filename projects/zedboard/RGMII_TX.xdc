
# Port 0

create_generated_clock -name ethfmc_p0_rgmii_txc -divide_by 1 -source [filter [all_fanin -flat -pin_levels 4 [get_ports ethfmc_p0_rgmii_txc]] {name =~ *C}] [get_ports ethfmc_p0_rgmii_txc]

set_output_delay -clock [get_clocks ethfmc_p0_rgmii_txc] -max -0.9 -add_delay [get_ports { ethfmc_p0_rgmii_td[*] ethfmc_p0_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p0_rgmii_txc] -min -2.7 -add_delay [get_ports { ethfmc_p0_rgmii_td[*] ethfmc_p0_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p0_rgmii_txc] -max -0.9 -add_delay -clock_fall [get_ports { ethfmc_p0_rgmii_td[*] ethfmc_p0_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p0_rgmii_txc] -min -2.7 -add_delay -clock_fall [get_ports { ethfmc_p0_rgmii_td[*] ethfmc_p0_rgmii_tx_ctl }]

set_false_path -rise_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -fall_to [get_clocks ethfmc_p0_rgmii_txc] -setup
set_false_path -fall_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -rise_to [get_clocks ethfmc_p0_rgmii_txc] -setup
set_false_path -rise_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -rise_to [get_clocks ethfmc_p0_rgmii_txc] -hold
set_false_path -fall_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -fall_to [get_clocks ethfmc_p0_rgmii_txc] -hold

# Port 1

create_generated_clock -name ethfmc_p1_rgmii_txc -divide_by 1 -source [filter [all_fanin -flat -pin_levels 4 [get_ports ethfmc_p1_rgmii_txc]] {name =~ *C}] [get_ports ethfmc_p1_rgmii_txc]

set_output_delay -clock [get_clocks ethfmc_p1_rgmii_txc] -max -0.9 -add_delay [get_ports { ethfmc_p1_rgmii_td[*] ethfmc_p1_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p1_rgmii_txc] -min -2.7 -add_delay [get_ports { ethfmc_p1_rgmii_td[*] ethfmc_p1_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p1_rgmii_txc] -max -0.9 -add_delay -clock_fall [get_ports { ethfmc_p1_rgmii_td[*] ethfmc_p1_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p1_rgmii_txc] -min -2.7 -add_delay -clock_fall [get_ports { ethfmc_p1_rgmii_td[*] ethfmc_p1_rgmii_tx_ctl }]

set_false_path -rise_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -fall_to [get_clocks ethfmc_p1_rgmii_txc] -setup
set_false_path -fall_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -rise_to [get_clocks ethfmc_p1_rgmii_txc] -setup
set_false_path -rise_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -rise_to [get_clocks ethfmc_p1_rgmii_txc] -hold
set_false_path -fall_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -fall_to [get_clocks ethfmc_p1_rgmii_txc] -hold

# Port 2

create_generated_clock -name ethfmc_p2_rgmii_txc -divide_by 1 -source [filter [all_fanin -flat -pin_levels 4 [get_ports ethfmc_p2_rgmii_txc]] {name =~ *C}] [get_ports ethfmc_p2_rgmii_txc]

set_output_delay -clock [get_clocks ethfmc_p2_rgmii_txc] -max -0.9 -add_delay [get_ports { ethfmc_p2_rgmii_td[*] ethfmc_p2_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p2_rgmii_txc] -min -2.7 -add_delay [get_ports { ethfmc_p2_rgmii_td[*] ethfmc_p2_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p2_rgmii_txc] -max -0.9 -add_delay -clock_fall [get_ports { ethfmc_p2_rgmii_td[*] ethfmc_p2_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p2_rgmii_txc] -min -2.7 -add_delay -clock_fall [get_ports { ethfmc_p2_rgmii_td[*] ethfmc_p2_rgmii_tx_ctl }]

set_false_path -rise_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -fall_to [get_clocks ethfmc_p2_rgmii_txc] -setup
set_false_path -fall_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -rise_to [get_clocks ethfmc_p2_rgmii_txc] -setup
set_false_path -rise_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -rise_to [get_clocks ethfmc_p2_rgmii_txc] -hold
set_false_path -fall_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -fall_to [get_clocks ethfmc_p2_rgmii_txc] -hold

# Port 3

create_generated_clock -name ethfmc_p3_rgmii_txc -divide_by 1 -source [filter [all_fanin -flat -pin_levels 4 [get_ports ethfmc_p3_rgmii_txc]] {name =~ *C}] [get_ports ethfmc_p3_rgmii_txc]

set_output_delay -clock [get_clocks ethfmc_p3_rgmii_txc] -max -0.9 -add_delay [get_ports { ethfmc_p3_rgmii_td[*] ethfmc_p3_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p3_rgmii_txc] -min -2.7 -add_delay [get_ports { ethfmc_p3_rgmii_td[*] ethfmc_p3_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p3_rgmii_txc] -max -0.9 -add_delay -clock_fall [get_ports { ethfmc_p3_rgmii_td[*] ethfmc_p3_rgmii_tx_ctl }]
set_output_delay -clock [get_clocks ethfmc_p3_rgmii_txc] -min -2.7 -add_delay -clock_fall [get_ports { ethfmc_p3_rgmii_td[*] ethfmc_p3_rgmii_tx_ctl }]

set_false_path -rise_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -fall_to [get_clocks ethfmc_p3_rgmii_txc] -setup
set_false_path -fall_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -rise_to [get_clocks ethfmc_p3_rgmii_txc] -setup
set_false_path -rise_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -rise_to [get_clocks ethfmc_p3_rgmii_txc] -hold
set_false_path -fall_from [get_clocks -of [get_pins -hier -filter {name =~ */ethfmc_dcm/*/CLKOUT0}]] -fall_to [get_clocks ethfmc_p3_rgmii_txc] -hold

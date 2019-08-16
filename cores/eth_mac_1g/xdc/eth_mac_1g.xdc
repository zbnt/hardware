
set_property ASYNC_REG TRUE [get_cells -hier -filter { NAME =~ */rx_prescale_sync_reg[*] }]
set_property ASYNC_REG TRUE [get_cells -hier -filter { NAME =~ */rx_mii_select_sync_reg[*] }]
set_property ASYNC_REG TRUE [get_cells -hier -filter { NAME =~ */tx_mii_select_sync_reg[*] }]

set_property ASYNC_REG TRUE [get_cells -hier -filter { NAME =~ */rx_rst_reg_reg[*] }]
set_property ASYNC_REG TRUE [get_cells -hier -filter { NAME =~ */tx_rst_reg_reg[*] }]

set_property -quiet ASYNC_REG TRUE [get_cells -hier -filter { NAME =~ */clk_oddr_inst/oddr[0].oddr_inst }]

set_max_delay -datapath_only 8.0 -from [get_cells -hier -filter { NAME =~ */rx_prescale_reg[*] }] -to [get_cells -hier -filter { NAME =~ */rx_prescale_sync_reg[*] }]
set_max_delay -datapath_only 8.0 -from [get_cells -hier -filter { NAME =~ */mii_select_reg_reg }] -to [get_cells -hier -filter { NAME =~ */rx_mii_select_sync_reg[0] }]
set_max_delay -datapath_only 8.0 -from [get_cells -hier -filter { NAME =~ */mii_select_reg_reg }] -to [get_cells -hier -filter { NAME =~ */tx_mii_select_sync_reg[0] }]

set_false_path -to [get_pins -of_objects [get_cells -hier -filter { NAME =~ */rx_rst_reg_reg[*] }] -filter {IS_PRESET || IS_RESET}]
set_false_path -to [get_pins -of_objects [get_cells -hier -filter { NAME =~ */tx_rst_reg_reg[*] }] -filter {IS_PRESET || IS_RESET}]

set_max_delay -quiet -datapath_only 2.0 -from [get_cells -hier -filter { NAME =~ */rgmii_tx_clk_1_reg }] -to [get_cells -hier -filter { NAME =~ */clk_oddr_inst/oddr[0].oddr_inst }]
set_max_delay -quiet -datapath_only 2.0 -from [get_cells -hier -filter { NAME =~ */rgmii_tx_clk_2_reg[*] }] -to [get_cells -hier -filter { NAME =~ */clk_oddr_inst/oddr[0].oddr_inst }]

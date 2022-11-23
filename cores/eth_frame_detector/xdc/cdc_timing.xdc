set_max_delay -datapath_only 8.0 -from [get_cells -hier -filter { NAME =~ */sync_stages_in_reg[*] }] -to [get_cells -hier -filter { NAME =~ */sync_stages_reg[0][*] }]

set_max_delay -datapath_only 8.0 -from [get_cells -hier -filter { NAME =~ */gray_sync_in_reg[*] }] -to [get_cells -hier -filter { NAME =~ */gray_sync_stages_reg[0][*] }]
set_bus_skew 8.0 -from [get_cells -hier -filter { NAME =~ */gray_sync_in_reg[*] }] -to [get_cells -hier -filter { NAME =~ */gray_sync_stages_reg[0][*] }]

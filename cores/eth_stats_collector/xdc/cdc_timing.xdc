set_max_delay -datapath_only 8.0 -from [get_cells -hier -filter { NAME =~ */sync_stages_in_reg[*] }] -to [get_cells -hier -filter { NAME =~ *sync_stages_reg[0][*] }]

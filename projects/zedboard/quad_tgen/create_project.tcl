
# Create project

cd [file dirname [info script]]
create_project -force zbnt_hw_quad_tgen -part xc7z020clg484-1 vivado
set_property BOARD_PART em.avnet.com:zed:part0:1.4 [current_project]
set_property XPM_LIBRARIES {XPM_MEMORY XPM_FIFO} [current_project]

# Load source files

read_xdc ../Zedboard.xdc
read_xdc ../RGMII_TX.xdc
read_xdc ../RGMII_RX.xdc

# Set path to IP repository

set_property IP_REPO_PATHS ../../../cores [current_fileset]
update_ip_catalog -rebuild

# Create block diagram

source bd_quad_tgen.tcl
read_verilog [make_wrapper -top -files [get_files bd_quad_tgen.bd]]

# Create synthesis run

set_property -name "flow" -value "Vivado Synthesis 2018" -objects [get_runs synth_1]
set_property -name "strategy" -value "Flow_PerfOptimized_high" -objects [get_runs synth_1]
set_property -name "steps.synth_design.args.fanout_limit" -value "400" -objects [get_runs synth_1]
set_property -name "steps.synth_design.args.fsm_extraction" -value "one_hot" -objects [get_runs synth_1]
set_property -name "steps.synth_design.args.keep_equivalent_registers" -value "1" -objects [get_runs synth_1]
set_property -name "steps.synth_design.args.resource_sharing" -value "off" -objects [get_runs synth_1]
set_property -name "steps.synth_design.args.no_lc" -value "1" -objects [get_runs synth_1]
set_property -name "steps.synth_design.args.shreg_min_size" -value "5" -objects [get_runs synth_1]
current_run -synthesis [get_runs synth_1]

# Create implementation run

set_property -name "flow" -value "Vivado Implementation 2018" -objects [get_runs impl_1]
set_property -name "strategy" -value "Performance_ExploreWithRemap" -objects [get_runs impl_1]
set_property -name "steps.opt_design.args.directive" -value "ExploreWithRemap" -objects [get_runs impl_1]
set_property -name "steps.place_design.args.directive" -value "Explore" -objects [get_runs impl_1]
set_property -name "steps.phys_opt_design.is_enabled" -value "1" -objects [get_runs impl_1]
set_property -name "steps.phys_opt_design.args.directive" -value "Explore" -objects [get_runs impl_1]
set_property -name "steps.route_design.args.directive" -value "NoTimingRelaxation" -objects [get_runs impl_1]
set_property -name "steps.route_design.args.more options" -value "-tns_cleanup" -objects [get_runs impl_1]
set_property -name "steps.post_route_phys_opt_design.is_enabled" -value "1" -objects [get_runs impl_1]
set_property -name "steps.post_route_phys_opt_design.args.directive" -value "Explore" -objects [get_runs impl_1]
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects [get_runs impl_1]
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects [get_runs impl_1]
current_run -implementation [get_runs impl_1]

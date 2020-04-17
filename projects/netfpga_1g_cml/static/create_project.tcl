
# Create project

cd [file dirname [info script]]
create_project -force zbnt_hw_static -part xc7k325tffg676-1 vivado
set_property XPM_LIBRARIES {XPM_MEMORY XPM_FIFO} [current_project]

# Load source files

read_xdc ../NetFPGA-1G-CML.xdc

# Set path to IP repository

set_property IP_REPO_PATHS {../../../cores ../cores} [current_fileset]
update_ip_catalog -rebuild

# Create block diagram

source bd_static.tcl
read_verilog [make_wrapper -top -files [get_files bd_static.bd]]

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

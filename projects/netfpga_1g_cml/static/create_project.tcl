
# Create project

cd [file dirname [info script]]
create_project -force zbnt_hw_static -part xc7k325tffg676-1 vivado
set_property XPM_LIBRARIES {XPM_MEMORY XPM_FIFO} [current_project]

# Load source files

read_xdc ../NetFPGA-1G-CML.xdc
read_xdc ../RGMII.xdc
set_property USED_IN_SYNTHESIS FALSE [get_files RGMII.xdc]

# Set path to IP repository

set_property IP_REPO_PATHS {../../../cores ../cores} [current_fileset]
update_ip_catalog -rebuild

# Create block diagram

source bd_static.tcl
set bd [get_files bd_static.bd]
read_verilog [make_wrapper -top -files $bd]

# Create IP synthesis runs

generate_target all $bd
export_ip_user_files -of_objects $bd -no_script -sync -force -quiet
create_ip_run $bd

# Configure synthesis

set runs [get_runs *synth_1]
set_property -name "flow" -value "Vivado Synthesis 2021" -objects $runs
set_property -name "strategy" -value "Flow_PerfOptimized_high" -objects $runs
set_property -name "steps.synth_design.args.fsm_extraction" -value "one_hot" -objects $runs
set_property -name "steps.synth_design.args.keep_equivalent_registers" -value "1" -objects $runs
set_property -name "steps.synth_design.args.resource_sharing" -value "off" -objects $runs
set_property -name "steps.synth_design.args.no_lc" -value "1" -objects $runs
set_property -name "steps.synth_design.args.shreg_min_size" -value "5" -objects $runs
current_run -synthesis [get_runs synth_1]

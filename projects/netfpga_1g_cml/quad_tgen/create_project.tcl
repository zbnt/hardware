
# Create project

cd [file dirname [info script]]
create_project -force zbnt_hw_quad_tgen -part xc7k325tffg676-1 vivado
set_property XPM_LIBRARIES {XPM_MEMORY XPM_FIFO} [current_project]

# Load source files

read_verilog ../cores/rp_wrapper/hdl/rp_wrapper_impl.v

# Set path to IP repository

set_property IP_REPO_PATHS ../../../cores [current_fileset]
update_ip_catalog -rebuild

# Create block diagram

source bd_reconfig_region.tcl

# Create synthesis run

set_property -name "flow" -value "Vivado Synthesis 2021" -objects [get_runs synth_1]
set_property -name "strategy" -value "Flow_PerfOptimized_high" -objects [get_runs synth_1]
set_property -name "steps.synth_design.args.fsm_extraction" -value "one_hot" -objects [get_runs synth_1]
set_property -name "steps.synth_design.args.keep_equivalent_registers" -value "1" -objects [get_runs synth_1]
set_property -name "steps.synth_design.args.resource_sharing" -value "off" -objects [get_runs synth_1]
set_property -name "steps.synth_design.args.no_lc" -value "1" -objects [get_runs synth_1]
set_property -name "steps.synth_design.args.shreg_min_size" -value "5" -objects [get_runs synth_1]
current_run -synthesis [get_runs synth_1]

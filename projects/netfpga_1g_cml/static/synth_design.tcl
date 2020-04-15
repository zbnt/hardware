
cd [file dirname [info script]]

# Get number of jobs to use

if { [info exists ::env(NUM_JOBS) ] } {
	set jobs $::env(NUM_JOBS)
} else {
	set jobs [exec nproc]
}

# Create project and generate bitstream, if needed

if { ![file exists vivado/zbnt_hw_static.xpr ] } {
	source create_project.tcl
} else {
	open_project vivado/zbnt_hw_static.xpr
}

if { [get_property needs_refresh [get_runs synth_1]] || [get_property status [get_runs synth_1]] == "Not started" } {
	reset_runs synth_1
	launch_runs synth_1 -jobs $jobs
	wait_on_run synth_1
}

# Write dcp

open_run synth_1 -name synth_1

file mkdir ../hw
file mkdir ../hw/dcp
write_checkpoint -force ../hw/dcp/static.dcp

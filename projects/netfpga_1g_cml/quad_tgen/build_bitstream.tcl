
cd [file dirname [info script]]

# Get number of jobs to use

if { [info exists ::env(NUM_JOBS) ] } {
	set jobs $::env(NUM_JOBS)
} else {
	set jobs [exec nproc]
}

# Create project and generate bitstream, if needed

if { ![file exists vivado/zbnt_hw_quad_tgen.xpr ] } {
	source create_project.tcl
} else {
	open_project vivado/zbnt_hw_quad_tgen.xpr
}

if { [get_property needs_refresh [get_runs impl_1]] || [get_property status [get_runs impl_1]] == "Not started" } {
	launch_runs impl_1 -to_step write_bitstream -jobs $jobs
	wait_on_run impl_1
}

# Copy to output folder

cd vivado/zbnt_hw_quad_tgen.runs/impl_1
file mkdir ../../../../hw
file copy -force bd_quad_tgen_wrapper.bit ../../../../hw/quad_tgen.bit

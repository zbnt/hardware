
cd [file dirname [info script]]

# Get number of jobs to use

if { [info exists ::env(NUM_JOBS) ] } {
	set jobs $::env(NUM_JOBS)
} else {
	set jobs [exec nproc]
}

# Create project and generate bitstream, if needed

if { ![file exists vivado/zbnt_hw_dual_tgen_latency.xpr ] } {
	source create_project.tcl
} else {
	open_project vivado/zbnt_hw_dual_tgen_latency.xpr
}

if { [get_property needs_refresh [get_runs impl_1]] || [get_property status [get_runs impl_1]] == "Not started" } {
	launch_runs impl_1 -to_step write_bitstream -jobs $jobs
	wait_on_run impl_1
}

# Swap bytes and copy to output folder

cd vivado/zbnt_hw_dual_tgen_latency.runs/impl_1

set bif_file [open bd_dual_tgen_latency.bif w]
puts $bif_file "all: { bd_dual_tgen_latency_wrapper.bit }"
close $bif_file

exec bootgen -image bd_dual_tgen_latency.bif -arch zynq -process_bitstream bin -w on

file mkdir ../../../../hw
file copy -force bd_dual_tgen_latency_wrapper.bit.bin ../../../../hw/dual_tgen_latency.bin

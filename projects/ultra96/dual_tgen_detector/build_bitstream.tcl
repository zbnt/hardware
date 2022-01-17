cd [file dirname [info script]]
set_param board.repoPaths [get_property LOCAL_ROOT_DIR [xhub::get_xstores xilinx_board_store]]

# Get number of jobs to use

if { [info exists ::env(NUM_JOBS) ] } {
	set jobs $::env(NUM_JOBS)
} else {
	set jobs 1
}

# Create project and generate bitstream, if needed

if { ![file exists vivado/zbnt_hw_dual_tgen_detector.xpr ] } {
	source create_project.tcl
} else {
	open_project vivado/zbnt_hw_dual_tgen_detector.xpr
}

if { [get_property needs_refresh [get_runs impl_1]] || [get_property status [get_runs impl_1]] == "Not started" } {
	reset_runs synth_1
	launch_runs impl_1 -to_step write_bitstream -jobs $jobs
	wait_on_run impl_1
}

# Swap bytes and copy to output folder

cd vivado/zbnt_hw_dual_tgen_detector.runs/impl_1

set bif_file [open bd_dual_tgen_detector.bif w]
puts $bif_file "all: { bd_dual_tgen_detector_wrapper.bit }"
close $bif_file

exec bootgen -image bd_dual_tgen_detector.bif -arch zynqmp -process_bitstream bin -w on

file mkdir ../../../../hw
file copy -force bd_dual_tgen_detector_wrapper.bit.bin ../../../../hw/dual_tgen_detector.bin

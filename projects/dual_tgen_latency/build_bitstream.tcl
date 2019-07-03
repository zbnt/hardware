
# Create project and generate bitstream

source create_project.tcl
launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1

# Copy bitstream to output directory

file mkdir ../../hw
file copy -force vivado/zbnt_hw_dual_tgen_latency.runs/impl_1/bd_dual_tgen_latency_wrapper.bin ../../hw/bd_dual_tgen_latency.bin

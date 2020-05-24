
# Define procedures for running implementation and generating bitstreams

proc run_implementation { static_dcp rp_dcp out_dcp reports_dir args } {
	create_project -part xc7k325tffg676-1 -in_memory

	# Load synthesis checkpoints

	add_files $static_dcp
	add_files $rp_dcp

	# Define hierarchy

	set_property SCOPED_TO_CELLS {bd_static_i/rp_wrapper/inst} [get_files $rp_dcp]
	link_design -top bd_static_wrapper -part xc7k325tffg676-1 -reconfig_partitions {bd_static_i/rp_wrapper/inst}

	# Create pblock for placing the RP

	if {[llength $args] == 2} {
		create_pblock pblock_pr
		set_property SNAPPING_MODE ON [get_pblock pblock_pr]
		set_property RESET_AFTER_RECONFIG true [get_pblock pblock_pr]

		resize_pblock pblock_pr -add {SLICE_X0Y250:SLICE_X153Y349 DSP48_X0Y100:DSP48_X5Y139 RAMB18_X0Y100:RAMB18_X6Y139 RAMB36_X0Y50:RAMB36_X6Y69}
		resize_pblock pblock_pr -add {SLICE_X36Y200:SLICE_X145Y249 DSP48_X2Y80:DSP48_X5Y99 RAMB18_X2Y80:RAMB18_X5Y99 RAMB36_X2Y40:RAMB36_X5Y49}
	}

	add_cells_to_pblock [get_pblocks pblock_pr] [get_cells bd_static_i/rp_wrapper/inst]

	# Run implementation

	opt_design
	place_design
	phys_opt_design
	route_design

	# Generate reports

	file mkdir $reports_dir

	report_drc               -file ${reports_dir}/drc.txt             -ruledecks {default}
	report_utilization       -file ${reports_dir}/utilization.txt
	report_methodology       -file ${reports_dir}/methodology.txt
	report_timing_summary    -file ${reports_dir}/timing.txt          -delay_type min_max -report_unconstrained -max_paths 10 -input_pins -routable_nets
	report_clock_interaction -file ${reports_dir}/clk_interaction.txt -delay_type min_max -significant_digits 3

	# Write checkpoint

	write_checkpoint -force $out_dcp

	# Write checkpoint with locked static logic and with reconfigurable partition as gray box

	if {[llength $args] == 2} {
		set out_st_dcp [lindex $args 0]
		set out_st_grey_dcp [lindex $args 1]

		update_design -cell bd_static_i/rp_wrapper/inst -black_box
		lock_design -level routing

		write_checkpoint -force $out_st_dcp

		update_design -cell bd_static_i/rp_wrapper/inst -buffer_ports
		place_design
		route_design

		write_checkpoint -force $out_st_grey_dcp
	}

	close_project
}

proc gen_static_bitstream { dcp } {
	open_checkpoint $dcp

	# Generate bitstream in bit format, convert to correct byte ordering for BPIx16

	set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
	write_bitstream -force -file ../bit/static.bit
	write_cfgmem -force -format bin -size 128 -interface BPIx16 -checksum -file ../static.bin -loadbit { up 0x00000000 ../bit/static.bit }

	close_project
}

proc gen_partial_bitstream { dcp bitstream_name } {
	open_checkpoint $dcp

	# Generate bitstreams in bin format

	set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
	write_bitstream -force -bin_file ../bit/${bitstream_name}

	# Convert to the correct format for writing to ICAP

	file del ../rp_${bitstream_name}.bin
	source [get_property REPOSITORY [get_ipdefs xilinx.com:ip:prc:1.3]]/xilinx/prc_v1_3/tcl/api.tcl
	prc_v1_3::format_bin_for_icap -i ../bit/${bitstream_name}_pblock_pr_partial.bin -o ../rp_${bitstream_name}.bin

	close_project
}

# Change directory

cd [file dirname [info script]]
cd hw/dcp

# Run implementation for every reconfigurable module

file mkdir impl
file mkdir ../reports

run_implementation static.dcp      rp_dual_detector.dcp      impl/dual_detector.dcp      ../reports/dual_detector      impl/static.dcp impl/static_grey.dcp
run_implementation impl/static.dcp rp_dual_tgen_detector.dcp impl/dual_tgen_detector.dcp ../reports/dual_tgen_detector
run_implementation impl/static.dcp rp_dual_tgen_latency.dcp  impl/dual_tgen_latency.dcp  ../reports/dual_tgen_latency
run_implementation impl/static.dcp rp_quad_tgen.dcp          impl/quad_tgen.dcp          ../reports/quad_tgen

# Verify if the implementation results are compatible

pr_verify impl/static_grey.dcp impl/dual_detector.dcp
pr_verify impl/static_grey.dcp impl/dual_tgen_detector.dcp
pr_verify impl/static_grey.dcp impl/dual_tgen_latency.dcp
pr_verify impl/static_grey.dcp impl/quad_tgen.dcp
close_project

# Generate bitstreams for every configuration

file mkdir ../bit

gen_static_bitstream  impl/static_grey.dcp
gen_partial_bitstream impl/dual_detector.dcp      dual_detector
gen_partial_bitstream impl/dual_tgen_detector.dcp dual_tgen_detector
gen_partial_bitstream impl/dual_tgen_latency.dcp  dual_tgen_latency
gen_partial_bitstream impl/quad_tgen.dcp          quad_tgen

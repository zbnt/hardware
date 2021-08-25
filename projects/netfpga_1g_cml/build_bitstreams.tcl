
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

	opt_design -directive ExploreWithRemap
	place_design -directive Explore
	phys_opt_design -directive Explore
	route_design -directive NoTimingRelaxation -tns_cleanup
	phys_opt_design -directive AggressiveExplore

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

	close_project
}

proc gen_partial_bitstream { dcp bitstream_name } {
	open_checkpoint $dcp

	# Generate bitstreams in bin format

	set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
	write_bitstream -force -bin_file ../bit/${bitstream_name}

	# Convert to the correct format for writing to ICAP

	file del ../rp_${bitstream_name}.bin
	source [get_property REPOSITORY [get_ipdefs xilinx.com:ip:dfx_controller:1.0]]/xilinx/dfx_controller_v1_0/tcl/api.tcl
	dfx_controller_v1_0::format_bin_for_icap -i ../bit/${bitstream_name}_pblock_pr_partial.bin -o ../bit/${bitstream_name}_icap.bin -bs 1

	close_project
}

proc set_bitstream_offsets { dcp dcp_out args } {
	open_checkpoint $dcp

	# Get memory cells and initialize address/size tables

	set address_mem {}
	set size_mem {}
	set total_size_mem {}

	set address_table {}
	set size_table {}
	set total_size_table {}

	for {set i 0} {$i < 32} {incr i} {
		lappend address_mem [get_cells -of_objects [all_fanin -flat -pin_levels 1 [get_nets bd_static_i/pr_ctrl/pr_controller/U0/i_vsm_0/address_from_mem[$i]]] -filter {REF_NAME =~ RAM*S}]
		lappend size_mem [get_cells -of_objects [all_fanin -flat -pin_levels 1 [get_nets bd_static_i/pr_ctrl/pr_controller/U0/i_vsm_0/size_from_mem[$i]]] -filter {REF_NAME =~ RAM*S}]
		lappend total_size_mem [get_cells bd_static_i/pr_ctrl/memory/pr_copy/inst/U1/genblk1[$i].size_rom]
		lappend address_table 0
		lappend size_table 0
		lappend total_size_table 0
	}

	# Calculate offsets for every bitstream

	set address 0x01000000
	set offset 0
	set result {}
	set i 0

	foreach bitstream $args {
		set bitsize [file size ../bit/${bitstream}_icap.bin]

		set_table_entry address_table $i $offset
		set_table_entry size_table $i $bitsize

		lappend result up
		lappend result [format "0x%08X" [expr $address/2]]
		lappend result ../bit/${bitstream}_icap.bin

		incr i
		incr address $bitsize
		incr offset $bitsize
	}

	# Apply changes

	set_table_entry total_size_table 0 $offset

	for {set i 0} {$i < 32} {incr i} {
		set_property INIT [format "'h%X" [lindex $address_table $i]] [lindex $address_mem $i]
		set_property INIT [format "'h%X" [lindex $size_table $i]] [lindex $size_mem $i]
		set_property INIT [format "'h%X" [lindex $total_size_table $i]] [lindex $total_size_mem $i]
	}

	write_checkpoint -force $dcp_out

	close_project
	return $result
}

proc set_table_entry { table idx value } {
	upvar $table t

	for {set i 0} {$i < 32} {incr i} {
		lset t $i [expr ([lindex $t $i] & ~(1 << $idx)) | (!!($value & (1 << $i)) << $idx) ]
	}
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

# Generate partial bitstreams

file mkdir ../bit

gen_partial_bitstream impl/dual_detector.dcp      dual_detector
gen_partial_bitstream impl/dual_tgen_detector.dcp dual_tgen_detector
gen_partial_bitstream impl/dual_tgen_latency.dcp  dual_tgen_latency
gen_partial_bitstream impl/quad_tgen.dcp          quad_tgen

# Update static design with partial bitstream sizes, generate bitstream

set offsets [set_bitstream_offsets impl/static_grey.dcp impl/static_grey_with_sizes.dcp dual_detector dual_tgen_detector dual_tgen_latency quad_tgen]
gen_static_bitstream impl/static_grey_with_sizes.dcp

# Make sure the implementation results are compatible

pr_verify impl/static_grey_with_sizes.dcp impl/dual_detector.dcp
pr_verify impl/static_grey_with_sizes.dcp impl/dual_tgen_detector.dcp
pr_verify impl/static_grey_with_sizes.dcp impl/dual_tgen_latency.dcp
pr_verify impl/static_grey_with_sizes.dcp impl/quad_tgen.dcp
close_project

# Generate BPI memory image

write_cfgmem -force -format bin -size 128 -interface BPIx16 -checksum -file ../netfpga_1g_cml.bin -loadbit { up 0x00000000 ../bit/static.bit } -loaddata $offsets

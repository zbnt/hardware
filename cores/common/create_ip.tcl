cd [file dirname [info script]]
source ../ip_functions.tcl

# General info

set core [ip::create_core oscar-rc.dev zbnt common 1.0]

ip::set_disp_name   $core "ZBNT Library Core"
ip::set_description $core "Library of modules used by multiple cores"
ip::tag_as_library  $core

# Sources

ip::add_sources $core {
	hdl/axi4_lite/axi4_lite_slave_read.sv
	hdl/axi4_lite/axi4_lite_slave_rw.sv
	hdl/axi4_lite/axi4_lite_slave_write.sv
	hdl/axis_fifo.sv
	hdl/bus_cdc.sv
	hdl/counter_big.sv
	hdl/counter.sv
	hdl/lfsr.sv
	hdl/mux_big.sv
	hdl/pcg8.sv
	hdl/reg_slice.sv
	hdl/sync_ffs.sv
}

ip::save_core $core

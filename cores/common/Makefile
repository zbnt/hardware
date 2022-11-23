SOURCES = \
	hdl/axi4_lite/axi4_lite_slave_read.sv  \
	hdl/axi4_lite/axi4_lite_slave_rw.sv    \
	hdl/axi4_lite/axi4_lite_slave_write.sv \
	hdl/axis_fifo.sv                       \
	hdl/bus_cdc.sv                         \
	hdl/counter.sv                         \
	hdl/gray_cdc.sv                        \
	hdl/lfsr_prng.sv                       \
	hdl/mux_big.sv                         \
	hdl/pcg8.sv                            \
	hdl/reg_slice.sv                       \
	hdl/sync_ffs.sv

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

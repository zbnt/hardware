SOURCES = \
	hdl/pr_bitstream_copy_rom.sv    \
	hdl/pr_bitstream_copy.sv        \
	hdl/pr_bitstream_copy_wrapper.v \
	xgui/pr_bitstream_copy.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

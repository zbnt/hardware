SOURCES = \
	hdl/axi_s2mm_io.sv     \
	hdl/axi_s2mm.sv        \
	hdl/axi_s2mm_wrapper.v \
	xgui/axi_s2mm.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

SOURCES = \
	hdl/axi_mm2s_io.sv     \
	hdl/axi_mm2s.sv        \
	hdl/axi_mm2s_wrapper.v \
	xgui/axi_mm2s.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

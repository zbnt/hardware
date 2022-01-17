SOURCES = \
	hdl/mem_streamer.sv        \
	hdl/mem_streamer_wrapper.v \
	xgui/mem_streamer.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

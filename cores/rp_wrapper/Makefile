SOURCES = \
	hdl/rp_wrapper.v    \
	xgui/rp_wrapper.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

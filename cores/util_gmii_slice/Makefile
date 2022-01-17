SOURCES = \
	hdl/util_gmii_slice.v    \
	xgui/util_gmii_slice.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

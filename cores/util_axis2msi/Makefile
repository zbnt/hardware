SOURCES = \
	hdl/util_axis2msi.v    \
	xgui/util_axis2msi.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

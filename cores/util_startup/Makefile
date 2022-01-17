SOURCES = \
	hdl/util_startup.v     \
	xgui/util_startup.gtcl \
	xgui/util_startup.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

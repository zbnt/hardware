SOURCES = \
	hdl/util_cdc_array_single.v    \
	xgui/util_cdc_array_single.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

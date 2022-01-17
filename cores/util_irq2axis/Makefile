SOURCES = \
	hdl/util_irq2axis.v    \
	xgui/util_irq2axis.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

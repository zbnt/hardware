SOURCES = \
	hdl/util_sgmii_crossover.v    \
	xgui/util_sgmii_crossover.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

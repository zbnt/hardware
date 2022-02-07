SOURCES = \
	hdl/mdio_fsm.sv    \
	hdl/mdio.sv        \
	hdl/mdio_wrapper.v \
	xgui/mdio.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

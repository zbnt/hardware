SOURCES = \
	hdl/axis_shutdown.sv        \
	hdl/axis_shutdown_wrapper.v \
	xgui/axis_shutdown.gtcl     \
	xgui/axis_shutdown.tcl      \

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

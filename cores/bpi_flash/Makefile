SOURCES = \
	hdl/bpi_flash_ctrl.sv       \
	hdl/bpi_flash_read_fsm.sv   \
	hdl/bpi_flash.sv            \
	hdl/bpi_flash_wrapper.v     \
	hdl/bpi_flash_write_fifo.sv \
	hdl/bpi_flash_write_fsm.sv  \
	xgui/bpi_flash.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

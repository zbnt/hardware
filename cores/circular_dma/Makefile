SOURCES = \
	hdl/circular_dma_axi.sv    \
	hdl/circular_dma_fifos.sv  \
	hdl/circular_dma_fsm.sv    \
	hdl/circular_dma.sv        \
	hdl/circular_dma_wrapper.v \
	xdc/memory_opt.xdc         \
	xgui/circular_dma.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

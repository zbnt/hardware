SOURCES = \
	hdl/eth_traffic_gen_axis.sv   \
	hdl/eth_traffic_gen_axi.sv    \
	hdl/eth_traffic_gen_burst.sv  \
	hdl/eth_traffic_gen.sv        \
	hdl/eth_traffic_gen_wrapper.v \
	hdl/frame_dram.sv             \
	hdl/lfsr.v                    \
	hdl/pattern_dram.sv           \
	xgui/eth_traffic_gen.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

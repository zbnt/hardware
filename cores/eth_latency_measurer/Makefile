SOURCES = \
	hdl/checksum_calculator.sv           \
	hdl/eth_latency_measurer_axis_log.sv \
	hdl/eth_latency_measurer_axi.sv      \
	hdl/eth_latency_measurer_coord.sv    \
	hdl/eth_latency_measurer_rx.sv       \
	hdl/eth_latency_measurer.sv          \
	hdl/eth_latency_measurer_tx.sv       \
	hdl/eth_latency_measurer_wrapper.v   \
	xdc/cdc_timing.xdc                   \
	xgui/eth_latency_measurer.gtcl       \
	xgui/eth_latency_measurer.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

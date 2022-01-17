SOURCES = \
	hdl/eth_stats_adder.sv              \
	hdl/eth_stats_collector_axis_log.sv \
	hdl/eth_stats_collector_axi.sv      \
	hdl/eth_stats_collector.sv          \
	hdl/eth_stats_collector_wrapper.v   \
	hdl/eth_stats_counter_rx.sv         \
	hdl/eth_stats_counter_tx.sv         \
	xdc/cdc_timing.xdc                  \
	xgui/eth_stats_collector.gtcl       \
	xgui/eth_stats_collector.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

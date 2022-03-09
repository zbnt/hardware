SOURCES = \
	hdl/alu.sv                         \
	hdl/eth_frame_detector_axi_dram.sv \
	hdl/eth_frame_detector_axis_log.sv \
	hdl/eth_frame_detector_axi.sv      \
	hdl/eth_frame_detector.sv          \
	hdl/eth_frame_detector_wrapper.v   \
	hdl/eth_frame_loop_compare.sv      \
	hdl/eth_frame_loop_csum.sv         \
	hdl/eth_frame_loop_edit.sv         \
	hdl/eth_frame_loop_extract.sv      \
	hdl/eth_frame_loop_fifo.sv         \
	hdl/eth_frame_loop_rx.sv           \
	hdl/eth_frame_loop.sv              \
	hdl/eth_frame_loop_tx.sv           \
	hdl/lfsr.v                         \
	hdl/multiplier.sv                  \
	hdl/script_mem.sv                  \
	xdc/cdc_timing.xdc                 \
	xdc/memory_opt.xdc                 \
	xgui/eth_frame_detector.gtcl       \
	xgui/eth_frame_detector.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml

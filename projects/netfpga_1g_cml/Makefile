
.PHONY: all synth bitstreams clean

all: bitstreams

bitstreams: synth
	vivado -mode batch -source build_bitstreams.tcl -nolog -nojournal

synth:
	vivado -mode batch -source static/synth_design.tcl -nolog -nojournal
	vivado -mode batch -source dual_tgen_latency/synth_design.tcl -nolog -nojournal
	vivado -mode batch -source dual_tgen_detector/synth_design.tcl -nolog -nojournal
	vivado -mode batch -source quad_tgen/synth_design.tcl -nolog -nojournal

clean:
	-rm -r static/vivado
	-rm -r dual_tgen_latency/vivado
	-rm -r dual_tgen_detector/vivado
	-rm -r quad_tgen/vivado
	-rm hw/*.bin
	-rm hw/*.prm
	-rm -r hw/bit hw/dcp hw/reports


.PHONY: all bitstreams synth clean clean_bitstreams clean_synth

all: bitstreams

wrapper:
	@$(MAKE) -C cores/rp_wrapper

# Synthesis and implementation

bitstreams: synth
	vivado -mode batch -source build_bitstreams.tcl -nolog -nojournal

synth: wrapper
	vivado -mode batch -source static/synth_design.tcl -nolog -nojournal
	vivado -mode batch -source dual_detector/synth_design.tcl -nolog -nojournal
	vivado -mode batch -source dual_tgen_detector/synth_design.tcl -nolog -nojournal
	vivado -mode batch -source dual_tgen_latency/synth_design.tcl -nolog -nojournal
	vivado -mode batch -source quad_tgen/synth_design.tcl -nolog -nojournal

# Cleanup

clean: clean_bitstreams clean_synth

clean_bitstreams:
	-rm -r hw/bit hw/reports hw/dcp/impl
	-rm hw/*.bin hw/*.prm

clean_synth:
	-rm -r static/vivado
	-rm -r dual_detector/vivado
	-rm -r dual_tgen_detector/vivado
	-rm -r dual_tgen_latency/vivado
	-rm -r quad_tgen/vivado
	-rm -r hw/dcp/*.dcp

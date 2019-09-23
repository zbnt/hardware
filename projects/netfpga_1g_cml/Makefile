
.PHONY: all dual_tgen_latency dual_tgen_detector quad_tgen mcs clean

all: dual_tgen_latency dual_tgen_detector quad_tgen mcs

dual_tgen_latency:
	vivado -mode batch -source dual_tgen_latency/build_bitstream.tcl -nolog -nojournal

dual_tgen_detector:
	vivado -mode batch -source dual_tgen_detector/build_bitstream.tcl -nolog -nojournal

quad_tgen:
	vivado -mode batch -source quad_tgen/build_bitstream.tcl -nolog -nojournal

mcs: dual_tgen_latency dual_tgen_detector quad_tgen
	vivado -mode batch -source create_mcs.tcl -nolog -nojournal

clean:
	-rm -r dual_tgen_latency/vivado
	-rm -r dual_tgen_detector/vivado
	-rm -r quad_tgen/vivado
	-rm hw/dual_tgen_detector.bit hw/dual_tgen_latency.bit hw/quad_tgen.bit hw/netfpga_1g_cml.mcs hw/netfpga_1g_cml.prm

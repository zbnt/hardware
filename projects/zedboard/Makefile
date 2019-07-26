
.PHONY: all dual_tgen_latency dual_tgen_detector quad_tgen clean

all: dual_tgen_latency dual_tgen_detector quad_tgen

dual_tgen_latency:
	vivado -mode batch -source dual_tgen_latency/build_bitstream.tcl -nolog -nojournal

dual_tgen_detector:
	vivado -mode batch -source dual_tgen_detector/build_bitstream.tcl -nolog -nojournal

quad_tgen:
	vivado -mode batch -source quad_tgen/build_bitstream.tcl -nolog -nojournal

clean:
	-rm -r dual_tgen_latency/vivado
	-rm -r dual_tgen_detector/vivado
	-rm -r quad_tgen/vivado

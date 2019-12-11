
.PHONY: all dual_tgen_latency dual_tgen_detector quad_tgen dtbs clean

all: dual_tgen_latency dual_tgen_detector quad_tgen dtbs

dual_tgen_latency:
	vivado -mode batch -source dual_tgen_latency/build_bitstream.tcl -nolog -nojournal

dual_tgen_detector:
	vivado -mode batch -source dual_tgen_detector/build_bitstream.tcl -nolog -nojournal

quad_tgen:
	vivado -mode batch -source quad_tgen/build_bitstream.tcl -nolog -nojournal

dtbs:
	dtc -I dts -O dtb -@ -o hw/quad_tgen.dtbo quad_tgen/pl_devtree.dts
	dtc -I dts -O dtb -@ -o hw/dual_tgen_latency.dtbo dual_tgen_latency/pl_devtree.dts
	dtc -I dts -O dtb -@ -o hw/dual_tgen_detector.dtbo dual_tgen_detector/pl_devtree.dts

clean:
	-rm -r dual_tgen_latency/vivado
	-rm -r dual_tgen_detector/vivado
	-rm -r quad_tgen/vivado
	-rm hw/dual_tgen_detector.bin hw/dual_tgen_latency.bin hw/quad_tgen.bin
	-rm hw/*.dtbo

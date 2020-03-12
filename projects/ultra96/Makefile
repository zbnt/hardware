
.PHONY: all quad_tgen dtbs clean

all: quad_tgen dtbs

quad_tgen:
	vivado -mode batch -source quad_tgen/build_bitstream.tcl -nolog -nojournal

dtbs:
	dtc -I dts -O dtb -@ -o hw/quad_tgen.dtbo quad_tgen/pl_devtree.dts

clean:
	-rm -r quad_tgen/vivado
	-rm hw/quad_tgen.bin
	-rm hw/*.dtbo

.PHONY: all cores zedboard ultra96 netfpga_1g_cml clean

all: zedboard ultra96 netfpga_1g_cml

cores:
	$(MAKE) -C cores

zedboard: cores
	$(MAKE) -C projects/zedboard all

ultra96: cores
	$(MAKE) -C projects/ultra96 all

netfpga_1g_cml: cores
	$(MAKE) -C projects/netfpga_1g_cml all

clean:
	$(MAKE) -C cores clean
	$(MAKE) -C projects/zedboard clean
	$(MAKE) -C projects/ultra96 clean
	$(MAKE) -C projects/netfpga_1g_cml clean

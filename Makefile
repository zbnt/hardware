
.PHONY: all zedboard ultra96 netfpga_1g_cml clean

all: zedboard ultra96 netfpga_1g_cml

zedboard:
	$(MAKE) -C projects/zedboard all

ultra96:
	$(MAKE) -C projects/ultra96 all

netfpga_1g_cml:
	$(MAKE) -C projects/netfpga_1g_cml all

clean:
	$(MAKE) -C projects/zedboard clean
	$(MAKE) -C projects/ultra96 clean
	$(MAKE) -C projects/netfpga_1g_cml clean

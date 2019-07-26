
.PHONY: all zedboard netfpga_1g_cml clean

all: zedboard netfpga_1g_cml

zedboard:
	$(MAKE) -C projects/zedboard all

netfpga_1g_cml:
	$(MAKE) -C projects/netfpga_1g_cml all

clean:
	$(MAKE) -C projects/zedboard clean
	$(MAKE) -C projects/netfpga_1g_cml clean

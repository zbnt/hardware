
# zbnt_hw

HDL code for ZBNT, a configurable network tester for Xilinx FPGAs/SoCs

## Related projects

* **GUI:** [zbnt_gui](https://github.com/oscar-rc1/zbnt_gui)
* **Board software:** [zbnt_sw](https://github.com/oscar-rc1/zbnt_sw)

## Requirements

### Hardware

This repository includes block designs for the following boards:

* [ZedBoard](http://www.zedboard.org/product/zedboard) with [Ethernet FMC](http://ethernetfmc.com) **(2.5V version only)**
* _(Experimental)_ [NetFPGA-1G-CML](https://store.digilentinc.com/netfpga-1g-cml-kintex-7-fpga-development-board)

### Software

* [Vivado Design Suite 2018.3](https://www.xilinx.com/products/design-tools/vivado.html)

## Building

1. Clone this repository, make sure all dependencies are installed before proceeding.
2. Add Vivado tools to PATH by sourcing the `settings64.sh` script in the installation directory:

```bash
source /opt/Xilinx/Vivado/2018.3/settings64.sh
```

3. `cd` to the root directory of this repository and run `make`

```bash
# Build bitstreams for all supported devices
make

# Build bitstreams only for the specified device
make zedboard
make netfpga_1g_cml

# Use the NUM_JOBS environment variable to control the number of parallel jobs
# By default it will use one parallel job for each thread in your CPU
NUM_JOBS=2 make zedboard
```

## License

* The source code included in this repository is subject to the terms of the Mozilla Public License, v2.0. A copy is available in [LICENSE.txt](https://github.com/oscar-rc1/zbnt_hw/blob/master/LICENSE.txt) and [Mozilla's website](https://mozilla.org/MPL/2.0).
* The block designs depend on IP cores available for free as part of the Xilinx Vivado Design Suite, and licensed under the terms of the [Xilinx End User License](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/end-user-license-agreement.pdf). The source code for those cores is not distributed as part of this repository.

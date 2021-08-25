# zbnt/hardware

HDL code and block designs for ZBNT, a system for generating, capturing and modifying network traffic.

## Related projects

* **GUI:** [zbnt/gui](https://github.com/zbnt/gui)
* **Server:** [zbnt/server](https://github.com/zbnt/server)
* **Python client:** [zbnt/python-client](https://github.com/zbnt/python-client)

## Requirements

### Hardware

This repository includes block designs for the following boards:

* [ZedBoard](http://www.zedboard.org/product/zedboard) with [Ethernet FMC](http://ethernetfmc.com) **(2.5V version only)**
* [Ultra96](https://www.96boards.org/product/ultra96) with [96B Quad Ethernet Mezzanine](https://opsero.com/product/96b-quad-ethernet-mezzanine)
* [NetFPGA-1G-CML](https://store.digilentinc.com/netfpga-1g-cml-kintex-7-fpga-development-board)

### Software

* [Vivado Design Suite 2021.1](https://www.xilinx.com/products/design-tools/vivado.html)
* Linux device tree compiler (dtc)
* Python 3

### Others

* For building the bitstreams, a system with at least 16GB of RAM is highly recommended

## Building

1. Clone this repository, make sure all dependencies are installed before proceeding.
2. Initialize and fetch the required submodules:

```bash
git submodule init
git submodule update
```

3. Add Vivado tools to PATH by sourcing the `settings64.sh` script in the installation directory:

```bash
source /opt/Xilinx/Vivado/2021.1/settings64.sh
```

4. `cd` to the root directory of this repository and run `make`

```bash
# Build bitstreams for all supported devices
make

# Build bitstreams only for the specified device
make zedboard
make ultra96
make netfpga_1g_cml

# Use the NUM_JOBS environment variable to control the number of parallel synthesis jobs
# By default it will use one for each CPU thread
# Reducing this number also reduces the RAM usage
NUM_JOBS=2 make zedboard
```

## License

* The source code included in this repository is subject to the terms of the Mozilla Public License, v2.0. A copy is available in [LICENSE.txt](https://github.com/zbnt/zbnt_hw/blob/master/LICENSE.txt) and [Mozilla's website](https://mozilla.org/MPL/2.0). This excludes code referenced as a submodule, located in the ```external/``` directory.
* The block designs depend on IP cores available for free as part of the Xilinx Vivado Design Suite, and licensed under the terms of the [Xilinx End User License](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/end-user-license-agreement.pdf). The source code for those cores is not distributed as part of this repository.


# zbnt_hw

HDL code for ZBNT, a configurable network tester for the [ZedBoard](http://www.zedboard.org/product/zedboard)

## Related projects

* **GUI:** [zbnt_gui](https://github.com/oscar-rc1/zbnt_gui)
* **Board software:** [zbnt_sw](https://github.com/oscar-rc1/zbnt_sw)

## Requirements

### Hardware

* [ZedBoard](http://www.zedboard.org/product/zedboard)
* [Ethernet FMC](http://ethernetfmc.com/)
	* **Warning:** The included projects were made for the 2.5V version of the Ethernet FMC, if you have the 1.8V version you'll have to edit the constraints and block designs, refer to [the official documentation](http://ethernetfmc.com/using-the-1-8v-version-with-the-zedboard/).

### Software

* [Vivado Design Suite 2018.3](https://www.xilinx.com/products/design-tools/vivado.html)
* Python 3

### Others

* [License for Xilinx Tri-Mode Ethernet MAC](https://www.xilinx.com/products/intellectual-property/temac.html)
	* Xilinx offers evaluation licenses, they allow you to generate bitstreams, but they will stop working after approximately 8 hours, requiring you to reprogram the FPGA.
	* Note that the [license](https://www.xilinx.com/products/intellectual-property/license/core-license-agreement.html) grants you permission to distribute the generated bitstreams.

## Building

1. Clone this repository, make sure all dependencies are installed before proceeding.
2. Add Vivado tools to PATH by sourcing the `settings64.sh` script in the installation directory:

~~~~
source /opt/Xilinx/Vivado/2018.3/settings64.sh
~~~~

3. `cd` to the root directory of this repository and run `make`
	* By default, the scripts will try to use the amount of threads in your CPU as the number of parallel jobs when building each project, you can override this by setting the `NUM_JOBS` environment variable.
	* This process can use a considerable amount of RAM, try reducing the amount of parallel jobs if you run out of memory.

## License

Unless otherwise noted, files in this repository are subject to the terms of the Mozilla Public License, v.2.0.
Check [LICENSE.txt](https://github.com/oscar-rc1/zbnt_hw/blob/master/LICENSE.txt) or [https://mozilla.org/MPL/2.0/]() for more details.

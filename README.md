# Senior Lab Hardware
## Minecraft World Generation on an FPGA

### Overview
This repository contains the `Vivado` and `Vitis` projects for Senior Design Lab. 

### Vivado Build
The `Vivado` project is built from a `TCL` script. To build the project, clone the repository and run the following command inside the repository folder:
```bash
vivado -mode batch -source build.tcl
```
This will generate the project in `./senior_lab_hw/senior_lab_hw.xpr`. It will also generate the Block Design. Open this project like any other `Vivado` project.

You may need to generate output products. To do this, right-click on the yellow `design_1_i` tab under `Sources` -> `Design Sources` -> `design_1_wrapper` and click `Generate Output Products`. Then you can generate the bitstream. An up-to-date bitstream is included in the root of the repository.

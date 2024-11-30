# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct /home/ndane/Desktop/senior_lab_hw/senior_lab_vitis/design_1_wrapper/platform.tcl
# 
# OR launch xsct and run below command.
# source /home/ndane/Desktop/senior_lab_hw/senior_lab_vitis/design_1_wrapper/platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {design_1_wrapper}\
-hw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}\
-out {/home/ndane/Desktop/senior_lab_hw/senior_lab_vitis}

platform write
domain create -name {standalone_ps7_cortexa9_0} -display-name {standalone_ps7_cortexa9_0} -os {standalone} -proc {ps7_cortexa9_0} -runtime {cpp} -arch {32-bit} -support-app {hello_world}
platform generate -domains 
platform active {design_1_wrapper}
domain active {zynq_fsbl}
domain active {standalone_ps7_cortexa9_0}
platform generate -quick
platform generate
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
bsp reload
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
domain active {zynq_fsbl}
catch {bsp regenerate}
domain active {zynq_fsbl}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
bsp reload
domain active {zynq_fsbl}
bsp reload
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
bsp reload
domain active {standalone_ps7_cortexa9_0}
bsp reload
catch {bsp regenerate}
domain active {zynq_fsbl}
catch {bsp regenerate}
domain active {standalone_ps7_cortexa9_0}
catch {bsp regenerate}
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform clean
domain active {zynq_fsbl}
domain active {zynq_fsbl}
catch {bsp regenerate}
domain active {zynq_fsbl}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform clean
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform generate -domains standalone_ps7_cortexa9_0,zynq_fsbl 
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform clean
platform generate
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform generate
platform clean
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform generate
platform clean
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform generate -domains standalone_ps7_cortexa9_0,zynq_fsbl 
platform clean
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains standalone_ps7_cortexa9_0,zynq_fsbl 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains standalone_ps7_cortexa9_0,zynq_fsbl 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform clean
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate
platform config -updatehw {/home/ndane/Desktop/senior_lab_hw/design_1_wrapper.xsa}
platform generate -domains 
platform clean
platform generate design_1_wrapper 
platform generate
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate
platform clean
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform active {design_1_wrapper}
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains standalone_ps7_cortexa9_0 
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/ndane/Desktop/vivado_testing/senior-lab-hardware/design_1_wrapper.xsa}
platform generate -domains 

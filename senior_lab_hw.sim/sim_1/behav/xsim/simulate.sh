#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2023.1 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Mon Nov 18 22:10:20 EST 2024
# SW Build 3865809 on Sun May  7 15:04:56 MDT 2023
#
# IP Build 3864474 on Sun May  7 20:36:21 MDT 2023
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# simulate design
echo "xsim design_1_wrapper_behav -key {Behavioral:sim_1:Functional:design_1_wrapper} -tclbatch design_1_wrapper.tcl -protoinst "protoinst_files/bd_48ac.protoinst" -protoinst "protoinst_files/design_1.protoinst" -view /home/ndane/Desktop/senior_lab_hw/design_1_wrapper_behav.wcfg -log simulate.log"
xsim design_1_wrapper_behav -key {Behavioral:sim_1:Functional:design_1_wrapper} -tclbatch design_1_wrapper.tcl -protoinst "protoinst_files/bd_48ac.protoinst" -protoinst "protoinst_files/design_1.protoinst" -view /home/ndane/Desktop/senior_lab_hw/design_1_wrapper_behav.wcfg -log simulate.log

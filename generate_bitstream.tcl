# TCL script to upgrade IP, generate output products, then generate bitstream
#exec rm *.log *.jou

# Open the project
open_project senior_lab_hw.xpr -quiet
update_compile_order -fileset sources_1
open_bd_design {senior_lab_hw.srcs/sources_1/bd/design_1/design_1.bd} -quiet

# Upgrade IP
set_property ip_repo_paths ip_repo [current_project]
update_ip_catalog -rebuild -scan_changes
if {[upgrade_ip [get_ips *]] != {}} {
    export_ip_user_files -of_objects [get_ips *] -no_script -sync -force -quiet
    generate_target all [get_files senior_lab_hw.srcs/sources_1/bd/design_1/design_1.bd]
} else {
    puts "No IP upgrade required"
}

# Generate output products
#export_simulation -of_objects [get_files senior_lab_hw.srcs/sources_1/bd/design_1/design_1.bd] -directory senior_lab_hw.ip_user_files/sim_scripts -ip_user_files_dir senior_lab_hw.ip_user_files -ipstatic_source_dir senior_lab_hw.ip_user_files/ipstatic -lib_map_path [list {modelsim=senior_lab_hw.cache/compile_simlib/modelsim} {questa=senior_lab_hw.cache/compile_simlib/questa} {xcelium=senior_lab_hw.cache/compile_simlib/xcelium} {vcs=senior_lab_hw.cache/compile_simlib/vcs} {riviera=senior_lab_hw.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

# Generate bitstream
#reset_run synth_1
#launch_runs impl_1 -to_step write_bitstream -jobs 12 -quiet
#wait_on_run impl_1
#write_hw_platform -fixed -include_bit -force -file design_1_wrapper.xsa
exit


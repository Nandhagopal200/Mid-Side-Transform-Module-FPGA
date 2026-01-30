# ============================================================================
# create_project.tcl
#
# Minimal Vivado project generator for Mid-Side AXI RTL
# Focus: RTL + Testbench simulation
#
# Vivado Version : 2024.1
# Target Device  : xck26-sfvc784-2LV-c (Kria KV260)
# ============================================================================

# ---------------------------------------------------------------------------
# Project setup
# ---------------------------------------------------------------------------
set proj_name "midside_rtl"
set proj_dir  "./${proj_name}"

create_project ${proj_name} ${proj_dir} -part xck26-sfvc784-2LV-c -force

# Optional (board info only, no BD)
set_property board_part xilinx.com:kv260_som:part0:1.4 [current_project]

# ---------------------------------------------------------------------------
# Source files (RTL)
# ---------------------------------------------------------------------------
add_files -fileset sources_1 {
    ../rtl/mid_side_core.v
    ../rtl/mid_side_inverse.v
    ../rtl/midside_axis_wrapper.v
}

set_property top midside_axis_wrapper [get_filesets sources_1]

# ---------------------------------------------------------------------------
# Simulation files (Testbench)
# ---------------------------------------------------------------------------
add_files -fileset sim_1 {
    ../tb/tb_mid_side_core.sv
    ../tb/tb_mid_side_inverse.sv
    ../tb/tb_midside_axis_wrapper.sv
}

set_property file_type SystemVerilog [get_files -of_objects [get_filesets sim_1]]

# Set default simulation top (can be changed manually)
set_property top tb_mid_side_core [get_filesets sim_1]

# ---------------------------------------------------------------------------
# Simulation settings
# ---------------------------------------------------------------------------
set_property simulator_language Mixed [current_project]
set_property xsim.simulate.runtime 1ms [get_filesets sim_1]

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
puts "INFO: RTL-only project '${proj_name}' created successfully."
puts "INFO: This project is intended for simulation and RTL inspection only."

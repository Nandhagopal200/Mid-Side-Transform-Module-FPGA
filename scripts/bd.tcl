# ============================================================================
# bd.tcl
#
# Minimal IP Integrator block design for Mid-Side AXI wrapper
#
# Purpose:
#   - Demonstrate AXI-Stream and AXI-Lite integration
#   - Instantiate midside_axis_wrapper as a reusable processing block
#
# This script intentionally omits:
#   - Processing System (PS)
#   - DMA engines
#   - Address mapping
#   - Board-specific configuration
#
# The resulting BD is schematic-level, not a full system design.
# ============================================================================

# ---------------------------------------------------------------------------
# Create block design
# ---------------------------------------------------------------------------
set design_name "midside_bd"

create_bd_design $design_name
current_bd_design $design_name

# ---------------------------------------------------------------------------
# Instantiate Mid-Side AXI wrapper
# ---------------------------------------------------------------------------
set midside_inst [create_bd_cell -type module \
    -reference midside_axis_wrapper \
    midside_axis_wrapper_0]

# ---------------------------------------------------------------------------
# Create external AXI-Stream interfaces
# ---------------------------------------------------------------------------
make_bd_intf_pins_external  [get_bd_intf_pins $midside_inst/s_axis]
make_bd_intf_pins_external  [get_bd_intf_pins $midside_inst/m_axis]

# ---------------------------------------------------------------------------
# Create external AXI-Lite interface
# ---------------------------------------------------------------------------
make_bd_intf_pins_external  [get_bd_intf_pins $midside_inst/s_axi]

# ---------------------------------------------------------------------------
# Create external clock and reset ports
# ---------------------------------------------------------------------------
make_bd_pins_external [get_bd_pins $midside_inst/aclk]
make_bd_pins_external [get_bd_pins $midside_inst/aresetn]

# ---------------------------------------------------------------------------
# Validate and save
# ---------------------------------------------------------------------------
validate_bd_design
save_bd_design

puts "INFO: Minimal block design for midside_axis_wrapper created."
puts "INFO: This BD is intended as an integration reference only."

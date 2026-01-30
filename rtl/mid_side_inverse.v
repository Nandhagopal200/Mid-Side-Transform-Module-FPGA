`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Mid-Side Inverse Transform Core
// -----------------------------------------------------------------------------
// Function:
//   L = mid + side
//   R = mid - side
//
// Characteristics:
//   - Fixed-point, signed
//   - Deterministic 1-cycle latency
//   - Explicit internal bit growth
//   - Explicit output saturation (16-bit)
// -----------------------------------------------------------------------------

module mid_side_inverse (
    input  wire               clk,
    input  wire               ce,      // clock enable
    input  wire               enable,  // inverse transform enable
    input  wire signed [15:0] mid,
    input  wire signed [15:0] side,
    output wire signed [15:0] L,
    output wire signed [15:0] R
);

    // -------------------------------------------------------------------------
    // Internal bit expansion (16-bit -> 24-bit)
    // -------------------------------------------------------------------------
    wire signed [23:0] mid_ext  = {{8{mid[15]}},  mid};
    wire signed [23:0] side_ext = {{8{side[15]}}, side};

    // -------------------------------------------------------------------------
    // Reconstruction arithmetic (24-bit domain)
    // -------------------------------------------------------------------------
    wire signed [23:0] L_24 = mid_ext + side_ext;
    wire signed [23:0] R_24 = mid_ext - side_ext;

    // -------------------------------------------------------------------------
    // Output saturation limits (16-bit signed)
    // -------------------------------------------------------------------------
    localparam signed [23:0] MAX_16 = 24'sh007FFF; // +32767
    localparam signed [23:0] MIN_16 = 24'shFF8000; // -32768

    wire signed [15:0] L_sat;
    wire signed [15:0] R_sat;

    assign L_sat = (L_24 > MAX_16) ? 16'sh7FFF :
                   (L_24 < MIN_16) ? 16'sh8000 :
                   L_24[15:0];

    assign R_sat = (R_24 > MAX_16) ? 16'sh7FFF :
                   (R_24 < MIN_16) ? 16'sh8000 :
                   R_24[15:0];

    // -------------------------------------------------------------------------
    // Output registers (1-cycle latency)
    // -------------------------------------------------------------------------
    reg signed [15:0] L_reg;
    reg signed [15:0] R_reg;

    always @(posedge clk) begin
        if (ce) begin
            if (enable) begin
                L_reg <= L_sat;
                R_reg <= R_sat;
            end else begin
                // Bypass mode (identity for debugging / pipeline bring-up)
                L_reg <= mid;
                R_reg <= side;
            end
        end
    end

    assign L = L_reg;
    assign R = R_reg;

endmodule

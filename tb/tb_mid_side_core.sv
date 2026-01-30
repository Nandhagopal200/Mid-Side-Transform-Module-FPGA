`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Testbench: Mid-Side Core
// -----------------------------------------------------------------------------
// Purpose:
//   - Functional verification of mid_side_core
//   - Validate bypass and encode modes
//   - Capture results in CSV for offline inspection
//
// Assumptions:
//   - Fixed 1-cycle latency
//   - ce is held high
// -----------------------------------------------------------------------------

module tb_mid_side_core;

    // -------------------------------------------------------------------------
    // DUT Interface
    // -------------------------------------------------------------------------
    reg  clk;
    reg  ce;
    reg  enable;
    reg  signed [15:0] L;
    reg  signed [15:0] R;

    wire signed [15:0] mid;
    wire signed [15:0] side;

    // CSV file handle
    integer f;

    // -------------------------------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------------------------------
    mid_side_core dut (
        .clk   (clk),
        .ce    (ce),
        .enable(enable),
        .L     (L),
        .R     (R),
        .mid   (mid),
        .side  (side)
    );

    // -------------------------------------------------------------------------
    // Clock generation (100 MHz)
    // -------------------------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // -------------------------------------------------------------------------
    // Apply one test vector
    // -------------------------------------------------------------------------
    task apply_vector(
        input signed [15:0] in_L,
        input signed [15:0] in_R,
        input               en
    );
    begin
        // Apply inputs
        L      <= in_L;
        R      <= in_R;
        enable <= en;

        // Wait exactly one pipeline latency
        @(posedge clk);
        #1;

        // Log result
        $fwrite(
            f,
            "%0t,%0d,%0d,%0d,%0d,%0d\n",
            $time, enable, in_L, in_R, mid, side
        );
    end
    endtask

    // -------------------------------------------------------------------------
    // Test sequence
    // -------------------------------------------------------------------------
    initial begin
        // Open CSV file
        f = $fopen("tb_mid_side_core.csv", "w");
        $fwrite(f, "Time,Enable,In_L,In_R,Out_Mid,Out_Side\n");

        // Initial conditions
        ce     = 1'b1;
        enable= 1'b0;
        L      = 16'sd0;
        R      = 16'sd0;

        #20;
        $display("=== Mid/Side Core Test Start ===");

        // ---------------------------------------------------------------------
        // Test Case 1: Bypass mode
        // Expect: mid = L, side = R
        // ---------------------------------------------------------------------
        apply_vector( 1000,   500, 0);
        apply_vector( -500,   200, 0);
        apply_vector(32767, -32768, 0);

        // ---------------------------------------------------------------------
        // Test Case 2: Encode mode
        // mid  = (L + R) >>> 1
        // side = (L - R) >>> 1
        // ---------------------------------------------------------------------
        apply_vector( 2000,  1000, 1); // mid=1500, side=500
        apply_vector(-2000,  2000, 1); // mid=0,    side=-2000
        apply_vector(    3,     0, 1); // mid=1,    side=1
        apply_vector(  100,   -50, 1); // mid=25,   side=75

        #20;
        $fclose(f);

        $display("=== Test Done. Results written to tb_mid_side_core.csv ===");
        $finish;
    end

endmodule

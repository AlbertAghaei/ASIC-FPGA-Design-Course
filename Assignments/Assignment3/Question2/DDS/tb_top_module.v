`timescale 1ns / 1ps

module tb_top_module;

    // Testbench signals
    reg clk;
    reg [31:0] phase_input;    // Phase input
    wire [15:0] sine_out;
    wire [15:0] cosine_out;
    wire valid_out;

    // Generate 250 MHz clock (period = 4 ns)
    initial begin
        clk = 0;
        forever #2 clk = ~clk;
    end

    // Instantiate DUT (top module)
    top_module uut (
        .clk(clk),
        .phase_input(phase_input),  // Phase input for direct control
        .sine_out(sine_out),
        .cosine_out(cosine_out),
        .valid_out(valid_out)
    );

    // Apply test values to phase input
    initial begin
        // Step 1: Set initial phase for sine and cosine
        phase_input = 32'd0;   // Phase 0 for initial condition
        #1000000;              // Run simulation for 1 ms
        
        // Step 2: Change phase for sine and cosine
        phase_input = 32'd50000; // Phase shift for next cycle
        #1000000;              // Run for 1 ms

        // Step 3: Change phase again
        phase_input = 32'd100000; // Another phase shift
        #1000000;              // Run for 1 ms

        $stop;  // End simulation
    end

endmodule

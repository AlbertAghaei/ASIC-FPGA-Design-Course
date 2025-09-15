`timescale 1ns / 1ps

module tb_FCW;

    // Testbench signals
    reg clk;
    reg [31:0] fcw_input;   // Frequency control word input
    wire [15:0] sine_out;
    wire [15:0] cosine_out;
    wire valid_out;

    // Generate 250 MHz clock (period = 4 ns)
    initial begin
        clk = 0;
        forever #2 clk = ~clk;  // Clock generation with 250 MHz frequency
    end

    // Instantiate DUT (Device Under Test)
    FCW uut (
        .clk(clk),
        .fcw_input(fcw_input),
        .sine_out(sine_out),
        .cosine_out(cosine_out),
        .valid_out(valid_out)
    );

    // Apply test values to FCW input
    initial begin
        // Step 1: Set FCW for ~1 kHz output (for 250 MHz clock, FCW = 17179)
        fcw_input = 32'd17179;  // For 1 kHz
        #5000000;  // Run simulation for 5 ms to see 5 full periods of 1 kHz signal

        // Step 2: Change to ~2 kHz output (FCW = 34359)
        fcw_input = 32'd34359;  // For 2 kHz
        #5000000;  // Run for 5 ms to see 5 full periods of 2 kHz signal

        // Step 3: Change to ~500 Hz output (FCW = 8590)
        fcw_input = 32'd8590;   // For 500 Hz
        #5000000;  // Run for 5 ms to see 5 full periods of 500 Hz signal

        $stop;  // End simulation
    end

endmodule

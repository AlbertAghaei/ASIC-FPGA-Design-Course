`timescale 1ns / 1ps

module tb_top_module;

    // Testbench signals
    reg clk;
    reg [31:0] phase_input;    // Phase input for DDS
    wire signed [15:0] sine_out;
    wire signed [15:0] cosine_out;
    wire valid_out;

    // FFT Output signals
    wire [31:0] fft_data_out;  // FFT output data (complex)
    wire fft_valid_out;        // FFT valid signal

    // Instantiate the top module (DDS and FFT)
    top_module uut (
        .clk(clk),
        .phase_input(phase_input),  // Phase input for direct control
        .sine_out(sine_out),
        .cosine_out(cosine_out),
        .valid_out(valid_out),
        .fft_data_out(fft_data_out),
        .fft_valid_out(fft_valid_out)
    );

    // Generate 250 MHz clock (period = 4 ns)
    initial begin
        clk = 0;
        forever #2 clk = ~clk;
    end

    // Apply test values to phase input and verify results
    initial begin
        // Step 1: Set initial phase for sine and cosine
        phase_input = 32'd0;   // Initial phase for DDS
        #1000000;              // Run simulation for 1 ms
        
        // Step 2: Change phase for sine and cosine
        phase_input = 32'd50000; // Phase shift for next cycle
        #1000000;              // Run for 1 ms

        // Step 3: Change phase again
        phase_input = 32'd100000; // Another phase shift
        #1000000;              // Run for 1 ms

        // End simulation
        $stop;  // End simulation
    end

endmodule

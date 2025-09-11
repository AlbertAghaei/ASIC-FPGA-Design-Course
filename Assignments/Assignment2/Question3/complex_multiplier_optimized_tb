`timescale 1ns / 1ps

module complex_multiplier_optimized_tb;

    // Inputs
    reg clk;
    reg [17:0] A, B, C, D;

    // Outputs
    wire [35:0] real_out, imag_out;

    // Instantiate the Unit Under Test (UUT)
    complex_multiplier_optimized uut (
        .clk(clk),
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .real_out(real_out),
        .imag_out(imag_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        A = 18'h0;
        B = 18'h0;
        C = 18'h0;
        D = 18'h0;

        // Wait for global reset or initial setup
        #100;

        // Test case 1
        A = 18'h1;
        B = 18'h2;
        C = 18'h3;
        D = 18'h4;
        #100; // Wait for the outputs to stabilize
        $display("Test Case 1: A=%h, B=%h, C=%h, D=%h | Real=%h, Imag=%h",
                 A, B, C, D, real_out, imag_out);

        // Test case 2
        A = 18'h5;
        B = 18'h6;
        C = 18'h7;
        D = 18'h8;
        #100;
        $display("Test Case 2: A=%h, B=%h, C=%h, D=%h | Real=%h, Imag=%h",
                 A, B, C, D, real_out, imag_out);

        // Test case 3
        A = 18'hFFFF;
        B = 18'hFFFF;
        C = 18'hFFFF;
        D = 18'hFFFF;
        #100;
        $display("Test Case 3: A=%h, B=%h, C=%h, D=%h | Real=%h, Imag=%h",
                 A, B, C, D, real_out, imag_out);

        // Test case 4
        A = 18'h1234;
        B = 18'h5678;
        C = 18'h9ABC;
        D = 18'hDEF0;
        #100;
        $display("Test Case 4: A=%h, B=%h, C=%h, D=%h | Real=%h, Imag=%h",
                 A, B, C, D, real_out, imag_out);

        // End simulation
        $stop;
    end

endmodule

`timescale 1ns / 1ps

module Cube1_tb;

    reg clk;
    reg rst;
    reg [7:0] in;
    wire [23:0] out;

    // Instantiate the module under test
     Cube1_shared_minimal uut (
        .clk(clk),
        .rst(rst),
        .in(in),
        .out(out)
    );

    // Clock generation: 11 ns period 
    initial begin
        clk = 0;
        forever #5.5 clk = ~clk;
    end

    initial begin
        // Initialize
        rst = 1;
        in = 0;

        // Wait a few cycles with reset high
        #22;
        rst = 0;

        // Apply inputs and observe outputs
        #55 in = 2;   // 2^3 = 8
        #55 in = 3;   // 3^3 = 27
        #55 in = 4;   // 4^3 = 64
        #55 in = 5;   // 5^3 = 125
        #55 in = 10;  // 10^3 = 1000
        #55 in = 255; // Large input

        // Wait before finishing
        #50;

        $finish;
    end

endmodule

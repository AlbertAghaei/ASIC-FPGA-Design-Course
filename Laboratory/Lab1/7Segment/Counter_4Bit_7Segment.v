`timescale 1ns / 1ps
module Counter_4Bit_7Segment (
    input clk,          // Clock signal
    input rst,          // Reset signal (active-high)
    output a,           // 7-segment segment a
    output b,           // 7-segment segment b
    output c,           // 7-segment segment c
    output d,           // 7-segment segment d
    output e,           // 7-segment segment e
    output f,           // 7-segment segment f
    output g,           // 7-segment segment g
    output dp,          // Decimal point (always off)
    output [3:0] dig    // Digit control (4-bit)
);

    reg [3:0] count;            // 4-bit counter
    reg [24:0] clk_div;         // Clock divider (for 50 MHz to 1 Hz)
    reg clk_1hz;                // 1 Hz clock signal

    // Instantiate the BCD-to-7-segment converter
    BCD_to_7Segment bcd_to_7seg (
        .Dip(count),       // BCD input from the counter
        .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g), .dp(dp), .dig(dig)
    );

    // Clock divider to generate 1 Hz clock from the original clk (50 MHz)
    always @(posedge clk or posedge rst) begin
        if (!rst) begin
            clk_div <= 25'b0;   // Reset the divider counter
            clk_1hz <= 0;        // Reset the 1 Hz clock signal
        end else begin
            // Divide the clock by 50 million to achieve 1 Hz signal
            if (clk_div >= 25'd24999999) begin
                clk_div <= 25'b0;   // Reset the divider counter
                clk_1hz <= ~clk_1hz; // Toggle the 1 Hz clock signal
            end else begin
                clk_div <= clk_div + 1; // Increment the divider counter
            end
        end
    end

    // Counter logic based on the 1 Hz clock signal
    always @(posedge clk_1hz or posedge rst) begin
        if (!rst) begin
            count <= 4'b0000;  // Reset the counter to 0
        end else begin
            if (count == 4'b1111)  // If count reaches 15, reset to 0
                count <= 4'b0000;
            else
                count <= count + 1;  // Increment the counter
        end
    end

endmodule

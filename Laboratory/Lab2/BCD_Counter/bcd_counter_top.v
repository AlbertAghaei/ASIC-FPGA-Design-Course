module bcd_counter(
    input clk,          // 50 MHz clock input
    input rst,          // Reset input (button)
    output [6:0] HEX2, // 7-segment for hundreds
    output [6:0] HEX1, // 7-segment for tens
    output [6:0] HEX0  // 7-segment for ones
);

    wire enable_1hz; // 1 Hz enable signal from 50 million counter
    wire [3:0] count_hundreds, count_tens, count_ones;
    wire enable_tens, enable_hundreds;

    // Instantiate the 50 Million Counter
    counter_50M counter_50M_inst (
        .clk(clk),
        .rst(rst),
        .enable(enable_1hz)
    );

    // Instantiate the 0-9 Counter for ones, tens, and hundreds
    counter_0to9 ones_counter (
        .clk(clk),
        .rst(rst),
        .enable(enable_1hz),
        .count(count_ones)
    );

    // Enable tens counter only when ones counter overflows
    assign enable_tens = enable_1hz && (count_ones == 9);
    
    counter_0to9 tens_counter (
        .clk(clk),
        .rst(rst),
        .enable(enable_tens),
        .count(count_tens)
    );

    // Enable hundreds counter only when tens and ones counters overflow
    assign enable_hundreds = enable_tens && (count_tens == 9);
    
    counter_0to9 hundreds_counter (
        .clk(clk),
        .rst(rst),
        .enable(enable_hundreds),
        .count(count_hundreds)
    );

    // Instantiate the Hex Display for HEX2 (hundreds), HEX1 (tens), and HEX0 (ones)
    hex_display hex2 (
        .hex(count_hundreds),
        .seg(HEX2)
    );

    hex_display hex1 (
        .hex(count_tens),
        .seg(HEX1)
    );

    hex_display hex0 (
        .hex(count_ones),
        .seg(HEX0)
    );

endmodule

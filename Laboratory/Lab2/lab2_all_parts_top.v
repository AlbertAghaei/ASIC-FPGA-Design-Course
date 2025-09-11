module lab2_all_parts(
    input wire CLK_50,      // 50 MHz Clock
    input wire rst,         // Reset button
    input wire [3:0] button, // 4 buttons for sender
    output wire [2:0] LEDR, // 3 LEDs from receiver
    output wire [6:0] Dig0, // 7-segment display for ones place
    output wire [6:0] Dig1, // 7-segment display for tens place
    output wire [6:0] Dig2  // 7-segment display for hundreds place
);

    // Internal connections
    wire Tx, Rx;
    wire [2:0] key;
    wire trigger;
    wire enable_1hz;
    wire [3:0] count_hundreds, count_tens, count_ones;
    wire enable_tens, enable_hundreds;

    // Instantiate sender module
    sender sender_inst (
        .rst(rst),
        .clk(CLK_50),
        .button(button),
        .Tx(Tx)
    );
    assign Rx = Tx; // Direct connection

    // Instantiate receiver module
    receiver receiver_inst (
        .rst(rst),
        .clk(CLK_50),
        .Rx(Rx),
        .key(key)
    );
    assign LEDR = key; // Connect receiver output to LEDs

    // Instantiate SecretFSM module
    SecretFSM secretFSM_inst (
        .clk(CLK_50),
        .rst(rst),
        .key(key),
        .trigger(trigger)
    );

    // Instantiate 50M counter (generates 1Hz enable signal)
    counter_50M counter_50M_inst (
        .clk(CLK_50),
        .rst(rst || trigger), // Reset when trigger is active
        .enable(enable_1hz)
    );

    // Instantiate BCD counters
    counter_0to9 ones_counter (
        .clk(CLK_50),
        .rst(rst || trigger),
        .enable(enable_1hz),
        .count(count_ones)
    );
    
    assign enable_tens = enable_1hz && (count_ones == 9);
    counter_0to9 tens_counter (
        .clk(CLK_50),
        .rst(rst || trigger),
        .enable(enable_tens),
        .count(count_tens)
    );
    
    assign enable_hundreds = enable_tens && (count_tens == 9);
    counter_0to9 hundreds_counter (
        .clk(CLK_50),
        .rst( rst || trigger),
        .enable(enable_hundreds),
        .count(count_hundreds)
    );

    // Instantiate HEX display drivers
    hex_display hex2 (
        .hex(count_hundreds),
        .seg(Dig2)
    );
    hex_display hex1 (
        .hex(count_tens),
        .seg(Dig1)
    );
    hex_display hex0 (
        .hex(count_ones),
        .seg(Dig0)
    );

endmodule


module top(
    input wire CLK_50,
    input wire [0:0]KEY ,
    input wire [3:0] SW,  // 4 buttons
    output wire [2:0] LEDR     // 3 LEDs
);

    // Internal wires
    wire Tx;
    wire Rx;
    wire [2:0] key;

    // Instantiate the sender module
    sender sender_inst (
        .rst(KEY),
        .clk(CLK_50),
        .button(SW),
        .Tx(Tx)
    );
    assign Rx = Tx;

    // Instantiate the receiver module
    receiver receiver_inst (
        .rst(KEY),
        .clk(CLK_50),
        .Rx(Rx),  // Connect Tx from sender to Rx of receiver
        .key(key)
    );

    // Connect the key output from the receiver to the LEDs
    assign LEDR = key;

endmodule

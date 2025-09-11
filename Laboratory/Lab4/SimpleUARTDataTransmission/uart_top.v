module uart_top(
    input  wire       clk,           // 96kHz clock input (for test; replace with 50MHz for FPGA)
    input  wire       rst,           // Active-high reset
    //input  wire [3:0] deep_switches, // Switches to send
    input  wire       KEY,           // Button to trigger transmission
    output wire [3:0] leds           // Output LEDs from received data
);

    wire tx_wire;

    // Instantiate UART Sender
    uart_sender sender_inst (
        .rst(rst),
        .clk(clk),
        .deep_switches(4'b1011),
        .KEY(KEY),
        .Tx(tx_wire)
    );

    // Instantiate UART Receiver
    uart_receiver receiver_inst (
        .clk(clk),
        .rst(rst),
        .rx(tx_wire),
        .leds(leds)
    );

endmodule

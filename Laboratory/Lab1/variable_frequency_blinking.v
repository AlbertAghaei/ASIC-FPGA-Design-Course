`timescale 1ns / 1ps
module variable_frequency_blinking(
    input wire clk,            // 50 MHz clock input
    input wire [3:0] button,   // 4 buttons to select blinking frequency
    output reg LEDblink        // Output to control the LED blinking
);

    // Frequency lookup based on button press
    reg [25:0] counter;       // 26-bit counter for dividing the clock
    reg [25:0] counter_limit; // Variable counter limit
    wire [2:0] encoded_button;  // Output from the priority encoder

    // Instantiate the priority encoder to determine which button is pressed
    priority_encoder encoder (
        .btn(button),
        .led(encoded_button)
    );

    // Frequency selection based on the priority encoder output
    always @(*) begin
        case (encoded_button)
            3'b100: counter_limit = 50_000_000 * 2;  // 0.5 Hz (50M / 2)
            3'b011: counter_limit = 50_000_000;      // 1 Hz (50M / 1)
            3'b010: counter_limit = 50_000_000 / 2;  // 2 Hz (50M / 2)
            3'b001: counter_limit = 50_000_000 / 4;  // 4 Hz (50M / 4)
            default: counter_limit = 50_000_000;     // Default to 1 Hz if no button pressed
        endcase
    end

    // Blinking logic based on counter and selected frequency
    always @(posedge clk) begin
        if (counter == counter_limit - 1) begin
            counter <= 0;           // Reset counter when it reaches the limit
            LEDblink <= ~LEDblink;  // Toggle LED
        end else begin
            counter <= counter + 1; // Increment counter
        end
    end

endmodule


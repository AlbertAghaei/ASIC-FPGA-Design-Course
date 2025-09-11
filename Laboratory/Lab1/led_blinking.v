`timescale 1ns / 1ps


module led_blinking(
    input wire clk,           // Input clock signal (50 MHz)
    output reg LEDblink      // Output to control the LED
);

    // Define the counter limit for 1 Hz blinking frequency
    // Assuming a 50 MHz clock, the counter must count up to 25 million (50M / 2)
    reg [31:0] counter;  // 25-bit counter to count up to 25 million

    always @(posedge clk) begin
        if (counter == 50_000_000 - 1) begin
            counter <= 0;           // Reset counter when it reaches the limit
            LEDblink <= ~LEDblink;  // Toggle the LED on/off
        end else begin
            counter <= counter + 1;  // Increment the counter
        end
    end

endmodule

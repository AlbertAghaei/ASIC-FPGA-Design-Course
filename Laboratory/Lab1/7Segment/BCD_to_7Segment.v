`timescale 1ns / 1ps
module BCD_to_7Segment (
   input clk,           // Clock signal for multiplexing
    output reg a, b, c, d, e, f, g, dp, // Seven-segment display segments
    output reg [3:0] dig // Display control for multiplexing (1 digit)
);

    reg [7:0] Dip = 8'b01110011; // 7 is 4'b0111 and 3 is 4'b0011
    reg [1:0] digit_select = 2'b00; // Used for multiplexing
    reg [15:0] counter = 16'b0;  // Counter for multiplexing timing
   
    always @(posedge clk) begin
        // Increment counter for multiplexing control
        counter <= counter + 1;
       
        if (counter == 16'hFFFF) begin // Toggle digit selection after counting
            digit_select <= digit_select + 1;
            counter <= 0; // Reset the counter after it reaches its max value
        end
    end
   
    // Always block to control the segment display based on digit_select
    always @(*) begin
        // Default all segments to off
        {a, b, c, d, e, f, g} = 7'b1111111;
        dp = 1;   // Decimal point is off
       
        // Based on digit_select, we show either digit 7 or 3
        case (digit_select)
            2'b00: begin
                // Display the first digit (7)
                case (Dip[7:4]) // Upper 4 bits for 7
                    4'b0111: {a, b, c, d, e, f, g} = 7'b0001111; // 7
                    default: {a, b, c, d, e, f, g} = 7'b1111111;
                endcase
                dig = 4'b0001; // Activate digit (show the first digit)
            end
           
            2'b01: begin
                // Display the second digit (3)
                case (Dip[3:0]) // Lower 4 bits for 3
                    4'b0011: {a, b, c, d, e, f, g} = 7'b0000110; // 3
                    default: {a, b, c, d, e, f, g} = 7'b1111111;
                endcase
                dig = 4'b0010; // Activate digit (show the second digit)
            end
           
            default: begin
                {a, b, c, d, e, f, g} = 7'b1111111; // Turn off all segments
                dig = 4'b0000; // No active digit
            end
        endcase
    end

endmodule


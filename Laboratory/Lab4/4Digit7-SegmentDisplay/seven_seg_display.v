module seven_seg_display (
    input clk,
    input rst,
   // input [27:0] data,       // 4 digits, each 7 bits (abcdefg)
    output reg [3:0] dig,    // active-low digit enable
    output reg [6:0] abcdefg // 7-segment outputs
);
    // Parameters for clock and refresh rate
    parameter CLK_FREQ_HZ = 50000000;    // 50 MHz
    parameter REFRESH_RATE_HZ = 1000;    // 1 kHz
    parameter REFRESH_COUNT = CLK_FREQ_HZ / REFRESH_RATE_HZ / 4;

   // wire [27:0] data;
    reg [31:0] count;
    reg [1:0] digit_index;


  //  assign data = 28'b0000110000011000001100000110;
    always @(posedge clk or posedge rst) begin
        if (rst==0) begin
            count <= 16'd0;
            digit_index <= 2'd0;
        end else begin
            if (count == REFRESH_COUNT -1 ) begin
                count <= 16'd0;

                // Correct wrapping
                if (digit_index == 2'd3)
                    digit_index <= 2'd0;
                else
                    digit_index <= digit_index + 1;
            end else begin
                count <= count + 1;
            end
        end
    end

    always @(*) begin
        case (digit_index)
            2'd0: begin
                abcdefg =7'b0000110;
                dig = 4'b0001;
            end
            2'd1: begin
                abcdefg = 7'b0000110;
                dig = 4'b0010;
            end
            2'd2: begin
                abcdefg = 7'b0000110;
                dig = 4'b0100;
            end
            2'd3: begin
                abcdefg = 7'b0000110;
                dig = 4'b1000;
            end
            default: begin
                abcdefg = 7'b1111111;
                dig = 4'b0000;
            end
        endcase
    end
endmodule

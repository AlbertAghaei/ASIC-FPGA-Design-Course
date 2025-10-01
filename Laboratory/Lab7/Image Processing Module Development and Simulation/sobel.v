`timescale 1ns / 1ps

module sobel(
    input wire clk,                    // Pixel clock
    input wire [23:0] Data_in,         // 24-bit RGB input
    input wire HSync,                  // Horizontal sync input
    input wire VSync,                  // Vertical sync input
    input wire ActiveVideo,            // Active video signal
    output reg [23:0] Data_out,        // 24-bit output
    output reg HSync_out,              // Horizontal sync output
    output reg VSync_out,              // Vertical sync output
    output reg ActiveVideo_out         // Active video output
);

    // Parameters
    parameter WIDTH = 1280;           

    wire [7:0] R = Data_in[23:16];  // Red 
    wire [7:0] G = Data_in[15:8];   // Green 
    wire [7:0] B = Data_in[7:0];    // Blue 
    
    wire [9:0] sum = R + G + B;    
    wire [15:0] product ;
    assign product = sum * 8'd85;
    wire [7:0] gray_val ;
    assign gray_val = product >> 8;      
    //  (R + G + B) / 3 using (sum * 85) >> 8
    //  85/256 = 1/3  :)))))))
    
    
    // 3-line buffers (2 delay lines, 1 current line shift)
    reg [7:0] line1 [0:WIDTH-1];
    reg [7:0] line2 [0:WIDTH-1];
    reg [7:0] shift0, shift1, shift2;

    integer i;
    reg [10:0] col = 0;

    // 3x3 window pixels
    reg [7:0] p00, p01, p02;
    reg [7:0] p10, p11, p12;
    reg [7:0] p20, p21, p22;

    // Gx, Gy, and G
    wire signed [10:0] Gx ;
    assign Gx = -p00 - (p10 << 1) - p20 + p02 + (p12 << 1) + p22;
    wire signed [10:0] Gy ;
    assign Gy =  p00 + (p01 << 1) + p02 - p20 - (p21 << 1) - p22;
    wire [10:0] absGx ;
    assign absGx = (Gx < 0) ? -Gx : Gx;
    wire [10:0] absGy ;
    assign absGy = (Gy < 0) ? -Gy : Gy;
    wire [10:0] gradient_sum ;
    assign gradient_sum = absGx + absGy;
    wire [7:0] edge_val ;
    assign edge_val  = (gradient_sum > 255) ? 8'd255 : gradient_sum[7:0];

    always @(posedge clk) begin
        // Forward sync signals
        HSync_out <= HSync;
        VSync_out <= VSync;
        ActiveVideo_out <= ActiveVideo;

        if (ActiveVideo) begin
            // Shift register for current line
            shift0 <= shift1;
            shift1 <= shift2;
            shift2 <= gray_val;

            // Update window
            p00 <= p01;  p01 <= p02;  p02 <= line2[col];
            p10 <= p11;  p11 <= p12;  p12 <= line1[col];
            p20 <= p21;  p21 <= p22;  p22 <= gray_val;

            // Output edge value
            Data_out <= {edge_val, edge_val, edge_val};

            // Store pixels in line buffers
            line2[col] <= line1[col];
            line1[col] <= gray_val;

            col <= (col == WIDTH-1) ? 0 : col + 1;
        end else begin
            col <= 0;
            Data_out <= 0;
        end
    end
    
    
endmodule
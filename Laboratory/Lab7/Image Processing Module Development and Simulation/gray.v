`timescale 1ns / 1ps

module gray(
    input wire clk,                    // Pixel clock
    input wire [23:0] Data_in,         // 24-bit RGB input (R[23:16], G[15:8], B[7:0])
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

    wire [7:0] gray;
    wire [9:0] sum = R + G + B;    
    wire [15:0] product ;
    assign product = sum * 8'd85;
    wire [7:0] gray_val ;
    assign gray_val = product >> 8;      
   // assign gray = (sum * 8'd85) >> 8;    
   
    //  (R + G + B) / 3 using (sum * 85) >> 8
    //  85/256 = 1/3  :)))))))
    
    always@(posedge clk)  begin
    HSync_out <= HSync;
    VSync_out <= VSync;
    ActiveVideo_out <= ActiveVideo;
    
    
    if(ActiveVideo_out)    Data_out <= {gray_val,gray_val,gray_val};
    else               Data_out <= 24'd0;
    end

endmodule

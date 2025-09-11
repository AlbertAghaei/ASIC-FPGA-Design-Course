module Cube1_pipeline (
    input clk,
    input rst,
    input [7:0] in,
    output reg [23:0] out
);

    reg [7:0] in_reg1,in_reg2;
    reg [15:0] stage1_result; // intermediate: in * in
    reg valid;
    reg [23:0] stage2_result;
   
    // Stage 0: Register input
    always @(posedge clk or posedge rst) begin
        if (rst)
            in_reg1 <= 0;
        else
            in_reg1 <= in;
    end

    // Stage 1: Square the input (in * in) and again register input
    always @(posedge clk or posedge rst) begin
        if (rst)
            stage1_result <= 0;
        else
            stage1_result <= in_reg1 * in_reg1;
      
            
    end
   always @(posedge clk or posedge rst) begin
        if (rst)
            in_reg2 <= 0;
        else
            in_reg2 <= in_reg1;
      end
    // Stage 2: Multiply again (square * in) and register output
    always @(posedge clk or posedge rst) begin
        if (rst )
            stage2_result <= 0;
        else
        begin
            stage2_result <= stage1_result * in_reg2;
            valid <= 1'b1;
        end
            
   // Stage 3: register output
    end
     always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 0;
        else if(valid==1)
      
            out <= stage2_result;

            

    end

   

endmodule

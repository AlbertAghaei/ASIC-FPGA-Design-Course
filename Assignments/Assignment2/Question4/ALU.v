module ALU (
    input [7:0] i_a, i_b,
    input [3:0] i_cont,
    input i_clk,
    output reg [8:0] o_out
);
reg [15:0] product;
reg [7:0] quotient, remainder;
            integer i;

always @(posedge i_clk) begin
    case (i_cont)
        4'b0000: {o_out[8], o_out[7:0]} = i_a + i_b;  // Addition with carry
        4'b0001: {o_out[8], o_out[7:0]} = i_a - i_b;  // Subtraction with carry
        4'b0010: begin // Multiplication with lower 8 bits + carry 
          product = i_a * i_b; 
          o_out[7:0] = product[7:0];  
          o_out[8] = |product[15:8];  
        end
        4'b0011: begin  // Division using Restoring Division Algorithm
            
            quotient = 0;
            remainder = 0;
            for (i = 7; i >= 0; i = i - 1) begin
                remainder = (remainder << 1) | (i_a[i]);
                if (remainder >= i_b) begin
                    remainder = remainder - i_b;
                    quotient[i] = 1;
                end
            end
            o_out = {1'b0, quotient};  // Division result in lower 8 bits
        end
        4'b0100: o_out = i_a << 1;  // Logical left shift
        4'b0101: o_out = i_a >> 1;  // Logical right shift
        4'b0110: o_out = {i_a[6:0], i_a[7]};  // Rotate left
        4'b0111: o_out = {i_a[0], i_a[7:1]};  // Rotate right
        4'b1000: o_out = i_a & i_b;  // AND
        4'b1001: o_out = i_a | i_b;  // OR
        4'b1010: o_out = i_a ^ i_b;  // XOR
        4'b1011: o_out = {1'b0,~(i_a | i_b)};  // NOR
        4'b1100: o_out = {1'b0,~(i_a & i_b)};  // NAND
        4'b1101: o_out = {1'b0,~(i_a ^ i_b)};  // XNOR
        4'b1110: o_out = (i_a == i_b) ? 9'b1 : 9'b0;  // Equality check
        4'b1111: o_out = (i_a > i_b) ? 9'b1 : 9'b0;  // Greater than check
        default: o_out = 9'b0;  // Default case
    endcase
end

endmodule

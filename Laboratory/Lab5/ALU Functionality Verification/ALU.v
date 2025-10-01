`timescale 1ns/1ns

module ALU (
    input wire [1:0] op,
    input wire [31:0] A,
    input wire [31:0] B,
    output wire [31:0] Out1
);

reg [31:0] Out_temp;

assign Out1 = Out_temp;

always @(*) begin
    case (op)
        2'b00: Out_temp = A + B; // ADD
        2'b01: Out_temp = A - (~B); // SUB
        2'b10: Out_temp = ~(A & B); // NAND
        2'b11: Out_temp = ~(A | B); // NOR
    endcase
end
    
endmodule

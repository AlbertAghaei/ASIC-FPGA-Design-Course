`timescale 1ns/1ns

module XOR1 (
    input [1:0] A,
    input [1:0] B,
    output [1:0] C
);

assign C = A ^ B;
    
endmodule

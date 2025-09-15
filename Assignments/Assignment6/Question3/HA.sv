module HA(
input wire logic A,B,
output var logic S,C
            
    );
    
    assign S = A ^ B;
    assign C = A & B;
    
endmodule

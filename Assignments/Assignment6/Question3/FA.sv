module FA(
input wire logic A,B,Cin,
output var logic S,Cout
    );
    
    assign S    = ( A ^ B ) ^ Cin ;
    assign Cout = ( A & B ) | (( A ^ B ) &  Cin );
    
endmodule

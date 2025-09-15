module top_module #(
   parameter int WIDTH = 32
)(
    input wire logic [WIDTH - 1 : 0] A , B,
    output var logic [WIDTH - 1 : 0] S,
    output var logic Cout
    );
    
    var logic [WIDTH - 1 : 0] C;
    
    genvar i;
    generate 
    for ( i = 0 ; i < WIDTH ; i = i + 1 ) begin : adder_32
        if ( i == 0 ) begin
        HA ha_inst (
        .A(A[i]) , .B(B[i]) , .S(S[i]) , .C(C[i]) );
        end
        else begin
        FA fa_inst (
        .A(A[i]) , .B(B[i]) , .S(S[i]) , .Cout(C[i]) , .Cin(C[i - 1]) );
        end
        end
        endgenerate
 
 assign Cout = C[WIDTH - 1];
 
 
endmodule

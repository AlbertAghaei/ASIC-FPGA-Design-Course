module top_module_tb;

  parameter int WIDTH = 32;

  logic [WIDTH - 1 : 0] A, B;
  logic [WIDTH - 1 : 0] S;
  logic Cout;

  top_module #(.WIDTH(WIDTH)) uut (
    .A(A), .B(B), .S(S), .Cout(Cout)
  );


  initial begin
    // test1
    A = 32'd15;
    B = 32'd10;
    #1;  

    // test2 Overflow
    A = 32'hffffffff; 
    B = 32'd1;
    #1;

    $finish;
  end

endmodule

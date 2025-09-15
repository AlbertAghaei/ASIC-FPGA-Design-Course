class Int_Test extends calculator #(int);
function new (int value1, int value2);
super.new(value1,value2);
endfunction
endclass

function void display_int_results(Int_Test test);
  $display("value1 = %0d, value2 = %0d", test.get_a(), test.get_b());
  $display("Add: %0d", test.add());
  $display("Subtract: %0d", test.sub());
  $display("Multiply: %0d", test.mult());
endfunction


module calculator_tb;
initial begin
  Int_Test test1 = new(12,8);
  display_int_results(test1);
  
  end
endmodule
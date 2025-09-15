
class Real_Test extends calculator #(real);
function new (real value1, real value2);
super.new(value1,value2);
endfunction
endclass

function void display_real_results(Real_Test test);
  $display("value1 = %0.2f, value2 = %0.2f", test.get_a(), test.get_b());
  $display("Add: %0.2f", test.add());
  $display("Subtract: %0.2f", test.sub());
  $display("Multiply: %0.2f", test.mult());
endfunction


module calculator_tb;
initial begin
  Real_Test test1 = new(10.5,3.2);
  display_real_results(test1);
  
  end
endmodule
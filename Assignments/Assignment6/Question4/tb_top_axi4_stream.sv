module tb_top_axi4_stream;

  logic clk, rst;
  logic [31:0] result;

  // Instantiate DUT
  top_axi4_stream dut (
    .clk(clk),
    .rst(rst),
    .result(result)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset and stimulus
  initial begin
    rst = 1;
    #20;
    rst = 0;
    #20;
    rst = 1;

    // Run long enough to complete two transmissions
    #2000;

    $display("Final result = %0d", result);
    $finish;
  end

endmodule

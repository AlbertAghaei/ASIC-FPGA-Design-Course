module tb_sequence_detector;

  logic clk;
  logic rst;
  logic in;
  logic detected;

  sequence_detector_1011 dut (
    .clk(clk),
    .rst(rst),
    .in(in),
    .detected(detected)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst = 1;
    in  = 0;

    $display("in\tdetected");
    $monitor("%b\t%b",in, detected);

    #10 rst = 0;
    #10 rst = 1;

    repeat(2) @(posedge clk); in = 1;   // 1
    repeat(2) @(posedge clk); in = 0;   // 0
    repeat(2) @(posedge clk); in = 1;   // 1
    repeat(2) @(posedge clk); in = 1;   // 1 

    repeat(4) @(posedge clk) in = $random;

    #20 $finish;
  end

endmodule

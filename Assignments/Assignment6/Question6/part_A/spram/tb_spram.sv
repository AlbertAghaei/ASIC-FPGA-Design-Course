module tb_spram_top;

  logic clk;
  logic rst;
  logic ena_in, we_in;
  logic [5:0] addr_in;
  logic [31:0] din_in;
  logic [31:0] dout_out;

  
  initial clk = 0;
  always #5 clk = ~clk;

  
  spram_top dut (
    .clk(clk),
    .rst(rst),
    .ena_in(ena_in),
    .we_in(we_in),
    .addr_in(addr_in),
    .din_in(din_in),
    .dout_out(dout_out)
  );

  initial begin
    
    rst      = 1;
    ena_in   = 0;
    we_in    = 0;
    addr_in  = 6'd0;
    din_in   = 32'd0;

    
    #20;
    rst = 0;

   
    #10;
    addr_in = 6'd10;
    din_in  = 32'hBCD1234;
    ena_in  = 1;
    we_in   = 1;
    #10;

   
    we_in  = 0;
    din_in = 0;
    #20;

    
    addr_in = 6'd10;
    ena_in  = 1;
    #30;

    $display("Read value from address 10 = %h", dout_out);

    #10;
    $finish;
  end

endmodule

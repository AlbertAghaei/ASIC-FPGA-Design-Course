module tb_sdpram;

  logic clk, rst;
  logic ena_in, enb_in, wea_in;
  logic [5:0] addra_in, addrb_in;
  logic [31:0] dina_in;
  logic [31:0] doutb;

  initial clk = 0;
  always #5 clk = ~clk;

  sdpram_top dut (
    .clk(clk),
    .rst(rst),
    .ena_in(ena_in),
    .enb_in(enb_in),
    .wea_in(wea_in),
    .addra_in(addra_in),
    .addrb_in(addrb_in),
    .dina_in(dina_in),
    .doutb(doutb)
  );

  initial begin
    rst = 1;
    ena_in = 0;
    enb_in = 0;
    wea_in = 0;
    addra_in = 0;
    addrb_in = 0;
    dina_in = 0;

    #20;
    rst = 0;

    @(posedge clk);
    ena_in = 1;
    wea_in = 1;
    addra_in = 6'd12;
    dina_in = 32'hABCD1234;

    @(posedge clk);
    wea_in = 0; 
    ena_in = 0;
    dina_in = 0;

    #20;

    @(posedge clk);
    enb_in = 1;
    addrb_in = 6'd12;

    #20;

    $display("Read value from address 12 = %h", doutb);

    $finish;
  end

endmodule

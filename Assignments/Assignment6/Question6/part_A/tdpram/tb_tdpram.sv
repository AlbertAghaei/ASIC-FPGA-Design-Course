module tb_tdpram;

  logic clk, rst;
  logic ena_in, enb_in, wea_in, web_in;
  logic [5:0] addra_in, addrb_in;
  logic [31:0] dina_in, dinb_in;
  logic [31:0] douta_out, doutb_out;

 
  initial clk = 0;
  always #5 clk = ~clk;  

 
  tdpram_top dut (
    .clk(clk),
    .rst(rst),
    .ena_in(ena_in),
    .enb_in(enb_in),
    .wea_in(wea_in),
    .web_in(web_in),
    .addra_in(addra_in),
    .addrb_in(addrb_in),
    .dina_in(dina_in),
    .dinb_in(dinb_in),
    .douta_out(douta_out),
    .doutb_out(doutb_out)
  );

  
  initial begin
    
    rst = 1;
    ena_in = 0; enb_in = 0;
    wea_in = 0; web_in = 0;
    dina_in = 0; dinb_in = 0;
    addra_in = 0; addrb_in = 0;

    #20;
    rst = 0;

    
    ena_in = 1;
    wea_in = 1;
    addra_in = 6'd20;
    dina_in = 32'hABCD1234;
    #10;

    wea_in = 0;
    dina_in = 0;
    #20;

    
    enb_in = 1;
    addrb_in = 6'd20;
    #30;

    $display("Read from port B at address 20: %h", doutb_out);

    $finish;
  end

endmodule

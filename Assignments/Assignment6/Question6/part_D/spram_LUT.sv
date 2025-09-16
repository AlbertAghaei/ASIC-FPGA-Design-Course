module spram_LUT (
  input  logic        clk,
  input  logic        rst,
  input  logic        we,
  input  logic [5:0]  addr,
  input  logic [31:0] din,
  output logic [31:0] dout
);

  xpm_memory_spram #(
    .ADDR_WIDTH_A(6),  //ceil(log2(48)) = 6
    .MEMORY_SIZE(1536), //MEMORY_SIZE = 32 × 48 = 1536
    .BYTE_WRITE_WIDTH_A(32),
    .READ_LATENCY_A(0),
    .WRITE_DATA_WIDTH_A(32),
    .READ_DATA_WIDTH_A(32),
    .MEMORY_PRIMITIVE("distributed"), // => LUTRAM
    .ECC_MODE("no_ecc")
  ) mem_inst (
    .clka(clk),
    .rsta(rst),
    .ena(1'b1),
    .wea(we ? 4'b1111 : 4'b0000),
    .addra(addr),
    .dina(din),
    .douta(dout),
    .regcea(1'b1),
    .sleep(1'b0),
    .injectsbiterra(1'b0),
    .injectdbiterra(1'b0),
    .sbiterra(), .dbiterra()
  );

endmodule 

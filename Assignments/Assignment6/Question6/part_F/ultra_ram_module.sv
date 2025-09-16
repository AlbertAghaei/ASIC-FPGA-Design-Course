module ultra_ram_module (
  input  logic         clk,
  input  logic         rst,
  input  logic         ena,
  input  logic         enb,
  input  logic         we,
  input  logic [12:0]  addra,    // log2(8000) ≈ 13 bits
  input  logic [12:0]  addrb,
  input  logic [199:0] dina,
  output logic [199:0] doutb
);

  xpm_memory_sdpram #(
    .ADDR_WIDTH_A(13),
    .ADDR_WIDTH_B(13),
    .MEMORY_SIZE(8000 * 200),          
    .BYTE_WRITE_WIDTH_A(200),
    .WRITE_DATA_WIDTH_A(200),
    .READ_DATA_WIDTH_B(200),
    .READ_LATENCY_B(2),
    .MEMORY_PRIMITIVE("ultra"),        //  UltraRAM
    .CLOCKING_MODE("common_clock"),
    .ECC_MODE("no_ecc"),
    .MEMORY_INIT_FILE("none"),
    .MEMORY_INIT_PARAM("0"),
    .USE_MEM_INIT(1),
    .WAKEUP_TIME("disable_sleep"),
    .WRITE_MODE_B("read_first")
  ) xpm_uram_inst (
    .clka(clk),
    .ena(ena),
    .wea(we ? 25'h1FFFFFF : 25'h0000000),  
    .addra(addra),
    .dina(dina),

    .clkb(clk),
    .enb(enb),
    .addrb(addrb),
    .doutb(doutb),

    .injectsbiterra(1'b0),
    .injectdbiterra(1'b0),
    .regceb(1'b1),
    .rstb(rst),
    .sleep(1'b0),
    .sbiterrb(),
    .dbiterrb()
  );

endmodule 
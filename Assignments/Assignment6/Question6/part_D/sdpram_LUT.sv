module sdpram_LUT (
  input  logic        clk,
  input  logic        rst,
  input  logic        ena,
  input  logic        enb,
  input  logic        we,
  input  logic [5:0]  addra,
  input  logic [5:0]  addrb,
  input  logic [31:0] dina,
  output logic [31:0] doutb
);

  xpm_memory_sdpram #(
    .ADDR_WIDTH_A(6),
    .ADDR_WIDTH_B(6),
    .BYTE_WRITE_WIDTH_A(32),
    .WRITE_DATA_WIDTH_A(32),
    .READ_DATA_WIDTH_B(32),
    .MEMORY_SIZE(32 * 48),             
    .READ_LATENCY_B(0),                // Read latency
    .CLOCKING_MODE("common_clock"),
    .MEMORY_PRIMITIVE("auto"),
    .ECC_MODE("no_ecc"),
    .MEMORY_INIT_FILE("none"),
    .MEMORY_INIT_PARAM("0"),
    .USE_MEM_INIT(1),
    .WAKEUP_TIME("disable_sleep"),
    .WRITE_MODE_B("read_first")
  ) xpm_sdpram_inst (
    .clka(clk),
    .ena(ena),
    .wea(we ? 4'b1111 : 4'b0000),
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
module sdpram_bram (
  input  logic         clk,
  input  logic         rst,
  input  logic         ena_in,
  input  logic         enb_in,
  input  logic         we_in,
  input  logic [9:0]   addra_in,   // log2(700) ? 10 bits
  input  logic [9:0]   addrb_in,
  input  logic [89:0]  dina_in,
  output logic [89:0]  doutb_out
);

  // Registering inputs
  logic        ena, enb, we;
  logic [9:0]  addra, addrb;
  logic [89:0] dina;

  always_ff @(posedge clk) begin
    if (rst) begin
      ena   <= 1'b0;
      enb   <= 1'b0;
      we    <= 1'b0;
      addra <= '0;
      addrb <= '0;
      dina  <= '0;
    end else begin
      ena   <= ena_in;
      enb   <= enb_in;
      we    <= we_in;
      addra <= addra_in;
      addrb <= addrb_in;
      dina  <= dina_in;
    end
  end

  // Output register
  logic [89:0] doutb_internal;

  always_ff @(posedge clk) begin
    if (rst)
      doutb_out <= '0;
    else
      doutb_out <= doutb_internal;
  end

  // XPM Simple Dual Port RAM instantiation
  xpm_memory_sdpram #(
    .ADDR_WIDTH_A(10),
    .ADDR_WIDTH_B(10),
    .MEMORY_SIZE(90 * 700),              // = width * depth
    .BYTE_WRITE_WIDTH_A(90),
    .WRITE_DATA_WIDTH_A(90),
    .READ_DATA_WIDTH_B(90),
    .READ_LATENCY_B(3),                  // adjustable later (1 clock for now)
    .MEMORY_PRIMITIVE("block"),          // Force BRAM
    .CLOCKING_MODE("common_clock"),
    .ECC_MODE("no_ecc"),
    .MEMORY_INIT_FILE("none"),
    .MEMORY_INIT_PARAM("0"),
    .USE_MEM_INIT(1),
    .WAKEUP_TIME("disable_sleep"),
    .WRITE_MODE_B("read_first")
  ) xpm_bram_inst (
    .clka(clk),
    .ena(ena),
    .wea(we ? 10'b1111111111 : 10'b0),   // Assuming full 90-bit write (rounded to 10 bytes)
    .addra(addra),
    .dina(dina),

    .clkb(clk),
    .enb(enb),
    .addrb(addrb),
    .doutb(doutb_internal),

    .injectsbiterra(1'b0),
    .injectdbiterra(1'b0),
    .regceb(1'b1),
    .rstb(rst),
    .sleep(1'b0),
    .sbiterrb(),
    .dbiterrb()
  );

endmodule

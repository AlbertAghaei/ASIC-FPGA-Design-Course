module sdpram_top (
    input  logic        clk,
    input  logic        rst,
    input  logic        ena_in,
    input  logic        enb_in,
    input  logic        wea_in,
    input  logic [5:0]  addra_in,
    input  logic [5:0]  addrb_in,
    input  logic [31:0] dina_in,
    output logic [31:0] doutb
);

  logic        ena, enb, wea;
  logic [5:0]  addra, addrb;
  logic [31:0] dina;

  always_ff @(posedge clk) begin
    if (rst) begin
      ena    <= 0;
      enb    <= 0;
      wea    <= 0;
      addra  <= 0;
      addrb  <= 0;
      dina   <= 0;
    end else begin
      ena    <= ena_in;
      enb    <= enb_in;
      wea    <= wea_in;
      addra  <= addra_in;
      addrb  <= addrb_in;
      dina   <= dina_in;
    end
  end

  logic [31:0] dout_internal;

  always_ff @(posedge clk) begin
    if (rst)
      doutb <= 32'd0;
    else
      doutb <= dout_internal;
  end

  xpm_memory_sdpram #(
    .ADDR_WIDTH_A(6),
    .ADDR_WIDTH_B(6),
    .AUTO_SLEEP_TIME(0),
    .BYTE_WRITE_WIDTH_A(32),
    .CASCADE_HEIGHT(0),
    .CLOCKING_MODE("common_clock"),
    .ECC_MODE("no_ecc"),
    .MEMORY_INIT_FILE("none"),
    .MEMORY_INIT_PARAM("0"),
    .MEMORY_OPTIMIZATION("true"),
    .MEMORY_PRIMITIVE("auto"),
    .MEMORY_SIZE(2048),
    .MESSAGE_CONTROL(0),
    .READ_DATA_WIDTH_B(32),
    .READ_LATENCY_B(2),
    .READ_RESET_VALUE_B("0"),
    .RST_MODE_A("SYNC"),
    .RST_MODE_B("SYNC"),
    .SIM_ASSERT_CHK(0),
    .USE_EMBEDDED_CONSTRAINT(0),
    .USE_MEM_INIT(1),
    .WAKEUP_TIME("disable_sleep"),
    .WRITE_DATA_WIDTH_A(32),
    .WRITE_MODE_B("no_change")
  ) ram_inst (
    .addra(addra),
    .addrb(addrb),
    .clka(clk),
    .clkb(clk),
    .dina(dina),
    .doutb(dout_internal),
    .ena(ena),
    .enb(enb),
    .injectdbiterra(1'b0),
    .injectsbiterra(1'b0),
    .regceb(1'b1),
    .rstb(rst),
    .sleep(1'b0),
    .wea(wea ? 4'b1111 : 4'b0000),
    .dbiterrb(),
    .sbiterrb()
  );

endmodule

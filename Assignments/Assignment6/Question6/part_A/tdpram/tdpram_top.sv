module tdpram_top (
    input  logic        clk,
    input  logic        rst,

    input  logic        ena_in,
    input  logic        enb_in,
    input  logic        wea_in,
    input  logic        web_in,
    input  logic [5:0]  addra_in,
    input  logic [5:0]  addrb_in,
    input  logic [31:0] dina_in,
    input  logic [31:0] dinb_in,

    output logic [31:0] douta_out,
    output logic [31:0] doutb_out
);

  logic        ena, enb, wea, web;
  logic [5:0]  addra, addrb;
  logic [31:0] dina, dinb;

  always_ff @(posedge clk) begin
    if (rst) begin
      ena    <= 0;
      enb    <= 0;
      wea    <= 0;
      web    <= 0;
      addra  <= 0;
      addrb  <= 0;
      dina   <= 0;
      dinb   <= 0;
    end else begin
      ena    <= ena_in;
      enb    <= enb_in;
      wea    <= wea_in;
      web    <= web_in;
      addra  <= addra_in;
      addrb  <= addrb_in;
      dina   <= dina_in;
      dinb   <= dinb_in;
    end
  end

  logic [31:0] douta_int, doutb_int;

  always_ff @(posedge clk) begin
    if (rst) begin
      douta_out <= 0;
      doutb_out <= 0;
    end else begin
      douta_out <= douta_int;
      doutb_out <= doutb_int;
    end
  end

  xpm_memory_tdpram #(
    .ADDR_WIDTH_A(6),
    .ADDR_WIDTH_B(6),
    .AUTO_SLEEP_TIME(0),
    .BYTE_WRITE_WIDTH_A(32),
    .BYTE_WRITE_WIDTH_B(32),
    .CASCADE_HEIGHT(0),
    .CLOCKING_MODE("common_clock"),
    .ECC_MODE("no_ecc"),
    .MEMORY_INIT_FILE("none"),
    .MEMORY_INIT_PARAM("0"),
    .MEMORY_OPTIMIZATION("true"),
    .MEMORY_PRIMITIVE("auto"),
    .MEMORY_SIZE(2048),
    .MESSAGE_CONTROL(0),
    .READ_DATA_WIDTH_A(32),
    .READ_DATA_WIDTH_B(32),
    .READ_LATENCY_A(2),
    .READ_LATENCY_B(2),
    .READ_RESET_VALUE_A("0"),
    .READ_RESET_VALUE_B("0"),
    .RST_MODE_A("SYNC"),
    .RST_MODE_B("SYNC"),
    .SIM_ASSERT_CHK(0),
    .USE_EMBEDDED_CONSTRAINT(0),
    .USE_MEM_INIT(1),
    .WAKEUP_TIME("disable_sleep"),
    .WRITE_DATA_WIDTH_A(32),
    .WRITE_DATA_WIDTH_B(32),
    .WRITE_MODE_A("no_change"),
    .WRITE_MODE_B("no_change")
  ) ram_inst (
    .clka(clk),
    .clkb(clk),

    .addra(addra),
    .addrb(addrb),

    .dina(dina),
    .dinb(dinb),

    .ena(ena),
    .enb(enb),

    .wea(wea ? 4'b1111 : 4'b0000),
    .web(web ? 4'b1111 : 4'b0000),

    .douta(douta_int),
    .doutb(doutb_int),

    .rsta(rst),
    .rstb(rst),
    .regcea(1'b1),
    .regceb(1'b1),

    .sleep(1'b0),

    .injectdbiterra(1'b0),
    .injectdbiterrb(1'b0),
    .injectsbiterra(1'b0),
    .injectsbiterrb(1'b0),

    .sbiterra(),
    .sbiterrb(),
    .dbiterra(),
    .dbiterrb()
  );

endmodule

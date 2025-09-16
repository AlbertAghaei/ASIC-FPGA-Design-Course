module spram_top (
    input  logic        clk,
    input  logic        rst,
    input  logic        ena_in,
    input  logic        we_in,
    input  logic [5:0]  addr_in,
    input  logic [31:0] din_in,
    output logic [31:0] dout_out
);

  logic  ena, we;
  logic [5:0]  addr;
  logic [31:0] din;

  always_ff @(posedge clk) begin
    if (rst) begin
      ena  <= 1'b0;
      we   <= 1'b0;
      addr <= 6'd0;
      din  <= 32'd0;
    end else begin
      ena  <= ena_in;
      we   <= we_in;
      addr <= addr_in;
      din  <= din_in;
    end
  end

  logic [31:0] dout_internal;

  always_ff @(posedge clk) begin
    if (rst)
      dout_out <= 32'd0;
    else
      dout_out <= dout_internal;
  end

  xpm_memory_spram #(
    .ADDR_WIDTH_A(6),
    .AUTO_SLEEP_TIME(0),
    .BYTE_WRITE_WIDTH_A(32),
    .CASCADE_HEIGHT(0),
    .ECC_MODE("no_ecc"),
    .MEMORY_INIT_FILE("none"),
    .MEMORY_INIT_PARAM("0"),
    .MEMORY_OPTIMIZATION("true"),
    .MEMORY_PRIMITIVE("auto"),
    .MEMORY_SIZE(2048),
    .MESSAGE_CONTROL(0),
    .READ_DATA_WIDTH_A(32),
    .READ_LATENCY_A(2),
    .READ_RESET_VALUE_A("0"),
    .RST_MODE_A("SYNC"),
    .SIM_ASSERT_CHK(0),
    .USE_MEM_INIT(1),
    .WAKEUP_TIME("disable_sleep"),
    .WRITE_DATA_WIDTH_A(32),
    .WRITE_MODE_A("read_first")
  ) ram_inst (
    .clka(clk),
    .rsta(rst),
    .regcea(1'b1),
    .sleep(1'b0),
    .injectsbiterra(1'b0),
    .injectdbiterra(1'b0),

    .ena(ena),
    .wea(we ? 4'b1111 : 4'b0000),
    .addra(addr),
    .dina(din),
    .douta(dout_internal),

    .sbiterra(),
    .dbiterra()
  );

endmodule



//   xpm_memory_spram #(
//      .ADDR_WIDTH_A(6),              // DECIMAL
//      .AUTO_SLEEP_TIME(0),           // DECIMAL
//      .BYTE_WRITE_WIDTH_A(32),       // DECIMAL
//      .CASCADE_HEIGHT(0),            // DECIMAL
//      .ECC_MODE("no_ecc"),           // String
//      .MEMORY_INIT_FILE("none"),     // String
//      .MEMORY_INIT_PARAM("0"),       // String
//      .MEMORY_OPTIMIZATION("true"),  // String
//      .MEMORY_PRIMITIVE("auto"),     // String
//      .MEMORY_SIZE(2048),            // DECIMAL
//      .MESSAGE_CONTROL(0),           // DECIMAL
//      .READ_DATA_WIDTH_A(32),        // DECIMAL
//      .READ_LATENCY_A(2),            // DECIMAL
//      .READ_RESET_VALUE_A("0"),      // String
//      .RST_MODE_A("SYNC"),           // String
//      .SIM_ASSERT_CHK(0),            // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//      .USE_MEM_INIT(1),              // DECIMAL
//      .WAKEUP_TIME("disable_sleep"), // String
//      .WRITE_DATA_WIDTH_A(32),       // DECIMAL
//      .WRITE_MODE_A("read_first")    // String
//   )
//   xpm_memory_spram_inst (
//      .dbiterra(dbiterra),             // 1-bit output: Status signal to indicate double bit error occurrence
//                                       // on the data output of port A.

//      .douta(douta),                   // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
//      .sbiterra(sbiterra),             // 1-bit output: Status signal to indicate single bit error occurrence
//                                       // on the data output of port A.

//      .addra(addra),                   // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
//      .clka(clka),                     // 1-bit input: Clock signal for port A.
//      .dina(dina),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
//      .ena(ena),                       // 1-bit input: Memory enable signal for port A. Must be high on clock
//                                       // cycles when read or write operations are initiated. Pipelined
//                                       // internally.

//      .injectdbiterra(injectdbiterra), // 1-bit input: Controls double bit error injection on input data when
//                                       // ECC enabled (Error injection capability is not available in
//                                       // "decode_only" mode).

//      .injectsbiterra(injectsbiterra), // 1-bit input: Controls single bit error injection on input data when
//                                       // ECC enabled (Error injection capability is not available in
//                                       // "decode_only" mode).

//      .regcea(regcea),                 // 1-bit input: Clock Enable for the last register stage on the output
//                                       // data path.

//      .rsta(rsta),                     // 1-bit input: Reset signal for the final port A output register stage.
//                                       // Synchronously resets output port douta to the value specified by
//                                       // parameter READ_RESET_VALUE_A.

//      .sleep(sleep),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
//      .wea(wea)                        // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
//                                       // data port dina. 1 bit wide when word-wide writes are used. In
//                                       // byte-wide write configurations, each bit controls the writing one
//                                       // byte of dina to address addra. For example, to synchronously write
//                                       // only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
//                                       // 4'b0010.

//   );

  

module memory_tb;

  localparam ADDR_WIDTH = 6;
  localparam DATA_WIDTH = 32;
  localparam READ_LATENCY = 2;

  logic clk, rst;
  logic wr_en, rd_en;
  logic [ADDR_WIDTH-1:0] wr_addr, rd_addr;
  logic [DATA_WIDTH-1:0] wr_data;
  logic [DATA_WIDTH-1:0] rd_data_model, rd_data_dut;
  logic [DATA_WIDTH-1:0] wr_data_mem [0:(1<<ADDR_WIDTH)-1];
  int written_indices[20];

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst = 1;
    wr_en = 0;
    rd_en = 0;
    wr_addr = 0;
    rd_addr = 0;
    wr_data = 0;
    #20 rst = 0;

    // WRITE PHASE
    for (int i = 0; i < 20; i++) begin
      @(posedge clk);
      wr_en = 1;
      wr_addr = $urandom_range(0, 63);
      wr_data = $urandom;
      wr_data_mem[wr_addr] = wr_data;
      written_indices[i] = wr_addr;
      $display("WRITE @ %0t | addr = %0d | data = %h", $time, wr_addr, wr_data);
    end
    wr_en = 0;

    repeat(READ_LATENCY + 2) @(posedge clk);

    // READ PHASE
    for (int i = 0; i < 20; i++) begin
      @(posedge clk);
      rd_en = 1;
      rd_addr = written_indices[i];
      $display("READ  @ %0t | addr = %0d", $time, rd_addr);
    end
    rd_en = 0;

    #100;
    $finish;
  end

  // Custom memory model instantiation
  memory_model #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .READ_LATENCY(READ_LATENCY)
  ) model (
    .clk(clk), .rst(rst),
    .wr_en(wr_en), .rd_en(rd_en),
    .wr_addr(wr_addr), .rd_addr(rd_addr),
    .wr_data(wr_data),
    .rd_data(rd_data_model)
  );

  // XPM memory instantiation
  xpm_memory_sdpram #(
    .ADDR_WIDTH_A(ADDR_WIDTH),
    .ADDR_WIDTH_B(ADDR_WIDTH),
    .WRITE_DATA_WIDTH_A(DATA_WIDTH),
    .READ_DATA_WIDTH_B(DATA_WIDTH),
    .READ_LATENCY_B(READ_LATENCY - 1),
    .MEMORY_SIZE(DATA_WIDTH*(1<<ADDR_WIDTH)),
    .ECC_MODE("no_ecc"),
    .CLOCKING_MODE("common_clock"),
    .WRITE_MODE_B("no_change")
  ) xpm_mem (
    .clka(clk), .clkb(clk),
    .ena(1'b1), .enb(1'b1),
    .addra(wr_addr), .addrb(rd_addr),
    .dina(wr_data), .wea(wr_en ? 4'b1111 : 4'b0000),
    .rstb(rst), .regceb(1'b1),
    .sleep(1'b0),
    .injectsbiterra(1'b0), .injectdbiterra(1'b0),
    .doutb(rd_data_dut),
    .sbiterrb(), .dbiterrb()
  );

  // Check
  always_ff @(posedge clk) begin
    if (!rst && rd_en) begin
      if (rd_data_model === rd_data_dut)
        $display("MATCH    @ %0t | addr = %0d | data = %h", $time, rd_addr, rd_data_dut);
      else
        $display("MISMATCH @ %0t | addr = %0d | model = %h | XPM = %h", $time, rd_addr, rd_data_model, rd_data_dut);
    end
  end

endmodule

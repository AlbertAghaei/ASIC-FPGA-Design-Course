module my_behavioral_memory #(
  parameter DATA_WIDTH = 72,
  parameter ADDR_WIDTH = 9,          // log2(512) = 9
  parameter READ_LATENCY = 1
)(
  input  logic                  clk,
  input  logic                  rst,

  // Write port
  input  logic                  wr_en,
  input  logic [ADDR_WIDTH-1:0] wr_addr,
  input  logic [DATA_WIDTH-1:0] wr_data,

  // Read port
  input  logic                  rd_en,
  input  logic [ADDR_WIDTH-1:0] rd_addr,
  output logic [DATA_WIDTH-1:0] rd_data
);

  localparam DEPTH = 1 << ADDR_WIDTH;

  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  logic [DATA_WIDTH-1:0] pipeline [0:READ_LATENCY-1];

  // Write logic
  always_ff @(posedge clk) begin
    if (wr_en)
      mem[wr_addr] <= wr_data;
  end

  // Read pipeline logic (1-cycle delay)
  always_ff @(posedge clk) begin
    if (rst) begin
      foreach (pipeline[i]) pipeline[i] <= '0;
    end else begin
      pipeline[0] <= rd_en ? mem[rd_addr] : '0;
      for (int i = 1; i < READ_LATENCY; i++)
        pipeline[i] <= pipeline[i-1];
    end
  end

  assign rd_data = pipeline[READ_LATENCY-1];

endmodule



module memory_model #(
  parameter ADDR_WIDTH = 6,
  parameter DATA_WIDTH = 32,
  parameter READ_LATENCY = 2
)(
  input  logic                    clk,
  input  logic                    rst,
  input  logic                    wr_en,
  input  logic                    rd_en,
  input  logic [ADDR_WIDTH-1:0]   wr_addr,
  input  logic [ADDR_WIDTH-1:0]   rd_addr,
  input  logic [DATA_WIDTH-1:0]   wr_data,
  output logic [DATA_WIDTH-1:0]   rd_data
);

  localparam DEPTH = 1 << ADDR_WIDTH;
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  logic [DATA_WIDTH-1:0] rd_pipeline [0:READ_LATENCY-1];

  always_ff @(posedge clk) begin
    if (wr_en)
      mem[wr_addr] <= wr_data;

    if (rst) begin
      foreach (rd_pipeline[i]) rd_pipeline[i] <= '0;
    end else begin
      rd_pipeline[0] <= rd_en ? mem[rd_addr] : '0;
      for (int i = 1; i < READ_LATENCY; i++)
        rd_pipeline[i] <= rd_pipeline[i-1];
    end
  end

  assign rd_data = rd_pipeline[READ_LATENCY-1];

endmodule

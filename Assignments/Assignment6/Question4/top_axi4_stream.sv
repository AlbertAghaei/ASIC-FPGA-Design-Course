module top_axi4_stream(
  input  wire logic clk,
  input  wire logic rst,
  output var  logic [31:0] result
);

  typedef struct packed {
    logic [31:0] payload;
  } tdata_t;

  axi_stream_if #(.TDATA_TYPE(tdata_t)) stream_tx (.clk(clk), .rst(rst));
  axi_stream_if #(.TDATA_TYPE(tdata_t)) stream_rx (.clk(clk), .rst(rst));
  
  cnt_tx #(
    .CNT_MAX(64), .CNT_START(0), .CNT_STEP(1)
  ) tx_inst (
    .stream(stream_tx.master)
  );

  acc_rx rx_inst (
    .stream(stream_rx.slave),
    .ACC_OUT(result)
  );
  
axis_data_fifo_0 my_fifo (
  .s_axis_aresetn(rst),  // input wire s_axis_aresetn
  .s_axis_aclk(clk),        // input wire s_axis_aclk
  .s_axis_tvalid(stream_tx.tvalid),    // input wire s_axis_tvalid
  .s_axis_tready(stream_tx.tready),    // output wire s_axis_tready
  .s_axis_tdata(stream_tx.tdata.payload),      // input wire [255 : 0] s_axis_tdata
  .s_axis_tlast(stream_tx.tlast),      // input wire s_axis_tlast
  .m_axis_tvalid(stream_rx.tvalid),    // output wire m_axis_tvalid
  .m_axis_tready(stream_rx.tready),    // input wire m_axis_tready
  .m_axis_tdata(stream_rx.tdata.payload),      // output wire [255 : 0] m_axis_tdata
  .m_axis_tlast(stream_rx.tlast)      // output wire m_axis_tlast
);


endmodule


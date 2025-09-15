module cnt_tx #(
   parameter int CNT_MAX = 64,
   parameter int CNT_START = 0,
   parameter int CNT_STEP = 1
   )(
   axi_stream_if.master stream
    );
    
    logic [31:0] cnt;
    logic      done;
    
    always_ff @(posedge stream.clk or negedge stream.rst) begin
    if(stream.rst == 0) begin
      cnt               <= CNT_START;
      stream.tvalid     <= 0;
      stream.tlast      <= 0;
      stream.tdata      <= '{default: 0};
      done              <= 0;
    end else begin
       if (stream.tready && !done) begin
        stream.tdata.payload <= cnt;
        stream.tvalid        <= 1;
    
        if (cnt >= CNT_MAX - CNT_STEP) begin
          stream.tlast <= 1;
          done         <= 1;
        end else begin
          stream.tlast <= 0;
        end

        cnt <= cnt + CNT_STEP;
      end else if (done) begin
        stream.tvalid <= 0;
        stream.tlast  <= 0;
        cnt           <= CNT_START;
        done          <= 0;
      end
    end
  end
endmodule

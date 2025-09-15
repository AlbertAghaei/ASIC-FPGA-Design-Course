module acc_rx(
  axi_stream_if.slave stream,
  output var logic [31:0] ACC_OUT
    );
    
  logic [31:0] acc;
  logic phase;
  logic ready_flag;
  
  
  always_ff @(posedge stream.clk or negedge stream.rst) begin
     if(stream.rst == 0)
        phase <= 0;
     else
        phase <= ~phase;
     end
          

always_ff @(posedge stream.clk or negedge stream.rst) begin
    if (stream.rst == 0) begin
      acc      <= 0;
      ACC_OUT  <= 0;
    end else if (stream.tready) begin
      acc <= acc + stream.tdata.payload;
      if (stream.tlast) begin
        ACC_OUT <= acc + stream.tdata.payload;
        acc <= 0;
      end
    end
  end
  
  
  always_comb begin
    ready_flag = (phase == 0) && stream.tvalid;  
  end

  assign stream.tready = ready_flag;
  


endmodule

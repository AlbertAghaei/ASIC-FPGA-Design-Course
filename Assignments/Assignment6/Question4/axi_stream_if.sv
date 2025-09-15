interface axi_stream_if #(
   parameter type TDATA_TYPE = tdata_t
    )(
    input wire logic clk,rst
    );
    
    TDATA_TYPE tdata;
    var logic tvalid;
    var logic tready;
    var logic tlast;
    
    
    modport master (
    output tdata,tvalid,tlast,
    input  tready,
    input  clk,rst
    );
    
    
    modport slave (
    input tdata,tvalid,tlast,
    output  tready,
    input  clk,rst
    );
    
   
endinterface

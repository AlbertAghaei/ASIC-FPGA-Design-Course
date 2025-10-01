`timescale 1ns / 1ps

module ram_read_write(
input              clk,
    input              rst_n,
   
    input      [31:0]  din,    
    output reg [31:0]  dout,
    output reg         en,
    output reg [3:0]   we,
    output             rst,
    output reg [31:0]  addr,
    input              start,
    output reg         write_end,
    input      [3:0]  freq_mult,
    input      [31:0]  len,
    input      [31:0]  start_addr,
    input      [31:0]  dest_addr
    );
   
    assign rst = 1'b0 ;
       
    localparam IDLE        = 3'd0 ;
    localparam DECOY       = 3'd1 ;
    localparam READ_RAM    = 3'd2 ;
    localparam WRITE_RAM   = 3'd3 ;
    localparam ADDR_FETCH  = 3'd4 ;
    localparam DONE        = 3'd5 ;
   
    reg [2:0] state ;
    reg [31:0] counter ;
    reg [31:0] start_addr_reg ;
    reg [31:0] dest_addr_reg ;
    reg [31:0] read_data ;
    reg [3:0] write_repeat; // counts up to 7 for freq_mult=8
   // reg [31:0] repeat_pass;
   
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state      <= IDLE  ;
            dout       <= 32'd0 ;
            en         <= 1'b0  ;
            we         <= 4'd0  ;
            addr       <= 32'd0 ;
            write_end  <= 1'b0  ;
            counter    <= 32'd0 ;
            //counter2   <= 32'd0 ;
            start_addr_reg <= 32'd0;
            read_data <= 32'd0;
            write_repeat <= 4'd0;
            //repeat_pass <= 32'd0;
           
        end else begin
            case(state)
                IDLE: begin
                    if (start) begin
                        counter <= 32'd0;
                        //counter2 <= 32'd0;
                        write_repeat <= 4'd0;
                        start_addr_reg <= start_addr;
                        dest_addr_reg  <= dest_addr;
                        addr <= start_addr;
                        en   <= 1'b1 ;
                       
                        state <= DECOY;
                    end              
                    write_end <= 1'b0 ;
                end
                DECOY: begin
                   
                    state <= READ_RAM;
                end
                READ_RAM: begin
                 
           
                        read_data <= din;
                        state <= WRITE_RAM;
                   
                   
                   end
                WRITE_RAM: begin
                   write_repeat <= 3'd0;
                    we <= 4'hf;
                    dout <= read_data;
                    addr <= dest_addr_reg + counter + 4;
                    //counter2 <= counter + 4;
                     state <= ADDR_FETCH;


                end
                ADDR_FETCH: begin
                    we <= 4'd0;
                   
                    addr <= start_addr_reg + (counter + 4)*freq_mult;
                    counter <= counter + 4; // Increment by 4 bytes (32 bits)
                  
                    if (counter >= (((len/freq_mult)-1) << 2)) begin
                        state <= DONE;
                    end else begin
                        // Move to next read address
                        state <= DECOY;
                    end
                end
                DONE: begin
                    addr <= 32'd0 ;
                    write_end <= 1'b1 ;
                    state <= IDLE ;        
                end
                default: state <= IDLE ;
            endcase
        end
    end    
endmodule



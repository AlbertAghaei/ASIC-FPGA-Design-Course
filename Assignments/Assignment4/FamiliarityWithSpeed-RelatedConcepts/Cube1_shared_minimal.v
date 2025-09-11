
module Cube1_shared_minimal (
    input wire clk,
    input wire rst,
    input wire [7:0] in,
    output reg [23:0] out
);

    reg [1:0] state;
    reg [1:0] counter;
    reg [23:0] temp;
    reg [7:0] in_reg;
    reg [23:0] temp_out;
    

    parameter  IDLE = 2'b00,
               MULT = 2'b01,
               DONE = 2'b10;
   
    always@(*) begin
    temp_out <= in_reg * temp;
    end

    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            temp <= 24'd1;
            out <= 0;
            in_reg <= 0;
            counter <= 0;
           
        end
        else begin
        case (state)

             IDLE: begin
                        in_reg <= in;
                        temp <= 24'd1;
                        counter <= 0;
                        state <= MULT;
                        
                    
             end
       
            MULT: begin
                    temp <= temp_out;
                    counter <= counter + 1;
                    if ( counter == 2'b10 )

                         state <= DONE;
                        
                   
                    else state <= MULT;
             end



            DONE:
                   begin
                    out <= temp;
                    state <= IDLE; 
                   end
                    
                    
           
        endcase
        end
    end
endmodule

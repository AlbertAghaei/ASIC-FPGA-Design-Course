module fir_filter_resourcesharing (
    input wire clk,
    input wire rst,
    input wire [7:0] x_in,
    input wire [7:0] coef_val,
    input wire writeen,
    input wire tlast,
    output reg [18:0] y_out
);

    reg [7:0] coeffs[0:6];
    reg [7:0] in_reg [0:6];
    reg [2:0] coeff_index;
    reg coeff_done;

    reg [2:0] state;
    reg [18:0] add;
    reg  [18:0] mac;
    reg [15:0] multreg;
    reg  [7:0] multdata;
    reg  [7:0] multcoeff;
    
   always @(posedge clk)
         mac <= add + multreg;
         
            
    integer i;


    parameter IDLE = 3'd0,
              MAC  = 3'd1,
              DONE = 3'd2;
    
    always @(*)
    begin
    multreg = (state == IDLE) ? (16'b0):(multcoeff * multdata);
    add = (state == IDLE) ? (16'b0):(mac);
    
    end
     
    
     


    always @(posedge clk) begin
        if (rst) begin
            coeff_index <= 0;
            coeff_done <= 0;
            y_out <= 0;
           
            state <= IDLE;
            for (i = 0; i < 7; i = i + 1) begin
                coeffs[i] <= 0;
                in_reg[i] <= 0;
            end
        end


        else if (writeen && !coeff_done) begin
            coeffs[coeff_index] <= coef_val;
            coeff_index <= coeff_index + 1;
            if (tlast)
                coeff_done <= 1;
        end

        else if (coeff_done) begin
            case (state)
                IDLE: begin

                    for (i = 6; i > 0; i = i - 1)
                        in_reg[i] <= in_reg[i-1];
                        in_reg[0] <= x_in;
                      state <= MAC;
                    coeff_index <= 0;
                    
                    
                end

                MAC: begin
                    multdata <= in_reg[coeff_index];
                    multcoeff <= coeffs[coeff_index];
                    coeff_index <= coeff_index + 1;

                    if (coeff_index == 6)
                        state <= DONE;
                end

                DONE: begin
                y_out <= mac;
                   
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule

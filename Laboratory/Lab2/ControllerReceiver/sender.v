module sender (
    input wire rst,
    input wire clk,                    
    input wire [3:0] button,           
    output reg [0:0] Tx                   
    );

    // BUTTONS //
    localparam SQUARE   = 4'b1000;     // button[3] --> Square
    localparam TRIANGLE = 4'b0100;     // button[2] --> Triangle
    localparam CIRCLE   = 4'b0010;     // button[1] --> Circle
    localparam CROSS    = 4'b0001;     // button[0] --> Cross

    // SYMBOLS //
    localparam SQUARE_SYMBOL   = 4'b0101; 
    localparam TRIANGLE_SYMBOL = 4'b0010; 
    localparam CIRCLE_SYMBOL   = 4'b0110; 
    localparam CROSS_SYMBOL    = 4'b0011; 

    // STATES //
    localparam IDLE       = 0;     
    localparam OUTPUT_SEQ = 1;     

    //  REGS  //
    reg [0:0] state;            
    reg [0:0] button_pressed;   
    reg [3:0] sequence;         
    reg [1:0] seq_index;



    always @(posedge clk, posedge rst) begin
        if(rst) begin
            Tx <= 1;
            state <= IDLE;
            seq_index <= 2'b0;
            button_pressed  <= 1'b0;    
        end

        else begin
            case (state)
                IDLE: begin
                // =============================================== //
                    if(button == 4'b0000) begin
                        button_pressed <= 0;
                        state <= IDLE;
                        Tx <= 1;
                    end

                    else begin
                        if(button_pressed==0) begin
                            button_pressed <= 1;
                            state <= OUTPUT_SEQ;
                            seq_index <= 0;
                            case (button)
                                SQUARE:   sequence <= SQUARE_SYMBOL;
                                TRIANGLE: sequence <= TRIANGLE_SYMBOL;
                                CIRCLE:   sequence <= CIRCLE_SYMBOL;
                                CROSS:    sequence <= CROSS_SYMBOL;
                            endcase
                        end   
                        else begin
                            Tx <= 1;
                        end                   
                    end
                end
                // =============================================== //


                OUTPUT_SEQ: begin
                // =============================================== //
                    if (seq_index < 3) begin
                        Tx <= sequence[3 - seq_index];
                        seq_index <= seq_index + 1;
                    end else begin
                        Tx <= sequence[3 - seq_index];
                        state <= IDLE;
                        seq_index <= 0;
                    end
                end
                // =============================================== //

                default: begin
                    state <= IDLE;
                    Tx <= 1;
                end
            endcase
        end
    end

endmodule



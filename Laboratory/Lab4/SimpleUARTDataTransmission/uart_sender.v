module uart_sender(
    input wire rst,
    input wire clk,                    
    input wire [3:0] deep_switches,   
    input wire KEY,                     
    output reg Tx                      
    );

    parameter idle = 3'b000 , start_bit = 3'b001 , send_data = 3'b010, send_parity= 3'b011 , stop_bit = 3'b100 , wait_data = 3'b101 ;



    parameter BAUD_RATE = 9_600;
    parameter CLK_FREQ = 50_000_000;  
    parameter CLOCK_CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;   /// CLOCK_CYCLES_PER_BIT = 5208

    reg [2:0] state;               
    reg [2:0] next_state;           
    reg [7:0] data_to_send;       
    reg [3:0] seq_index;           
    reg [31:0] bit_counter;        
    reg button_pressed;

     always @(posedge clk) begin
        if (!rst) begin
            state <= idle;
        end else begin
            state <= next_state;
        end
    end



    always @(*) begin
        case(state)
            idle: begin
                if (KEY==1 && button_pressed==0) begin   // key ? active high ?!!!!
                    next_state = start_bit;  
                end else begin
                    next_state = idle;
                end
            end

            start_bit: begin
                next_state = send_data; 
            end

            send_data: begin
                if (seq_index < 6) begin
                    next_state = send_data; 
                end else begin
                    next_state = send_parity; 
                end
            end

            send_parity: begin
                next_state = stop_bit;  
            end

            stop_bit: begin
                next_state = wait_data;  
            end

            wait_data: begin
                next_state = idle;  
            end

            default: begin
                next_state = idle;
            end
        endcase
    end


    always @(posedge clk) begin
        if (!rst) begin
            Tx <= 1;              
            seq_index <= 0;
            bit_counter <= 0;
            button_pressed <= 0;
        end else begin
            case(state)
                idle: begin
                    Tx <= 1;  
                    if (KEY==1 && button_pressed==0) begin
                        button_pressed <= 1;  
                        data_to_send <= {1'b1,3'b000, deep_switches, 1'b0}; 
                        seq_index <= 0;  
                    end
                end

                start_bit: begin
                    Tx <= 0;  
                end

                send_data: begin
                    if (bit_counter < CLOCK_CYCLES_PER_BIT) begin // 5205
                        bit_counter <= bit_counter + 1;
                    end else begin
                        bit_counter <= 0;
                        Tx <= data_to_send[seq_index];  
                          $display("Tx=%0d", Tx);
                        seq_index <= seq_index + 1;
                    end
                end

                send_parity: begin
                    Tx <= 0;  
                end

                stop_bit: begin
                    Tx <= 1;  
                end

                wait_data: begin
                    button_pressed <= 0; 
                end

                default: begin
                    Tx <= 1;
                end
            endcase
        end
    end
endmodule

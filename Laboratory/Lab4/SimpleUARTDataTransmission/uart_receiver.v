module uart_receiver (
    input  wire       clk,     // 50 kHz system clock (LOW for testbench! Change to 50_000_000 for real FPGA)
    input  wire       rst,     // synchronous reset, active high
    input  wire       rx,      // serial input line
    output reg [3:0]  leds     // drives LEDs = D3..D0 of received 7-bit word
);

    // Clock and baud rate settings
    parameter CLK_FREQ        = 50_000_000;         // Change this to 50_000_000 on real board
    parameter BAUD_RATE       = 9_600;
    parameter CLOCKS_PER_BIT = CLK_FREQ / BAUD_RATE;  //CLOCKS_PER_BIT = 5208

    // FSM states
    parameter  IDLE   = 3'd0,
             //  START  = 3'd1,
               DATA   = 3'd2,
               PARITY = 3'd3,
               STOP   = 3'd4;

    reg [2:0]   state, next_state;
    reg [31:0]  clk_count;
    reg [2:0]   bit_index;       // index for 7 data bits
    reg [6:0]   data_shift;      // 7-bit shift register
    reg         parity_sample;   // received parity
    reg         parity_calc;     // XOR of received bits

    // Synchronize RX input
    reg rx_sync0, rx_sync1;
    wire rx_stable;
    wire rx2;
    assign rx_stable =  rx_sync1;
    assign rx2 = !rx;
    always @(posedge clk) begin
        if (!rst) begin
            rx_sync0 <= 0;
            rx_sync1 <= 0;
        end else begin
            rx_sync0 <= rx2;
            rx_sync1 <= rx_sync0;
        end
    end

    // FSM state transition
    always @(posedge clk) begin
        if (!rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    // FSM Debug
    always @(posedge clk) begin
        if (!rst) begin
            $display("RESET asserted at time %0t", $time);
        end else begin
            case (state)
            //    IDLE:   $display("Time %0t: STATE = IDLE", $time);
            //    START:  $display("Time %0t: STATE = START", $time);
                DATA:   $display("Time %0t: STATE = DATA, bit_index=%0d", $time, bit_index);
            //    PARITY: $display("Time %0t: STATE = PARITY", $time);
             //   STOP:   $display("Time %0t: STATE = STOP", $time);
            endcase
        end
    end

    // FSM next state logic
    always @(*) begin
    if (state == IDLE) begin
        if (rx_stable == 0)
            next_state = DATA;
        else
            next_state = IDLE;
  //  end else if (state == START) begin
   //     if (clk_count >= CLOCKS_PER_BIT) // 5208
    //        next_state = DATA;
     //   else
       //     next_state = START;
    end else if (state == DATA) begin
        if (bit_index == 3'd6 && clk_count >= CLOCKS_PER_BIT) // 5208
            next_state = PARITY;
        else
            next_state = DATA;
    end else if (state == PARITY) begin
        if (clk_count >= CLOCKS_PER_BIT)   //5208
            next_state = STOP;
        else
            next_state = PARITY;
    end else if (state == STOP) begin
        if (clk_count >= CLOCKS_PER_BIT) //5208
            next_state = IDLE;
        else
            next_state = STOP;
    end else begin
        next_state = IDLE;
    end
end


    // Datapath
    always @(posedge clk) begin
        if (!rst) begin
            clk_count     <= 0;
            bit_index     <= 0;
            data_shift    <= 0;
            parity_calc   <= 0;
            parity_sample <= 0;
            leds          <= 4'b1111;
        end else begin
            case (state)
                IDLE: begin
                    clk_count     <= 0;
                    bit_index     <= 0;
                    parity_calc   <= 0;
                    
                end

               // START: begin
               //     clk_count <= clk_count + 1;
                //end

                DATA: begin
                    if (clk_count >= CLOCKS_PER_BIT) begin  //5208
                        data_shift[bit_index] <=  rx_stable;

                        $display("rx=%0d", rx_stable);
 
                        parity_calc <= parity_calc ^ rx_stable;
                        clk_count <= 0;
                        bit_index <= bit_index + 1;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                PARITY: begin
                    if (clk_count >= CLOCKS_PER_BIT) begin  // 5208
                        parity_sample <= rx_stable;
                        clk_count <= 0;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                STOP: begin
                    if (clk_count >= CLOCKS_PER_BIT) begin  //5208
                        clk_count <= 0;
                        
                                $display("STOP STATE: Received data = %b ? LEDs = %b", data_shift, data_shift[3:0]);

                        //if (parity_sample == ~parity_calc)
                            leds <= ( data_shift[6:3]);
                       // else
                        //    leds <= 4'b1111;  // error code (all LEDs on)
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
            endcase
        end
    end


endmodule

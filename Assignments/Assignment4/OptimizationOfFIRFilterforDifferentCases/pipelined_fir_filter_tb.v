module pipelined_fir_filter_tb;
    // Parameters
    parameter CLK_PERIOD = 10; // 10ns = 100MHz clock
    
    // Signals
    reg clk;
    reg rst;
    reg [7:0] x_in;
    reg [7:0] coef_val;
    reg writeen;
    reg tlast;
    wire [17:0] y_out;
    wire data_valid;
    
    // Instantiate the DUT (Device Under Test)
    pipelined_fir_filter_7tap dut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .coef_val(coef_val),
        .writeen(writeen),
        .tlast(tlast),
        .y_out(y_out),
        .data_valid(data_valid)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        x_in = 0;
        coef_val = 0;
        writeen = 0;
        tlast = 0;
        
        // Release reset
        #(CLK_PERIOD*2) rst = 0;
        
        // Load coefficients [1, 2, 3, 4, 5, 6, 7]
        #CLK_PERIOD;
        writeen = 1;
        
        coef_val = 10; // h[0] = 1
        #CLK_PERIOD;
        
        coef_val = 20; // h[1] = 2
        #CLK_PERIOD;
        
        coef_val = 30; // h[2] = 3
        #CLK_PERIOD;
        
        coef_val = 40; // h[3] = 4
        #CLK_PERIOD;
        
        coef_val = 50; // h[4] = 5
        #CLK_PERIOD;
        
        coef_val = 60; // h[5] = 6
        #CLK_PERIOD;
        
        coef_val = 70; // h[6] = 7
        tlast = 1;
        #CLK_PERIOD;
        
        // End coefficient loading
        writeen = 0;
        tlast = 0;
        
        // Apply input sequence [10, 20, 30, 40, 50, 60, 70]
        #CLK_PERIOD;
        x_in = 1;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        
        // Wait for pipeline to complete
        #(CLK_PERIOD*10);
        
        // Test another sequence with alternating 1s and 0s
        x_in = 1;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        #CLK_PERIOD;
        x_in = 0;
        
        // Wait for pipeline to complete
        #(CLK_PERIOD*10);
        
        $finish;
    end
    
    // Monitor results
    initial begin
        $monitor("Time=%0t, x_in=%0d, y_out=%0d, valid=%0b", $time, x_in, y_out, data_valid);
    end
    
    // Expected results (optional - can be verified in waveform or through assertions)
    // For input [10, 20, 30, 40, 50, 60, 70] and coeffs [1, 2, 3, 4, 5, 6, 7]:
    // y[6] = 10*7 + 20*6 + 30*5 + 40*4 + 50*3 + 60*2 + 70*1 = 70 + 120 + 150 + 160 + 150 + 120 + 70 = 840
endmodule

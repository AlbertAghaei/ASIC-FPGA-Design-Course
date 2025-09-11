`timescale 1ns/1ps

module tb_fir_filter_7tap_parallel();

    reg clk;
    reg rst;
    reg [7:0] x_in1;
    reg [7:0] x_in2;
    reg [7:0] coef_val;
    reg writeen;
    reg tlast;
    wire [17:0] y_out1;
    wire [17:0] y_out2;

    // Instantiate the DUT
    fir_filter_7tap_parallel dut (
        .clk(clk),
        .rst(rst),
        .x_in1(x_in1),
        .x_in2(x_in2),
        .coef_val(coef_val),
        .writeen(writeen),
        .tlast(tlast),
        .y_out1(y_out1),
        .y_out2(y_out2)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns clock period
    end

    initial begin
        // Initial values
        rst = 1;
        x_in1 = 0;
        x_in2 = 0;
        coef_val = 0;
        writeen = 0;
        tlast = 0;

        // Reset
        #20;
        rst = 0;

        // Load coefficients: 10, 20, 30, 40, 50, 60, 70
        @(posedge clk); writeen = 1; coef_val = 8'd10;
        @(posedge clk); coef_val = 8'd20;
        @(posedge clk); coef_val = 8'd30;
        @(posedge clk); coef_val = 8'd40;
        @(posedge clk); coef_val = 8'd50;
        @(posedge clk); coef_val = 8'd60;
        @(posedge clk); coef_val = 8'd70; tlast = 1;

        @(posedge clk);
        writeen = 0;
        tlast = 0;
        coef_val = 0;

        // Apply inputs
        @(posedge clk);
        x_in1 = 8'd1;
        x_in2 = 8'd2;
        
        @(posedge clk);
        x_in1 = 8'd3;
        x_in2 = 8'd4;
        
        @(posedge clk);
        x_in1 = 8'd5;
        x_in2 = 8'd6;

        @(posedge clk);
        x_in1 = 8'd7;
        x_in2 = 8'd8;

        @(posedge clk);
        x_in1 = 8'd9;
        x_in2 = 8'd10;

        @(posedge clk);
        x_in1 = 8'd11;
        x_in2 = 8'd12;

        // Stop inputs
        @(posedge clk);
        x_in1 = 0;
        x_in2 = 0;

        // Let the filter settle
        repeat(10) @(posedge clk);

        $stop;
    end

    // Monitor outputs
    always @(posedge clk) begin
        $display("At time %0t : y_out1 = %d, y_out2 = %d", $time, y_out1, y_out2);
    end

endmodule

module tb_fir_filter_symmetric;
    reg clk, rst;
    reg [7:0] x_in, coef_val;
    reg writeen, tlast;
    wire [17:0] y_out;

    fir_filter_symmetric uut (
        .clk(clk), .rst(rst),
        .x_in(x_in),
        .coef_val(coef_val),
        .writeen(writeen),
        .tlast(tlast),
        .y_out(y_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    integer i;

    initial begin
        $display("Time\tOutput");
        $monitor("%0d\t%d", $time, y_out);

        rst = 1;
        x_in = 0;
        coef_val = 0;
        writeen = 0;
        tlast = 0;
        #10;
        rst = 0;

        // Load symmetric coefficients: a=10, b=20, c=30, d=40
        // Final coefficients: [10 20 30 40 30 20 10]
        coef_val = 8'd10; writeen = 1; tlast = 0; #10;
        coef_val = 8'd20; writeen = 1; tlast = 0; #10;
        coef_val = 8'd30; writeen = 1; tlast = 0; #10;
        coef_val = 8'd40; writeen = 1; tlast = 1; #10;

        // Disable writing
        writeen = 0;
        tlast = 0;
        coef_val = 0;

        // Apply impulse input (1 followed by 0s)
        x_in = 8'd1; #10;
        x_in = 8'd0;

        // Wait and observe outputs
        for (i = 0; i < 20; i = i + 1)
            #10;

        $finish;
    end
endmodule

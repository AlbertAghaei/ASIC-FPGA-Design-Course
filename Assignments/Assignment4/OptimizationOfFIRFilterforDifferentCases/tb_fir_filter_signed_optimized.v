module tb_fir_filter_signed_optimized;
    reg clk, rst;
    reg [7:0] x_in;
    reg signed [7:0] coef_val;
    reg writeen, tlast;
    wire signed [17:0] y_out;

    fir_filter_7tap_sparse uut (
        .clk(clk), .rst(rst),
        .x_in(x_in),
        .coef_val(coef_val),
        .writeen(writeen),
        .tlast(tlast),
        .y_out(y_out)
    );

    // Clock generation
    initial clk = 0;
    always #20 clk = ~clk;

    integer i;
    reg signed [7:0] coeff_set[0:6];

    initial begin
        $display("Time\tOutput");
        $monitor("%0d\t%d", $time, y_out);

        rst = 1;
        x_in = 0;
        coef_val = 0;
        writeen = 0;
        tlast = 0;
        #40;
        rst = 0;

        // Example coefficients: {1, 0, -1, 0, 1, 0, -1}
        coeff_set[0] = 1;
        coeff_set[1] = 0;
        coeff_set[2] = -1;
        coeff_set[3] = 0;
        coeff_set[4] = 1;
        coeff_set[5] = 0;
        coeff_set[6] = -1;

        // Load coefficients
        for (i = 0; i < 7; i = i + 1) begin
            coef_val = coeff_set[i];
            writeen = 1;
            tlast = (i == 6);
            #40;
        end

        writeen = 0;
        tlast = 0;

        // Apply impulse input
        x_in = 8'd1; #40;
        x_in = 8'd0;

        // Wait and observe outputs
        for (i = 0; i < 10; i = i + 1)
            #40;

        $finish;
    end
endmodule

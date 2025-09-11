module tb_fir_filter_7tap;
    reg clk, rst;
    reg [7:0] x_in, coef_val;
    reg writeen, tlast;
    wire [17:0] y_out;

    fir_filter_7tap uut (
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

        // Load coefficients: 10, 20, ..., 70
        for (i = 0; i < 7; i = i + 1) begin
            coef_val = (i+1)*10;
            writeen = 1;
            tlast = (i == 6);
            #10;
        end

        // Disable writing
        writeen = 0;
        tlast = 0;
        coef_val = 0;

        // Apply impulse input (1 followed by 0s)
        x_in = 8'd1; #10;
        x_in = 8'd0;

        // Wait and observe outputs (should match coefficients)
        for (i = 0; i < 10; i = i + 1)
            #10;

        $finish;
    end
endmodule

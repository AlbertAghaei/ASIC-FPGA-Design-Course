`timescale 1ns / 1ps

module fir_filter_resourcesharing_tb;

    reg clk, rst;
    reg [7:0] x_in, coef_val;
    reg writeen, tlast;
    wire [18:0] y_out;
    

    fir_filter_resourcesharing dut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .coef_val(coef_val),
        .writeen(writeen),
        .tlast(tlast),
        .y_out(y_out)
    );


    always #5 clk = ~clk;

    reg [7:0] coeffs[0:6];
    integer i;

    initial begin


        clk = 0;
        rst = 1;
        x_in = 0;
        coef_val = 0;
        writeen = 0;
        tlast = 0;

        coeffs[0] = 8'd10;
        coeffs[1] = 8'd20;
        coeffs[2] = 8'd30;
        coeffs[3] = 8'd40;
        coeffs[4] = 8'd50;
        coeffs[5] = 8'd60;
        coeffs[6] = 8'd70;

        #15 rst = 0;


        for (i = 0; i < 7; i = i + 1) begin
            @(posedge clk);
            coef_val <= coeffs[i];
            writeen <= 1;
            tlast <= (i == 6);
        end

        @(posedge clk);
        writeen <= 0;
        tlast <= 0;


        repeat (5) begin

            @(posedge clk);
            x_in <= 8'd1;


            repeat (19) begin
                @(posedge clk);
                x_in <= 8'd0;
            end
        end

        #50;
        $finish;
    end

   

endmodule

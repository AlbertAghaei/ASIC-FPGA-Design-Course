`timescale 1ns / 1ps

module fft_radix2_16_tb;

    reg clk = 0;
    reg rst = 1;

// 16-point input arrays (real + imag)
    reg signed [15:0] real_in[15:0];
    reg signed [15:0] imag_in[15:0];

// 16-point output wires
    wire signed [15:0] real_out[15:0];
    wire signed [15:0] imag_out[15:0];

    always #5 clk = ~clk;

    // Instantiate the FFT DUT
    fft_radix2_16 uut (
        .clk(clk),
        .rst(rst),
         // Input and output connections
        .real_in0(real_in[0]), .imag_in0(imag_in[0]),
        .real_in1(real_in[1]), .imag_in1(imag_in[1]),
        .real_in2(real_in[2]), .imag_in2(imag_in[2]),
        .real_in3(real_in[3]), .imag_in3(imag_in[3]),
        .real_in4(real_in[4]), .imag_in4(imag_in[4]),
        .real_in5(real_in[5]), .imag_in5(imag_in[5]),
        .real_in6(real_in[6]), .imag_in6(imag_in[6]),
        .real_in7(real_in[7]), .imag_in7(imag_in[7]),
        .real_in8(real_in[8]), .imag_in8(imag_in[8]),
        .real_in9(real_in[9]), .imag_in9(imag_in[9]),
        .real_in10(real_in[10]), .imag_in10(imag_in[10]),
        .real_in11(real_in[11]), .imag_in11(imag_in[11]),
        .real_in12(real_in[12]), .imag_in12(imag_in[12]),
        .real_in13(real_in[13]), .imag_in13(imag_in[13]),
        .real_in14(real_in[14]), .imag_in14(imag_in[14]),
        .real_in15(real_in[15]), .imag_in15(imag_in[15]),
        .real_out0(real_out[0]), .imag_out0(imag_out[0]),
        .real_out1(real_out[1]), .imag_out1(imag_out[1]),
        .real_out2(real_out[2]), .imag_out2(imag_out[2]),
        .real_out3(real_out[3]), .imag_out3(imag_out[3]),
        .real_out4(real_out[4]), .imag_out4(imag_out[4]),
        .real_out5(real_out[5]), .imag_out5(imag_out[5]),
        .real_out6(real_out[6]), .imag_out6(imag_out[6]),
        .real_out7(real_out[7]), .imag_out7(imag_out[7]),
        .real_out8(real_out[8]), .imag_out8(imag_out[8]),
        .real_out9(real_out[9]), .imag_out9(imag_out[9]),
        .real_out10(real_out[10]), .imag_out10(imag_out[10]),
        .real_out11(real_out[11]), .imag_out11(imag_out[11]),
        .real_out12(real_out[12]), .imag_out12(imag_out[12]),
        .real_out13(real_out[13]), .imag_out13(imag_out[13]),
        .real_out14(real_out[14]), .imag_out14(imag_out[14]),
        .real_out15(real_out[15]), .imag_out15(imag_out[15])
    );

    integer i;

    initial begin
        $display("======== TEST 1: Impulse Input ========");
        // Reset
        rst = 1;
        #10;
        rst = 0;

        // Impulse: x[0] = 1000
        for (i = 0; i < 16; i = i + 1) begin
            real_in[i] = (i == 0) ? 16'sd1000 : 0;
            imag_in[i] = 0;
        end

        #100;

        for (i = 0; i < 16; i = i + 1)
            $display("X[%0d] = %d + j%d", i, real_out[i], imag_out[i]);

        // Reset before next test
        $display("\n======== TEST 2: Sine Wave Input ========");
        rst = 1;
        #10;
        rst = 0;

        // Cosine wave input: one period over 16 samples
        real_in[0] = 1000;   imag_in[0] = 0;
        real_in[1] = 923;    imag_in[1] = 0;
        real_in[2] = 707;    imag_in[2] = 0;
        real_in[3] = 382;    imag_in[3] = 0;
        real_in[4] = 0;      imag_in[4] = 0;
        real_in[5] = -382;   imag_in[5] = 0;
        real_in[6] = -707;   imag_in[6] = 0;
        real_in[7] = -923;   imag_in[7] = 0;
        real_in[8] = -1000;  imag_in[8] = 0;
        real_in[9] = -923;   imag_in[9] = 0;
        real_in[10] = -707;  imag_in[10] = 0;
        real_in[11] = -382;  imag_in[11] = 0;
        real_in[12] = 0;     imag_in[12] = 0;
        real_in[13] = 382;   imag_in[13] = 0;
        real_in[14] = 707;   imag_in[14] = 0;
        real_in[15] = 923;   imag_in[15] = 0;

        #100;

     // Display FFT output (Sine Wave)
        for (i = 0; i < 16; i = i + 1)
            $display("X[%0d] = %d + j%d", i, real_out[i], imag_out[i]);

        $stop;
    end

endmodule

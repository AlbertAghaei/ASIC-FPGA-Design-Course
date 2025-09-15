// Stage 2: Uses W0, W2, W4, W6

module fft_radix2_16_stage2 (
    input wire clk,
    input wire rst,

    input wire signed [15:0] real_in0,  input wire signed [15:0] imag_in0,
    input wire signed [15:0] real_in1,  input wire signed [15:0] imag_in1,
    input wire signed [15:0] real_in2,  input wire signed [15:0] imag_in2,
    input wire signed [15:0] real_in3,  input wire signed [15:0] imag_in3,
    input wire signed [15:0] real_in4,  input wire signed [15:0] imag_in4,
    input wire signed [15:0] real_in5,  input wire signed [15:0] imag_in5,
    input wire signed [15:0] real_in6,  input wire signed [15:0] imag_in6,
    input wire signed [15:0] real_in7,  input wire signed [15:0] imag_in7,
    input wire signed [15:0] real_in8,  input wire signed [15:0] imag_in8,
    input wire signed [15:0] real_in9,  input wire signed [15:0] imag_in9,
    input wire signed [15:0] real_in10, input wire signed [15:0] imag_in10,
    input wire signed [15:0] real_in11, input wire signed [15:0] imag_in11,
    input wire signed [15:0] real_in12, input wire signed [15:0] imag_in12,
    input wire signed [15:0] real_in13, input wire signed [15:0] imag_in13,
    input wire signed [15:0] real_in14, input wire signed [15:0] imag_in14,
    input wire signed [15:0] real_in15, input wire signed [15:0] imag_in15,

    output wire signed [15:0] real_out0,  output wire signed [15:0] imag_out0,
    output wire signed [15:0] real_out1,  output wire signed [15:0] imag_out1,
    output wire signed [15:0] real_out2,  output wire signed [15:0] imag_out2,
    output wire signed [15:0] real_out3,  output wire signed [15:0] imag_out3,
    output wire signed [15:0] real_out4,  output wire signed [15:0] imag_out4,
    output wire signed [15:0] real_out5,  output wire signed [15:0] imag_out5,
    output wire signed [15:0] real_out6,  output wire signed [15:0] imag_out6,
    output wire signed [15:0] real_out7,  output wire signed [15:0] imag_out7,
    output wire signed [15:0] real_out8,  output wire signed [15:0] imag_out8,
    output wire signed [15:0] real_out9,  output wire signed [15:0] imag_out9,
    output wire signed [15:0] real_out10, output wire signed [15:0] imag_out10,
    output wire signed [15:0] real_out11, output wire signed [15:0] imag_out11,
    output wire signed [15:0] real_out12, output wire signed [15:0] imag_out12,
    output wire signed [15:0] real_out13, output wire signed [15:0] imag_out13,
    output wire signed [15:0] real_out14, output wire signed [15:0] imag_out14,
    output wire signed [15:0] real_out15, output wire signed [15:0] imag_out15
);

    reg signed [15:0] out_real[15:0];
    reg signed [15:0] out_imag[15:0];

 // Twiddle factors: Only 4 unique values used
    wire signed [15:0] w_real[3:0];
    wire signed [15:0] w_imag[3:0];

    assign w_real[0] =  16'sd16384;  assign w_imag[0] =  16'sd0;       // W0
    assign w_real[1] =   16'sd0;     assign w_imag[1] = -16'sd16384;   // W2
    assign w_real[2] = -16'sd16384;  assign w_imag[2] =  16'sd0;       // W4
    assign w_real[3] =   16'sd0;     assign w_imag[3] =  16'sd16384;   // W6

 // Butterfly input pairs
    wire signed [15:0] A_real[7:0], A_imag[7:0];
    wire signed [15:0] B_real[7:0], B_imag[7:0];

    assign A_real[0] = real_in0;   assign A_imag[0] = imag_in0;
    assign B_real[0] = real_in2;   assign B_imag[0] = imag_in2;

    assign A_real[1] = real_in1;   assign A_imag[1] = imag_in1;
    assign B_real[1] = real_in3;   assign B_imag[1] = imag_in3;

    assign A_real[2] = real_in4;   assign A_imag[2] = imag_in4;
    assign B_real[2] = real_in6;   assign B_imag[2] = imag_in6;

    assign A_real[3] = real_in5;   assign A_imag[3] = imag_in5;
    assign B_real[3] = real_in7;   assign B_imag[3] = imag_in7;

    assign A_real[4] = real_in8;   assign A_imag[4] = imag_in8;
    assign B_real[4] = real_in10;  assign B_imag[4] = imag_in10;

    assign A_real[5] = real_in9;   assign A_imag[5] = imag_in9;
    assign B_real[5] = real_in11;  assign B_imag[5] = imag_in11;

    assign A_real[6] = real_in12;  assign A_imag[6] = imag_in12;
    assign B_real[6] = real_in14;  assign B_imag[6] = imag_in14;

    assign A_real[7] = real_in13;  assign A_imag[7] = imag_in13;
    assign B_real[7] = real_in15;  assign B_imag[7] = imag_in15;

    integer i;
    reg signed [31:0] tw_re, tw_im;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
        // Clear output on reset
            for (i = 0; i < 16; i = i + 1) begin
                out_real[i] <= 0;
                out_imag[i] <= 0;
            end
        end else begin
        // Compute butterflies with selected twiddle
            for (i = 0; i < 8; i = i + 1) begin
             // i[2:1] selects W0/W2/W4/W6
                tw_re = (B_real[i] * w_real[i[2:1]]) - (B_imag[i] * w_imag[i[2:1]]);
                tw_im = (B_real[i] * w_imag[i[2:1]]) + (B_imag[i] * w_real[i[2:1]]);

                tw_re = tw_re >>> 14;
                tw_im = tw_im >>> 14;

                out_real[i]     <= A_real[i] + tw_re[15:0];
                out_imag[i]     <= A_imag[i] + tw_im[15:0];
                out_real[i+8]   <= A_real[i] - tw_re[15:0];
                out_imag[i+8]   <= A_imag[i] - tw_im[15:0];
            end
        end
    end

    // Connect outputs
    assign real_out0  = out_real[0];  assign imag_out0  = out_imag[0];
    assign real_out1  = out_real[1];  assign imag_out1  = out_imag[1];
    assign real_out2  = out_real[2];  assign imag_out2  = out_imag[2];
    assign real_out3  = out_real[3];  assign imag_out3  = out_imag[3];
    assign real_out4  = out_real[4];  assign imag_out4  = out_imag[4];
    assign real_out5  = out_real[5];  assign imag_out5  = out_imag[5];
    assign real_out6  = out_real[6];  assign imag_out6  = out_imag[6];
    assign real_out7  = out_real[7];  assign imag_out7  = out_imag[7];
    assign real_out8  = out_real[8];  assign imag_out8  = out_imag[8];
    assign real_out9  = out_real[9];  assign imag_out9  = out_imag[9];
    assign real_out10 = out_real[10]; assign imag_out10 = out_imag[10];
    assign real_out11 = out_real[11]; assign imag_out11 = out_imag[11];
    assign real_out12 = out_real[12]; assign imag_out12 = out_imag[12];
    assign real_out13 = out_real[13]; assign imag_out13 = out_imag[13];
    assign real_out14 = out_real[14]; assign imag_out14 = out_imag[14];
    assign real_out15 = out_real[15]; assign imag_out15 = out_imag[15];

endmodule

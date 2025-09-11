`timescale 1ns / 1ps

module complex_multiplier_24bit (
    input clk,
    input [23:0] A, B, C, D,
    output reg [47:0] real_out, imag_out
);

    // Intermediate values for separate multiplications
    reg [47:0] AC, BD, AD, BC;

    // Force DSP usage for all multiplications
    (* use_dsp = "yes" *) reg [23:0] A_ext, B_ext, C_ext, D_ext;

    // First stage: Compute each multiplication independently
    always @(posedge clk) begin
        A_ext <= A;
        B_ext <= B;
        C_ext <= C;
        D_ext <= D;

        AC <= A_ext * C_ext;    // DSP 1 & 2
        BD <= B_ext * D_ext;    // DSP 3 & 4
        AD <= A_ext * D_ext;    // DSP 5 & 6
        BC <= B_ext * C_ext;    // DSP 7 & 8
    end

    // Second stage: Compute final outputs
    always @(posedge clk) begin
        real_out <= AC - BD;               // Real part
        imag_out <= AD + BC;               // Imaginary part
    end

endmodule

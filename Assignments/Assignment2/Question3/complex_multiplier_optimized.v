`timescale 1ns / 1ps

module complex_multiplier_optimized (
    input clk,
    input [17:0] A, B, C, D,
    output reg [35:0] real_out, imag_out
);

    // Intermediate values
    reg [35:0] AC, BD, AplusB, CplusD, AB_CD;

    // First stage: Compute the key multiplications
    always @(posedge clk) begin
        AC      <= A * C;            // 1st DSP
        BD      <= B * D;            // 2nd DSP
        AplusB  <= A + B;           // Addition in logic
        CplusD  <= C + D;           // Addition in logic
    end

    // Second stage: Combined multiplication
    always @(posedge clk) begin
        AB_CD <= AplusB * CplusD;    // 3rd DSP
    end

    // Final stage: Compute the real and imaginary outputs
    always @(posedge clk) begin
        real_out <= AC - BD;
        imag_out <= AB_CD - AC - BD;
    end

endmodule

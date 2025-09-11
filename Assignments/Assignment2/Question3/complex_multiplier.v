module complex_multiplier (
    input  clk,
    input  [17:0] A, B, C, D,
    output reg [35:0] real_out, imag_out
);

    // First stage: Multiplication
    reg [35:0] AC, BD, AD, BC;

    always@(posedge clk) begin
        AC <= A * C;  // Real part term 1
        BD <= B * D;  // Real part term 2
        AD <= A * D;  // Imaginary part term 1
        BC <= B * C;  // Imaginary part term 2
    end

    // Second stage: Addition/Subtraction
    reg [35:0] real_tmp, imag_tmp;

    always@(posedge clk) begin
        real_tmp <= AC - BD;
        imag_tmp <= AD + BC;
    end

    // Final output
    always@(posedge clk) begin
        real_out <= real_tmp;
        imag_out <= imag_tmp;
    end

endmodule

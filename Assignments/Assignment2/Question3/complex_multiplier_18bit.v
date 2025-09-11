module complex_multiplier_18bit (
    input clk,
    input [17:0] A, B, C, D,
    output reg [35:0] real_out,
    output reg [35:0] imag_out
);

    // Intermediate signals for calculations
    reg [35:0] AC, BD, AB_CD;

    // Prevent DSP usage for multiplications
    (* use_dsp = "no" *) wire [35:0] A_C = A * C;
    (* use_dsp = "no" *) wire [35:0] B_D = B * D;
    (* use_dsp = "no" *) wire [35:0] ABxCD = (A + B) * (C + D);

    // Pipeline or sequential logic
    always @(posedge clk) begin
        real_out <= A_C - B_D;
        imag_out <= ABxCD - A_C - B_D;
    end
endmodule

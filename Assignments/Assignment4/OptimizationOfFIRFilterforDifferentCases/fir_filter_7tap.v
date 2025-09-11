module fir_filter_7tap (
    input clk,
    input rst,
    input [7:0] x_in,
    input [7:0] coef_val,
    input writeen,
    input tlast,
    output reg [17:0] y_out
);
    // Internal Coefficient Registers
    reg [7:0] coeffs[0:6];
    reg [2:0] coef_index;
    reg valid_coeffs;

    // Input Shift Register
    reg [7:0] shift_reg[0:6];

    integer i;
    
    // Load Coefficients
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            coef_index <= 0;
            valid_coeffs <= 0;
        end else if (writeen) begin 
            coeffs[coef_index] <= coef_val;
            coef_index <= coef_index + 1;
            if (tlast) begin
                if (coef_index == 6) begin
                    valid_coeffs <= 1;
                end else begin
                    valid_coeffs <= 0; // discard
                end
                coef_index <= 0;
            end
        end
    end

    // Shift input samples
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 7; i = i + 1)
                shift_reg[i] <= 0;
        end else begin
            for (i = 6; i > 0; i = i - 1)
                shift_reg[i] <= shift_reg[i-1];
            shift_reg[0] <= x_in;
        end
    end

    // Output calculation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_out <= 0;
        end else if (valid_coeffs) begin
            y_out <= coeffs[0] * shift_reg[0] +
                     coeffs[1] * shift_reg[1] +
                     coeffs[2] * shift_reg[2] +
                     coeffs[3] * shift_reg[3] +
                     coeffs[4] * shift_reg[4] +
                     coeffs[5] * shift_reg[5] +
                     coeffs[6] * shift_reg[6];
        end else begin
            y_out <= 0;
        end
    end
endmodule

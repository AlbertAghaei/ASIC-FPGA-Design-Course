module fir_filter_7tap_sparse (
    input clk,
    input rst,
    input [7:0] x_in,
    input signed [7:0] coef_val,
    input writeen,
    input tlast,
    output reg signed [17:0] y_out
);
    // Coefficient Registers
    reg signed [7:0] coeffs[0:6];
    reg [2:0] coef_index;
    reg valid_coeffs;
    reg signed [17:0] acc;

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
                if (coef_index == 6)
                    valid_coeffs <= 1;
                else
                    valid_coeffs <= 0;
                coef_index <= 0;
            end
        end
    end

    // Shift Input Samples
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

    // Output Calculation (optimized for ±1, 0 coefficients)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_out <= 0;
        end else if (valid_coeffs) begin
            
            acc = 0;
            for (i = 0; i < 7; i = i + 1) begin
                case (coeffs[i])
                    8'sd1: acc = acc + shift_reg[i];
                    -8'sd1: acc = acc - shift_reg[i];
                    default: acc = acc;
                endcase
            end
            y_out <= acc;
        end else begin
            y_out <= 0;
        end
    end
endmodule

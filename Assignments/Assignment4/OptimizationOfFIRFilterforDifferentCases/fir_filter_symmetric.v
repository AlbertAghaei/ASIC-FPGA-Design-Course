module fir_filter_symmetric (
    input clk,
    input rst,
    input [7:0] x_in,
    input [7:0] coef_val,
    input writeen,
    input tlast,
    output reg [17:0] y_out
);
    // Store 4 unique symmetric coefficients
    reg [7:0] coeffs[0:3];
    reg [1:0] coef_index;
    reg valid_coeffs;

    // Shift register for inputs
    reg [7:0] x[0:6];  // x[0] = x[n], x[6] = x[n-6]

    integer i;

    // Coefficient loading
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            coef_index <= 0;
            valid_coeffs <= 0;
        end else if (writeen) begin
            coeffs[coef_index] <= coef_val;
            coef_index <= coef_index + 1;
            if (tlast) begin
                valid_coeffs <= (coef_index == 3); // should be 4 values
                coef_index <= 0;
            end
        end
    end

    // Input shift register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 7; i = i + 1)
                x[i] <= 0;
        end else begin
            for (i = 6; i > 0; i = i - 1)
                x[i] <= x[i-1];
            x[0] <= x_in;
        end
    end

    // Output calculation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_out <= 0;
        end else if (valid_coeffs) begin
            y_out <= coeffs[0] * (x[0] + x[6]) +
                     coeffs[1] * (x[1] + x[5]) +
                     coeffs[2] * (x[2] + x[4]) +
                     coeffs[3] * x[3];
        end else begin
            y_out <= 0;
        end
    end
endmodule

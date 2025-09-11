module fir_filter_7tap_parallel (
    input clk,
    input rst,
    input [7:0] x_in1,
    input [7:0] x_in2,
    input [7:0] coef_val,
    input writeen,
    input tlast,
    output reg [17:0] y_out1,
    output reg [17:0] y_out2
);
    // Internal Coefficient Registers
    reg [7:0] coeffs[0:6];
    reg [2:0] coef_index;
    reg valid_coeffs;

    // Input Shift Registers for two parallel streams
    reg [7:0] shift_reg1[0:6];
    reg [7:0] shift_reg2[0:6];

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

    // Shift input samples for stream 1 and stream 2
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 7; i = i + 1) begin
                shift_reg1[i] <= 0;
                shift_reg2[i] <= 0;
            end
        end else begin
            for (i = 6; i > 0; i = i - 1) begin
                shift_reg1[i] <= shift_reg1[i-1];
                shift_reg2[i] <= shift_reg2[i-1];
            end
            shift_reg1[0] <= x_in1;
            shift_reg2[0] <= x_in2;
        end
    end

    // Output calculation for both streams
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_out1 <= 0;
            y_out2 <= 0;
        end else if (valid_coeffs) begin
            y_out1 <= coeffs[0] * shift_reg1[0] +
                      coeffs[1] * shift_reg1[1] +
                      coeffs[2] * shift_reg1[2] +
                      coeffs[3] * shift_reg1[3] +
                      coeffs[4] * shift_reg1[4] +
                      coeffs[5] * shift_reg1[5] +
                      coeffs[6] * shift_reg1[6];

            y_out2 <= coeffs[0] * shift_reg2[0] +
                      coeffs[1] * shift_reg2[1] +
                      coeffs[2] * shift_reg2[2] +
                      coeffs[3] * shift_reg2[3] +
                      coeffs[4] * shift_reg2[4] +
                      coeffs[5] * shift_reg2[5] +
                      coeffs[6] * shift_reg2[6];
        end else begin
            y_out1 <= 0;
            y_out2 <= 0;
        end
    end
endmodule

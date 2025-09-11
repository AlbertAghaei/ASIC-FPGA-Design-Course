module pipelined_fir_filter_7tap (
    input clk,
    input rst,
    input [7:0] x_in,
    input [7:0] coef_val,
    input writeen,
    input tlast,
    output reg [17:0] y_out,
    output reg data_valid
);
    // Internal Coefficient Registers
    reg [7:0] coeffs[0:6];
    reg [2:0] coef_index;
    reg valid_coeffs;

    // Input Shift Register
    reg [7:0] shift_reg[0:6];
    
    // Pipeline Registers for Multiplication Results
    reg [15:0] mul_results[0:6];
    
    // Pipeline Registers for Addition Stages
    // First addition stage
    reg [16:0] add_stage1[0:3]; // 4 partial sums
    
    // Second addition stage
    reg [17:0] add_stage2[0:1]; // 2 partial sums
    
    // Pipeline valid signals
    reg valid_pipe[1:4];
    
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

    // Shift input samples - Stage 1
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

    // Stage 2: Parallel Multiplications
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 7; i = i + 1)
                mul_results[i] <= 0;
            valid_pipe[1] <= 0;
        end else begin
            if (valid_coeffs) begin
                for (i = 0; i < 7; i = i + 1)
                    mul_results[i] <= coeffs[i] * shift_reg[i];
                valid_pipe[1] <= 1;
            end else begin
                valid_pipe[1] <= 0;
            end
        end
    end
    
    // Stage 3: First level addition
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4; i = i + 1)
                add_stage1[i] <= 0;
            valid_pipe[2] <= 0;
        end else begin
            if (valid_pipe[1]) begin
                // Add pairs of products and handle the odd one
                add_stage1[0] <= mul_results[0] + mul_results[1];
                add_stage1[1] <= mul_results[2] + mul_results[3];
                add_stage1[2] <= mul_results[4] + mul_results[5];
                add_stage1[3] <= {1'b0, mul_results[6]}; // Zero-extend for consistency
                valid_pipe[2] <= 1;
            end else begin
                valid_pipe[2] <= 0;
            end
        end
    end
    
    // Stage 4: Second level addition
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            add_stage2[0] <= 0;
            add_stage2[1] <= 0;
            valid_pipe[3] <= 0;
        end else begin
            if (valid_pipe[2]) begin
                add_stage2[0] <= {1'b0, add_stage1[0]} + {1'b0, add_stage1[1]};
                add_stage2[1] <= {1'b0, add_stage1[2]} + {1'b0, add_stage1[3]};
                valid_pipe[3] <= 1;
            end else begin
                valid_pipe[3] <= 0;
            end
        end
    end
    
    // Stage 5: Final addition and output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_out <= 0;
            data_valid <= 0;
        end else begin
            if (valid_pipe[3]) begin
                y_out <= add_stage2[0] + add_stage2[1];
                data_valid <= 1;
            end else begin
                data_valid <= 0;
            end
        end
    end

endmodule

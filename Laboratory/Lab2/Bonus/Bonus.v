module Bonus (
    input clk,
    input rst,
    input [2:0] key,
    output reg Trigger
);

    // Define states using localparam
    localparam S0 = 3'b000;
    localparam S1 = 3'b001;
    localparam S2 = 3'b010;
    localparam S3 = 3'b011;
    localparam S4 = 3'b100;

    // Declare state variables
    reg [2:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            S0: if (key == 3'b000) next_state = S1; else next_state = S0; // First Cross
            S1: if (key == 3'b000) next_state = S2; else next_state = S0; // Second Cross
            S2: if (key == 3'b100) next_state = S3; else next_state = S0; // Square
            S3: if (key == 3'b010) next_state = S4; else next_state = S0; // Triangle
            S4: next_state = S0; // Reset state
            default: next_state = S0;
        endcase
    end

    // Output logic
    always @(*) begin
        if (current_state == S4)
            Trigger = 1'b1;
        else
            Trigger = 1'b0;
    end

endmodule

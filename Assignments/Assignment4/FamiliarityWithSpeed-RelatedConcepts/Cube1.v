module Cube1 (
    input clk,
    input rst,
    input [7:0] in,
    output reg [23:0] out
);

    reg [7:0] in_reg;
    reg [23:0] temp;
    integer i;

    // Input flop
    always @(posedge clk or posedge rst) begin
        if (rst)
            in_reg <= 0;
        else
            in_reg <= in;
    end

    // Combinational logic
    always @(*) begin
        temp = 1;
        for (i = 0; i < 3; i = i + 1) begin
            temp = temp * in_reg;
        end
    end

    // Output flop
    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 0;
        else
            out <= temp;
    end

endmodule

module counter_0to9(
    input clk,           // Clock input
    input rst,           // Reset input (active-high)
    input enable,        // Enable input to count
    output reg [3:0] count // 4-bit count (0-9)
);

    always @(posedge clk) begin
        if (rst)
            count <= 0;   // Reset the counter to 0
        else if (enable) begin
            if (count == 9)
                count <= 0;  // Reset the counter to 0 after 9
            else
                count <= count + 1;  // Increment the counter
        end
    end

endmodule

module counter_50M(
    input clk,          // 50 MHz clock input
    input rst,          // Reset input (active-high)
    output reg enable   // Enable pulse every 1 second
);

    reg [25:0] count;
    
    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            enable <= 0;
        end else if (count == 50000000-1) begin
            count <= 0;
            enable <= 1; // Generate a one-cycle pulse
        end else begin
            count <= count + 1;
            enable <= 0;
        end
    end
endmodule

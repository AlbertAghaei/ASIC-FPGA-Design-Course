module FIFO (
    input clk, rst,
    input [7:0] wr_data,
    input wr_en, rd_en,
    output reg [7:0] rd_data,
    output wire empty, full
);

    reg [7:0] mem [15:0]; // 16 x 8-bit memory
    reg [4:0] pointer_wr; // Track number of stored items

    assign empty = (pointer_wr==0);
    assign full = (pointer_wr==16);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pointer_wr <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[pointer_wr] <= wr_data;
                pointer_wr <= pointer_wr + 1;
            end
            if (rd_en && !empty) begin
                rd_data <= mem[0];
                for (integer i = 0; i < 15; i = i + 1) begin
                    mem[i] <= mem[i + 1];
                end
                pointer_wr <= pointer_wr - 1;
            end
        end
    end
endmodule

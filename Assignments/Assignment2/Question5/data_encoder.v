module data_encoder(
    input wire clk,
    input wire [15:0] data_in,
    output wire [31:0] encoded_out
);

    reg [15:0] crc_val;
    reg [31:0] shift_reg;
    integer idx;
    parameter poly = 16'h8007;
    assign encoded_out = {data_in, crc_val};

    always @(posedge clk) begin
        crc_val = 16'b0;
        shift_reg = {data_in, 16'b0};

        for (idx = 0; idx < 16; idx = idx + 1) begin
            if (shift_reg[31])
                shift_reg[31:16] = shift_reg[31:16] ^ poly;

            shift_reg = shift_reg << 1;
        end

        crc_val = shift_reg[31:16];
    end

endmodule

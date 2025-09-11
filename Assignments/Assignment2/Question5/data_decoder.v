module data_decoder(
    input wire clk,
    input wire [31:0] data_in,
    output reg valid_flag,
    output reg error_flag 
);

    reg [15:0] crc_check;
    reg [31:0] shift_reg;
    integer idx;
    parameter poly = 16'h8007;
    //assign valid_flag = (crc_check == data_in[15:0]) ? 1'b1 :1'b0 ;
    //assign error_flag = (crc_check == data_in[15:0]) ? 1'b0 :1'b1 ;

    always @(posedge clk) begin
        crc_check = 16'b0;
        shift_reg = {data_in[31:16], 16'b0};  

        for (idx = 0; idx < 16; idx = idx + 1) begin
            if (shift_reg[31])
                shift_reg[31:16] = shift_reg[31:16] ^ poly;
            shift_reg = shift_reg << 1;
        end

        crc_check = shift_reg[31:16];

        if (!(crc_check == data_in[15:0]) )begin
             valid_flag <= 0;
             error_flag <= 1;
         end else begin
             valid_flag <= 1;
             error_flag <= 0;
         end
    end

endmodule

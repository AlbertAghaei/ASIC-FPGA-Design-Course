module tb_FIFO;
    reg clk, rst, wr_en, rd_en;
    reg [7:0] wr_data;
    wire [7:0] rd_data;
    wire empty, full;

    FIFO uut (.clk(clk), .rst(rst), .wr_data(wr_data), .wr_en(wr_en), .rd_en(rd_en), .rd_data(rd_data), .empty(empty), .full(full));

    always #5 clk = ~clk; // 100MHz clock simulation

    initial begin
        clk = 0; rst = 1;
        wr_en = 0; rd_en = 0; wr_data = 8'b0;
        #10 rst = 0;
        $display("[INFO] Reset complete");

        // Writing data to FIFO
        repeat (16) begin
            @(posedge clk);
            wr_en = 1; wr_data = wr_data + 1;
            $display("[WRITE] Data Written: %h | Full: %b", wr_data, full);
        end

        // Attempt to write when full
        @(posedge clk);
        wr_en = 1; wr_data = 8'hAA;
        $display("[WARNING] Attempted to write when FIFO full. Data: %h | Full: %b", wr_data, full);

        // Start reading data from FIFO
        repeat (16) begin
            @(posedge clk);
            wr_en = 0; rd_en = 1;
            $display("[READ] Data Read: %h | Empty: %b", rd_data, empty);
        end

        // Attempt to read when empty
        @(posedge clk);
        rd_en = 1;
        $display("[WARNING] Attempted to read when FIFO empty. Empty: %b", empty);

        #20 $stop;
    end
endmodule

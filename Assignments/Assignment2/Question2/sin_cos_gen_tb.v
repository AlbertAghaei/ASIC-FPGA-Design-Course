`timescale 1ns/1ns

module sin_cos_gen_tb;

reg [1:0] frequency_sel;
reg clk;
reg rst;
wire [15:0] output_sin;
wire [15:0] output_cos;
wire done;


 sin_cos_gen dut (
    .frequency_sel(frequency_sel),
    .rst(rst),
    .clk(clk),
    .output_sin(output_sin),
    .output_cos(output_cos),
    .done(done)
);

integer SinFile;
integer CosFile;

always @(clk) begin
    #5 clk <= ~clk;
end

initial begin
    clk = 1;

    // Test case 1: frequency_sel = 2X
    rst = 1;
    frequency_sel = 2'b01;
    #10;
    rst = 0;
    SinFile = $fopen("2X_sin_output.txt", "w");
    CosFile = $fopen("2X_cos_output.txt", "w"); #10;
    
    while (dut.done == 0) begin
        $fdisplay(SinFile, "%b", output_sin);
        $fdisplay(CosFile, "%b", output_cos);
        #10;
    end

    $fclose(SinFile); 
    $fclose(CosFile);

    #10;

    // Test case 2: frequency_sel = 8X
    rst = 1;
    frequency_sel = 2'b11;
    #10;
    rst = 0;
    SinFile = $fopen("8X_sin_output.txt", "w");
    CosFile = $fopen("8X_cos_output.txt", "w"); #10;

    while (dut.done == 0) begin
        $fdisplay(SinFile, "%b", output_sin);
        $fdisplay(CosFile, "%b", output_cos);
        #10;
    end

    $fclose(SinFile);
    $fclose(CosFile);

    $stop;
end

endmodule

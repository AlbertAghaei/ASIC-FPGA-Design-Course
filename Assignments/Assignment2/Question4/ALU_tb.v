`timescale 1ns / 1ps

module ALU_tb;

    // Inputs
    reg [7:0] i_a, i_b;
    reg [3:0] i_cont;
    reg i_clk;

    // Output
    wire [8:0] o_out;

    // Instantiate the ALU
    ALU uut (
        .i_a(i_a),
        .i_b(i_b),
        .i_cont(i_cont),
        .i_clk(i_clk),
        .o_out(o_out)
    );

    // Clock generation
    always #5 i_clk = ~i_clk;

    initial begin
        // Initialize inputs
        i_clk = 0;
        i_b = 8'b10000110;  // 6
        i_a = 8'b10000011;  // 3

        // Addition Test
        i_cont = 4'b0000;
        #10 $display("Addition: %d + %d = %d (Carry: %b)", i_a, i_b, o_out[7:0], o_out[8]);

        // Subtraction Test
        i_cont = 4'b0001;
        #10 $display("Subtraction: %d - %d = %d (Borrow: %b)", i_a, i_b, (o_out[7:0]), o_out[8]);


        // Multiplication Test
        i_cont = 4'b0010;
        #10 $display("Multiplication: %d * %d = %d (Carry: %b)", i_a, i_b, o_out[7:0], o_out[8]);

        // Division Test
        i_cont = 4'b0011;
        #10 $display("Division: %d / %d = %d", i_a, i_b, o_out[7:0]);

        // Logical Left Shift Test
        i_cont = 4'b0100;
        #10 $display("Logical Left Shift: %b -> %b", i_a, o_out[7:0]);

        // Logical Right Shift Test
        i_cont = 4'b0101;
        #10 $display("Logical Right Shift: %b -> %b", i_a, o_out[7:0]);

        // Rotate Left Test
        i_cont = 4'b0110;
        #10 $display("Rotate Left: %b -> %b", i_a, o_out[7:0]);

        // Rotate Right Test
        i_cont = 4'b0111;
        #10 $display("Rotate Right: %b -> %b", i_a, o_out[7:0]);

        // AND Test
        i_cont = 4'b1000;
        #10 $display("AND: %b & %b = %b", i_a, i_b, o_out[7:0]);

        // OR Test
        i_cont = 4'b1001;
        #10 $display("OR: %b | %b = %b", i_a, i_b, o_out[7:0]);

        // XOR Test
        i_cont = 4'b1010;
        #10 $display("XOR: %b ^ %b = %b", i_a, i_b, o_out[7:0]);

        // NOR Test
        i_cont = 4'b1011;
        #10 $display("NOR: ~(%b | %b) = %b", i_a, i_b, o_out[7:0]);

        // NAND Test
        i_cont = 4'b1100;
        #10 $display("NAND: ~(%b & %b) = %b", i_a, i_b, o_out[7:0]);

        // XNOR Test
        i_cont = 4'b1101;
        #10 $display("XNOR: ~(%b ^ %b) = %b", i_a, i_b, o_out[7:0]);

        // Equality Check Test
        i_cont = 4'b1110;
        #10 $display("Equality: %d == %d -> %b", i_a, i_b, o_out[0]);

        // Greater Than Check Test
        i_cont = 4'b1111;
        #10 $display("Greater than: %d > %d -> %b", i_a, i_b, o_out[0]);

        $display("All tests completed");
        $stop;
    end
endmodule

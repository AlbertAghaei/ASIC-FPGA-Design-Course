`timescale 1ns/1ps

module tb_CRC_System();

    reg clk;
    reg [15:0] test_data;
    wire [31:0] encoded_data;
    wire is_valid, has_error;
    reg [31:0] noisy_data;
    wire valid_clean, error_clean;
    wire valid_noisy, error_noisy;

    
    data_encoder tx (
        .clk(clk),
        .data_in(test_data),
        .encoded_out(encoded_data)
    );

    
    data_decoder rx_clean (
        .clk(clk),
        .data_in(encoded_data),  
        .valid_flag(valid_clean),
        .error_flag(error_clean)
    );

     data_decoder rx_noisy (
        .clk(clk),
        .data_in(noisy_data),  
        .valid_flag(valid_noisy),
        .error_flag(error_noisy)
    );

    always #10 clk = ~clk; 

    initial begin
        clk = 0;

    
        repeat (5) begin
            @(posedge clk);
            test_data = $urandom % 65536;             
            @(posedge clk);
            @(posedge clk);

            $display("Time: %0t | Clean Data: %0x | Encoded: %0x | Valid: %b | Error: %b",
                     $time, test_data, encoded_data, valid_clean, error_clean);
        end

        
        repeat (5) begin
            @(posedge clk);
            test_data = $urandom % 65536; 
            
            @(posedge clk);
            @(posedge clk);

        
            noisy_data = encoded_data ^ (1 << ($urandom % 16)); 

            @(posedge clk);
            @(posedge clk);

            $display("Time: %0t | Noisy Data: %0x | Noisy Encoded: %0x | Valid: %b | Error: %b",
                     $time, test_data, noisy_data, valid_noisy, error_noisy);
        end

        #100;
        $finish;
    end

    initial begin
        $monitor("Time: %0t | Clean Valid: %b | Clean Error: %b | Noisy Valid: %b | Noisy Error: %b",
                 $time, valid_clean, error_clean, valid_noisy, error_noisy);
    end

endmodule

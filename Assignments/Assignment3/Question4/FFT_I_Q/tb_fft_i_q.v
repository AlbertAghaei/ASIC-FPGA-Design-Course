`timescale 1ns / 1ps

module tb_fft_i_q;

    // Testbench signals
    reg clk;
    reg [15:0] i_in;  // I input (real part)
    reg [15:0] q_in;  // Q input (imaginary part)
    wire [31:0] fft_output; // FFT output
    wire fft_valid;  // FFT valid signal

    // Instantiate the DUT (Device Under Test)
    fft_i_q uut (
        .clk(clk),
        .i_in(i_in),
        .q_in(q_in),
        .fft_output(fft_output),
        .fft_valid(fft_valid)
    );

    // Generate 250 MHz clock (period = 4 ns)
    initial begin
        clk = 0;
        forever #2 clk = ~clk;
    end

    // Apply test values from files and verify results
    integer i, file_i, file_q, file_output;  // Declare file handles
    reg [15:0] i_file [0:15];  // Array to store I data
    reg [15:0] q_file [0:15];  // Array to store Q data

    initial begin
        // Open input files for I and Q values (update to match your file names)
        file_i = $fopen("I_hex.txt", "r");
        file_q = $fopen("Q_hex.txt", "r");

        // Check if the files were opened successfully
        if (file_i == 0 || file_q == 0) begin
            $display("Error opening files.");
            $stop;
        end

        // Read the I and Q values from the files (Hex format)
        for (i = 0; i < 16; i = i + 1) begin
            $fscanf(file_i, "%h\n", i_file[i]);  // Read hex values from I_hex.txt
            $fscanf(file_q, "%h\n", q_file[i]);  // Read hex values from Q_hex.txt
        end

        // Open the output file for FFT results
        file_output = $fopen("fft_output.txt", "w");
        
        // Check if the output file was opened successfully
        if (file_output == 0) begin
            $display("Error opening output file.");
            $stop;
        end

        // Apply values to the inputs and run simulation
        for (i = 0; i < 16; i = i + 1) begin
            i_in = i_file[i];  // Apply I data from file
            q_in = q_file[i];  // Apply Q data from file

            // Wait for FFT calculation to complete
            #100;

            // Write the FFT output to the file (no text, just the value)
            if (fft_valid) begin
                $fwrite(file_output, "%h\n", fft_output); // Store only the FFT value in hex
            end
        end

        // Close the files
        $fclose(file_i);
        $fclose(file_q);
        $fclose(file_output);

        $stop;  // End simulation
    end

endmodule

module fft_i_q (
    input wire clk,                     // Clock input
    input wire [15:0] i_in,             // I input (real part)
    input wire [15:0] q_in,             // Q input (imaginary part)
    output wire [31:0] fft_output,      // FFT output (complex)
    output wire fft_valid               // FFT valid signal
);

    // FFT module instantiation
    wire [31:0] fft_data_out;
    wire fft_valid_out;

    xfft_0 fft_inst (
        .aclk(clk),
        .s_axis_data_tdata({i_in, q_in}),  // Input data to FFT (I and Q)
        .s_axis_data_tvalid(1'b1),  // Always valid input
        .s_axis_data_tlast(1'b0),        // Not using TLAST
        .m_axis_data_tdata(fft_data_out), // Output FFT data
        .m_axis_data_tvalid(fft_valid_out), // FFT valid signal
        .m_axis_data_tlast()             // Not using TLAST for FFT data
    );

    // Output the FFT data
    assign fft_output = fft_data_out;
    assign fft_valid = fft_valid_out;

endmodule

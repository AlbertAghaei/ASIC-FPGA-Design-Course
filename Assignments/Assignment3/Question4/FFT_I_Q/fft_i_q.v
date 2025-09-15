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

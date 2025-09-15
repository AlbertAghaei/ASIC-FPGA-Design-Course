module top_module (
    input wire clk,                    // System clock (e.g., 250 MHz)
    input wire [31:0] phase_input,     // Phase input (manual phase control)
    output wire signed [15:0] sine_out, // DDS sine output (signed)
    output wire signed [15:0] cosine_out, // DDS cosine output (signed)
    output wire valid_out,              // Output valid signal for DDS
    output wire [31:0] fft_data_out,    // FFT data output
    output wire fft_valid_out           // FFT valid output
);

    // DDS logic
    wire [31:0] dds_data_out;
    wire dds_valid_out;
    
    // Instantiating DDS
    dds_compiler_0 u_dds (
        .aclk(clk),                       
        .s_axis_phase_tvalid(1'b1),      // Always valid input
        .s_axis_phase_tdata(phase_input), // Phase input controls the phase
        .s_axis_phase_tlast(1'b0),        // Not using TLAST
        .m_axis_data_tvalid(dds_valid_out),    // DDS data valid
        .m_axis_data_tdata(dds_data_out),      // DDS data (sine and cosine)
        .m_axis_data_tlast()             // Not using TLAST for data
    );
    
    // Extracting sine and cosine from DDS output
    assign sine_out = dds_data_out[31:16];  // Upper 16 bits: SINE
    assign cosine_out = dds_data_out[15:0]; // Lower 16 bits: COSINE
    assign valid_out = dds_valid_out;

    // Instantiating FFT module
    xfft_0 fft_inst (
        .aclk(clk),
        .aclken(1'b1),  // Enable FFT processing
        .s_axis_data_tdata({sine_out, cosine_out}),  // Input data to FFT (Sine and Cosine)
        .s_axis_data_tvalid(valid_out),  // Valid signal from DDS
        .s_axis_data_tlast(1'b0),        // Not using TLAST
        .m_axis_data_tdata(fft_data_out), // Output FFT data
        .m_axis_data_tvalid(fft_valid_out), // FFT valid signal
        .m_axis_data_tlast()             // Not using TLAST for FFT data
    );

endmodule

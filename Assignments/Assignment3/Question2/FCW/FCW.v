module FCW (
    input wire clk,                    // System clock (e.g., 250 MHz)
    input wire [31:0] fcw_input,       // Frequency Control Word input (manual frequency control)
    output wire signed [15:0] sine_out, // DDS sine output (signed)
    output wire signed [15:0] cosine_out, // DDS cosine output (signed)
    output wire valid_out              // Output valid signal
);

    // AXI-Stream input signals for phase increment (Frequency Control Word)
    wire s_axis_phase_tvalid;
    wire [31:0] s_axis_phase_tdata;

    // AXI-Stream output signals from DDS
    wire m_axis_data_tvalid;
    wire [31:0] m_axis_data_tdata;

    // Always valid input for phase
    assign s_axis_phase_tvalid = 1'b1;
    assign s_axis_phase_tdata  = fcw_input; // Here, fcw_input controls the frequency

    // Instantiate the DDS Compiler IP
    dds_compiler_0 u_dds (
        .aclk(clk),                       // Clock input
        .s_axis_phase_tvalid(s_axis_phase_tvalid),  // Phase input valid signal
        .s_axis_phase_tdata(s_axis_phase_tdata),    // Phase input data (manual phase control)
        .s_axis_phase_tlast(1'b0),        // Not using TLAST (No packet framing)

        .m_axis_data_tvalid(m_axis_data_tvalid),    // Data output valid signal
        .m_axis_data_tdata(m_axis_data_tdata),      // Data output (32-bit sine and cosine)
        .m_axis_data_tlast(),                      // Not using TLAST for data
        .m_axis_phase_tvalid(),                    // Not using phase output
        .m_axis_phase_tdata(),                     // Not using phase output
        .m_axis_phase_tlast()                      // Not using phase output
    );

    // Extract sine and cosine from 32-bit output (signed)
    assign sine_out    = m_axis_data_tdata[31:16];  // Upper 16 bits: SINE (signed)
    assign cosine_out  = m_axis_data_tdata[15:0];   // Lower 16 bits: COSINE (signed)
    assign valid_out   = m_axis_data_tvalid;

endmodule

`timescale 1ns / 1ps

module timer(
    input clk,                    // 50 MHz clock input
    input reset_n,                // Active-low synchronous reset
    input [5:0] minutes,          // 6-bit input for minutes (0 to 59)
    input [5:0] seconds,          // 6-bit input for seconds (0 to 59)
    output reg done,
    output reg [5:0] count_minutes,
    output reg [5:0] count_seconds
);

    reg [5:0] microsec_counter;   // Counter for generating 1 microsecond pulse
    reg microsec_pulse;           // 1 microsecond pulse for each tick

    // Generate 1 microsecond pulse from 50 MHz clock
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            microsec_counter <= 0;
            microsec_pulse <= 0;
        end else begin
            if (microsec_counter == 25 - 1) begin  // 25 clock cycles = 1 microsecond
                microsec_counter <= 0;
                microsec_pulse <= 1;  // Generate 1 microsecond pulse
            end else begin
                microsec_counter <= microsec_counter + 1;
                microsec_pulse <= 0;
            end
        end
    end

    // Active-low synchronous reset and countdown logic using microsecond pulse
    always @(posedge microsec_pulse or negedge reset_n) begin
        if (!reset_n) begin
            count_minutes <= minutes;
            count_seconds <= seconds;
            done <= 0;
        end else begin
            // Countdown logic
            if (count_minutes == 0 && count_seconds == 0) begin
                done <= 1;  // Timer has expired
            end else begin
                done <= 0;
                if (count_seconds == 0) begin
                    if (count_minutes > 0) begin
                        count_minutes <= count_minutes - 1;
                        count_seconds <= 59;
                    end
                end else begin
                    count_seconds <= count_seconds - 1;
                end
            end
        end
    end
endmodule

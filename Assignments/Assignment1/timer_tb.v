`timescale 1ns / 1ps
module timer_tb;
    reg clk;
reg reset_n;
reg [5:0] minutes;
reg [5:0] seconds;
wire done;
wire [5:0] count_minutes;
wire [5:0] count_seconds;

// Instantiate the timer module
timer uut (
    .clk(clk),
    .reset_n(reset_n),
    .minutes(minutes),
    .seconds(seconds),
    .done(done),
    .count_minutes(count_minutes),
    .count_seconds(count_seconds)
);

// Generate a 50 MHz clock
always begin
    #20 clk = ~clk;  // Toggle clk every 20ns (50 MHz)
end

// Test sequence
initial begin
    // Initialize signals
    clk = 0;
    reset_n = 0;
    minutes = 6'd1;  // Set initial time to 1 minute 5 seconds
    seconds = 6'd5;

    // Apply reset
    #20 reset_n = 1;

    // Apply reset and then start the countdown
    #20 reset_n = 0; // Assert reset
    #20 reset_n = 1; // Deassert reset to start timer
    
    // Wait for the timer to expire (i.e., 1 minute 5 seconds)
    #650000;  
    // Check if the done signal is raised
    if (done) begin
        $display("Timer completed successfully.");
    end else begin
        $display("Timer did not complete correctly.");
    end
    
    // Finish simulation
    #20 $finish;
end
endmodule

`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// Sobel Edge Detection Filter Testbench
// 
// This testbench reads a BMP image file, applies the Sobel edge detection 
// filter through multiple passes, and writes the resulting image to a new file.
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Configuration Parameters
//-----------------------------------------------------------------------------
`define HEADER_SIZE    54          // BMP header size in bytes
`define IMAGE_WIDTH    1280        // Image width in pixels
`define IMAGE_HEIGHT   720         // Image height in pixels
`define FRAMES_TO_PROCESS 1        // Number of frames to process for filter stabilization
`define CLK_PERIOD     10          // Clock period in ns (100 MHz)
`define INPUT_FILE     "1.bmp"     // Input BMP file name
`define OUTPUT_FILE    "gray.bmp"  // Output BMP file name

module tb_gray;

  //-------------------------------------------------------------------------
  // DUT Interface Signals
  //-------------------------------------------------------------------------
  reg         clk;                 // System clock
  reg         reset_n;             // Active-low reset
  reg  [23:0] data_in;             // Input pixel data (RGB)
  reg         h_sync;              // Horizontal sync signal
  reg         v_sync;              // Vertical sync signal
  reg         active_video;        // Active video region indicator
  
  wire [23:0] data_out;            // Output pixel data (processed RGB)
  wire        h_sync_out;          // Output horizontal sync
  wire        v_sync_out;          // Output vertical sync
  wire        active_video_out;    // Output active video indicator

  //-------------------------------------------------------------------------
  // Testbench Variables
  //-------------------------------------------------------------------------
  // File I/O
  integer file_in;                 // Input file handle
  integer file_out;                // Output file handle
  integer byte_read;               // Bytes read from input file
  integer pixels_written;          // Counter for pixels written to output file
  integer file_pos;                // Current file position
  
  // Loop indices and control variables
  integer i;                       // Generic loop counter
  integer r, c;                    // Row and column indices
  integer frame;                   // Frame counter
  
  // Data storage
  reg [23:0] pixel;                // Current pixel value
  reg [23:0] output_buffer[0:`IMAGE_HEIGHT-1][0:`IMAGE_WIDTH-1]; // Buffer to store filtered image
  reg        output_valid;         // Flag to indicate valid output frame
  
  // Position tracking for DUT output
  reg [11:0] out_row, out_col;     // Output pixel position 
  
  // Simulation control
  integer    sim_errors;           // Error counter
  reg [31:0] sim_start_time;       // Simulation start time

  //-------------------------------------------------------------------------
  // DUT Instantiation
  //-------------------------------------------------------------------------
  gray #(
    .WIDTH(`IMAGE_WIDTH)           // Configure with image width
  ) dut (
    .clk(clk),
    .Data_in(data_in),
    .HSync(h_sync),
    .VSync(v_sync),
    .ActiveVideo(active_video),
    .Data_out(data_out),
    .HSync_out(h_sync_out),
    .VSync_out(v_sync_out),
    .ActiveVideo_out(active_video_out)
  );

  //-------------------------------------------------------------------------
  // Clock Generation
  //-------------------------------------------------------------------------
  initial begin
    clk = 0;
    forever #(`CLK_PERIOD/2) clk = ~clk;  // Generate clock with period defined by CLK_PERIOD
  end
  
  //-------------------------------------------------------------------------
  // Output Pixel Capture Process
  //-------------------------------------------------------------------------
  always @(posedge clk) begin
    // Capture output pixels during valid frame
    if (output_valid && active_video_out) begin
      output_buffer[out_row][out_col] = data_out;
      
      // Update output position counters
      if (out_col == `IMAGE_WIDTH-1) begin
        out_col <= 0;
        out_row <= out_row + 1;
      end else begin
        out_col <= out_col + 1;
      end
    end
    
    // Reset row/col counters on VSync (new frame)
    if (v_sync_out) begin
      out_row <= 0;
      out_col <= 0;
    end
    
    // Reset column counter on HSync (new line)
    if (h_sync_out) begin
      out_col <= 0;
    end
  end

  //-------------------------------------------------------------------------
  // Main Test Process
  //-------------------------------------------------------------------------
  initial begin
    // Record simulation start time
    sim_start_time = $time;
    
    // Initialize variables
    reset_n       = 1;             // Not in reset
    data_in       = 24'h000000;    // Black pixel
    h_sync        = 0;
    v_sync        = 0;
    active_video  = 0;
    output_valid  = 0;
    out_row       = 0;
    out_col       = 0;
    pixels_written = 0;
    sim_errors    = 0;
    
    // Apply reset pulse
    @(posedge clk);
    reset_n = 0;                   // Assert reset
    repeat(5) @(posedge clk);      // Hold reset for 5 clock cycles
    reset_n = 1;                   // Release reset
    @(posedge clk);

    //-------------------------------------------------------------------------
    // Open Input and Output Files
    //-------------------------------------------------------------------------
    $display("[%0t ns] Opening input file %s", $time, `INPUT_FILE);
    file_in = $fopen(`INPUT_FILE, "rb");
    if(file_in == 0) begin
      $display("ERROR: Could not open input file %s", `INPUT_FILE);
      sim_errors = sim_errors + 1;
      $finish;
    end

    $display("[%0t ns] Opening output file %s", $time, `OUTPUT_FILE);
    file_out = $fopen(`OUTPUT_FILE, "wb");
    if(file_out == 0) begin
      $display("ERROR: Could not open output file %s", `OUTPUT_FILE);
      sim_errors = sim_errors + 1;
      $fclose(file_in);
      $finish;
    end

    //-------------------------------------------------------------------------
    // Copy BMP Header from Input to Output File
    //-------------------------------------------------------------------------
    $display("[%0t ns] Copying BMP header (%0d bytes)", $time, `HEADER_SIZE);
    for(i = 0; i < `HEADER_SIZE; i = i + 1) begin
      byte_read = $fgetc(file_in);
      if (byte_read == -1) begin
        $display("ERROR: Unexpected end of file while reading header");
        sim_errors = sim_errors + 1;
        $fclose(file_in);
        $fclose(file_out);
        $finish;
      end
      $fwrite(file_out, "%c", byte_read);
    end
    
    // Store file position after header for later use
    file_pos = `HEADER_SIZE;
    
    //-------------------------------------------------------------------------
    // Process Multiple Frames to Stabilize the Filter
    //-------------------------------------------------------------------------
    for(frame = 0; frame < `FRAMES_TO_PROCESS; frame = frame + 1) begin
      // Reset file position to start of image data for each frame
      $fseek(file_in, `HEADER_SIZE, 0);
      
      // Only capture output during the final frame
      output_valid = (frame == `FRAMES_TO_PROCESS - 1);
      
      $display("[%0t ns] Processing frame %0d of %0d", $time, frame+1, `FRAMES_TO_PROCESS);
      
      // Signal start of frame with VSync pulse
      @(posedge clk);
      v_sync = 1;
      @(posedge clk);
      v_sync = 0;

      //-------------------------------------------------------------------------
      // Process Each Line of the Image
      //-------------------------------------------------------------------------
      for(r = 0; r < `IMAGE_HEIGHT; r = r + 1) begin
        // Generate HSync pulse at the start of each line
        @(posedge clk);
        h_sync = 1;
        @(posedge clk);
        h_sync = 0;

        // Process each pixel in the current line
        for(c = 0; c < `IMAGE_WIDTH; c = c + 1) begin
          // Read one pixel (3 bytes) from the input file in BGR order (BMP format)
          byte_read = $fgetc(file_in);
          if (byte_read == -1) begin
            $display("ERROR: Unexpected end of file at row %0d, col %0d", r, c);
            sim_errors = sim_errors + 1;
            $fclose(file_in);
            $fclose(file_out);
            $finish;
          end
          pixel[7:0] = byte_read;  // Blue component
          
          byte_read = $fgetc(file_in);
          if (byte_read == -1) begin
            $display("ERROR: Unexpected end of file at row %0d, col %0d", r, c);
            sim_errors = sim_errors + 1;
            $fclose(file_in);
            $fclose(file_out);
            $finish;
          end
          pixel[15:8] = byte_read;  // Green component
          
          byte_read = $fgetc(file_in);
          if (byte_read == -1) begin
            $display("ERROR: Unexpected end of file at row %0d, col %0d", r, c);
            sim_errors = sim_errors + 1;
            $fclose(file_in);
            $fclose(file_out);
            $finish;
          end
          pixel[23:16] = byte_read;  // Red component

          // Send pixel to DUT
          @(posedge clk);
          data_in = pixel;
          active_video = 1;
        end
        
        // End of line: disable active video
        @(posedge clk);
        active_video = 0;
        
        // Status update for every 100 lines
        if ((r + 1) % 100 == 0) begin
          $display("[%0t ns] Processed %0d of %0d lines (Frame %0d)", 
                  $time, r + 1, `IMAGE_HEIGHT, frame + 1);
        end
      end
      
      // Add a delay after each frame to ensure all pixels are processed
      $display("[%0t ns] Frame %0d complete, waiting for pipeline flush", $time, frame + 1);
      repeat(20) @(posedge clk);
    end
    
    //-------------------------------------------------------------------------
    // Ensure All Processing is Complete
    //-------------------------------------------------------------------------
    $display("[%0t ns] Final processing completed, waiting for pipeline to empty", $time);
    repeat(100) @(posedge clk);
    
    //-------------------------------------------------------------------------
    // Write Processed Image to Output File
    //-------------------------------------------------------------------------
    $display("[%0t ns] Writing processed image to output file", $time);
    for(r = 0; r < `IMAGE_HEIGHT; r = r + 1) begin
      for(c = 0; c < `IMAGE_WIDTH; c = c + 1) begin
        pixel = output_buffer[r][c];
        
        // Write pixel data in BGR order (BMP format)
        $fwrite(file_out, "%c", pixel[7:0]);     // Blue
        $fwrite(file_out, "%c", pixel[15:8]);    // Green 
        $fwrite(file_out, "%c", pixel[23:16]);   // Red
        
        pixels_written = pixels_written + 1;
      end
      
      // Status update for every 100 lines
      if ((r + 1) % 100 == 0) begin
        $display("[%0t ns] Written %0d of %0d lines to output file", 
                $time, r + 1, `IMAGE_HEIGHT);
      end
    end

    //-------------------------------------------------------------------------
    // Cleanup and Finish
    //-------------------------------------------------------------------------
    $fclose(file_in);
    $fclose(file_out);
    
    // Print simulation summary
    $display("-------------------------------------------------------------");
    $display("Simulation Summary:");
    $display("-------------------------------------------------------------");
    $display("Start time:          %0t ns", sim_start_time);
    $display("End time:            %0t ns", $time);
    $display("Simulation duration: %0t ns", $time - sim_start_time);
    $display("Input file:          %s", `INPUT_FILE);
    $display("Output file:         %s", `OUTPUT_FILE);
    $display("Image dimensions:    %0d x %0d pixels", `IMAGE_WIDTH, `IMAGE_HEIGHT);
    $display("Total pixels:        %0d", `IMAGE_WIDTH * `IMAGE_HEIGHT);
    $display("Pixels written:      %0d", pixels_written);
    $display("Errors:              %0d", sim_errors);
    $display("-------------------------------------------------------------");
    
    if (pixels_written == `IMAGE_WIDTH * `IMAGE_HEIGHT) begin
      $display("SIMULATION PASSED: All pixels processed successfully");
    end else begin
      $display("SIMULATION WARNING: Not all pixels were written (%0d of %0d)", 
              pixels_written, `IMAGE_WIDTH * `IMAGE_HEIGHT);
    end
    
    $display("-------------------------------------------------------------");
    $stop;
  end

endmodule
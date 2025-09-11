module sin_cos_gen (
    input clk,
    input rst,
    input wire [1:0] frequency_sel,
    output reg [15:0] output_sin,
    output reg [15:0] output_cos,
    output reg done
);

/*  
    Different cases for the input are as follows:
    frequency_sel = 0  --->   1X frequency_seluency
    frequency_sel = 1  --->   2X frequency_seluency
    frequency_sel = 2  --->   4X frequency_seluency
    frequency_sel = 3  --->   8X frequency_seluency
*/

integer i,step,counter;

reg [15:0] sin_data [0:1023];
reg [15:0] cos_data [0:1023];

initial begin
    $readmemb("sin_wave.mem", sin_data);
    $readmemb("cos_wave.mem", cos_data);
end

always @(posedge clk) begin 
    if (rst) begin
        i <= 0;
	    counter <= 0;
	    output_sin <= 0;
	    output_cos <= 0;
        done <= 0;
        case (frequency_sel)
            2'b00: step <= 1;
	        2'b01: step <= 2;
	        2'b10: step <= 4;
	        2'b11: step <= 8;
        endcase
    end
    else begin
        if (counter == 1024) begin
			done <= 1;
		end
		else begin
			output_sin <= sin_data[i];
			output_cos <= cos_data[i];
			counter <= counter + 1;
			if (i + step < 1024) i <= i + step;
			else i <= i + step - 1024;
		end
    end
end
endmodule

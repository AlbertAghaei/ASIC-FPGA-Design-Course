
// Animation

module animation
(CLK_50, // On Board 50 MHz
KEY, // Push Button[3:0]
SW,
VGA_CLK,   // VGA Clock
VGA_HS, // VGA H_SYNC
VGA_VS, // VGA V_SYNC
VGA_BLANK_N, // VGA BLANK
VGA_SYNC, // VGA SYNC
VGA_R,   // VGA Red[9:0]
VGA_G, // VGA Green[9:0]
VGA_B   // VGA Blue[9:0]
);

input CLK_50; // 50 MHz
input [0:0] KEY; // Button[3:0]
input   [17:0]  SW;
output VGA_CLK;   // VGA Clock
output VGA_HS; // VGA H_SYNC
output VGA_VS; // VGA V_SYNC
output VGA_BLANK_N; // VGA BLANK
output VGA_SYNC; // VGA SYNC
output [9:0] VGA_R;   // VGA Red[9:0]
output [9:0] VGA_G; // VGA Green[9:0]
output [9:0] VGA_B;   // VGA Blue[9:0]

wire resetn;
assign resetn = KEY[0];

// Create the color, x, y and writeEn wires that are inputs to the controller.

wire [2:0] colour;
wire writeEn = 1;

// Create an Instance of a VGA controller - there can be only one!
// Define the number of colours as well as the initial background
// image file (.MIF) for the controller.
vga_adapter VGA(
.resetn(resetn),
.clock(CLK_50),
.colour(colour),
.x(x),
.y(y),
.plot(writeEn),
/* Signals for the DAC to drive the monitor. */
.VGA_R(VGA_R),
.VGA_G(VGA_G),
.VGA_B(VGA_B),
.VGA_HS(VGA_HS),
.VGA_VS(VGA_VS),
.VGA_BLANK(VGA_BLANK_N),
.VGA_SYNC(VGA_SYNC),
.VGA_CLK(VGA_CLK));
defparam VGA.RESOLUTION = "160x120";
defparam VGA.MONOCHROME = "FALSE";
defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
defparam VGA.BACKGROUND_IMAGE = " ";

// Put your code here. Your code should produce signals x,y,color and writeEn
// for the VGA controller, in addition to any other functionality your design may require.
parameter IMAGE_FILE = "image.mif";
assign black_colour = 3'b100;
assign gnd = 1'b0;
lab3 my_ram(
.clock(CLK_50),
.data(black_colour),
.address(mem_address),
.wren(gnd),
.q(mem_out) );

defparam my_ram.altsyncram_component.init_file = IMAGE_FILE ;
//defparam my_ram.LPM_WIDTH = 3;
//defparam my_ram.LPM_WIDTHAD = 8;
//defparam my_ram.LPM_INDATA = "REGISTERED";
//defparam my_ram.LPM_ADDRESS_CONTROL = "REGISTERED";
//defparam my_ram.altsyncram_component.outdata_reg_a = "REGISTERED";


wire [2:0] mem_out;

reg [7:0] x;
reg [6:0] y;

reg [7:0] x_initial ;
reg [7:0] y_initioal;
reg [7:0] mem_address ;


wire done_x, done_y, pic_zone;

assign done_x = (x == 8'd159) ;
assign done_y = (y == 7'd119);
assign pic_zone = (x_initial <= x) && (x < x_initial + 16) && (y_initioal <= y) && (y < y_initioal + 16);
assign colour = (pic_zone == 1) ? mem_out : black_colour;
//assign mem_address = pic_zone ? (x-x_initial) + 16 * (y - y_initioal) : 8'd0;
   

always @(posedge CLK_50) begin
if(!resetn) begin
x <= 0;
y <= 0;
end
else begin
x <= x + 1;
if (done_x) begin
x <= 0;
y <= y + 1;
if(done_y) begin
y <= 0;
end
end
end
end

     reg [7:0] x_draw, y_draw;
     //reg [7:0] x_erase, y_erase;
     reg up_x , up_y;
     reg [25:0] counter;

     always @(posedge CLK_50) begin
     if(x_draw>= (160-17) )
      up_x <= 0;
     else if(x_draw==0)
      up_x <= 1;
     if(y_draw>= (120-17) )
      up_y <= 0;
     else if(y_draw==0)
      up_y <= 1;
     end
 
always @(posedge CLK_50) begin
if (!resetn) begin

 x_draw <= 80;
 y_draw <= 70;
end
else begin
if (up_x) begin
counter <= counter + 1;
      if (counter == 5000000) begin
     
      counter <= 0;
x_draw <= x_draw + 1 ;
end
     end
     else if(!up_x) begin
 counter <= counter + 1;
      if (counter == 5000000) begin
     
      counter <= 0;
     x_draw <= x_draw - 1 ;
     end
 end
     if (up_y) begin
 counter <= counter + 1;
      if (counter == 5000000) begin
     
      counter <= 0;
y_draw <= y_draw + 1 ;
     end
 end
     else if(!up_y) begin
 counter <= counter + 1;
      if (counter == 5000000) begin
     
      counter <= 0;
y_draw <= y_draw - 1 ;
end
     end
end
end

     always @(posedge CLK_50) begin
     
      //counter <= counter + 1;
      //if (counter == 5000000) begin
     
      //counter <= 0;
      x_initial <= x_draw;
      y_initioal <= y_draw;
     
 if(pic_zone)
 mem_address <= (x-x_initial) + 16 * (y - y_initioal);
 else
 mem_address <= 8'd0;
 

      end

     //end




endmodule

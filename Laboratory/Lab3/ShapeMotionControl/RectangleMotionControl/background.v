// Background image display

module background
(
CLK_50, // On Board 50 MHz
KEY, // Push Button[3:0]
SW, // Push Button[0:0]
VGA_CLK,   // VGA Clock
VGA_HS, // VGA H_SYNC
VGA_VS, // VGA V_SYNC
VGA_BLANK_N, // VGA BLANK
VGA_SYNC, // VGA SYNC
VGA_R,   // VGA Red[9:0]
VGA_G, // VGA Green[9:0]
VGA_B   // VGA Blue[9:0]
);

parameter reset_x_center = 8'd80, reset_y_center = 7'd60, circle_radius2 = 18'd225,
circle_color = 3'b100, back_color = 3'b000, circle_radius = 8'd15;

input wire CLK_50; // 50 MHz
input wire [3:0] KEY; // Button[0:0]
input wire [3:0] SW; // Button[0:0]
output wire VGA_CLK;   // VGA Clock
output wire VGA_HS; // VGA H_SYNC
output wire VGA_VS; // VGA V_SYNC
output wire VGA_BLANK_N; // VGA BLANK
output wire VGA_SYNC; // VGA SYNC
output wire [9:0] VGA_R;   // VGA Red[9:0]
output wire [9:0] VGA_G; // VGA Green[9:0]
output wire [9:0] VGA_B;   // VGA Blue[9:0]

wire resetn, plot;
wire [2:0] color;
wire done;
reg [7:0] x;
reg [6:0] y;
reg [7:0] x_center;
reg [6:0] y_center;

wire signed [8:0] dx = $signed({1'b0, x}) - $signed({1'b0, x_center});
wire signed [7:0] dy = $signed({1'b0, y}) - $signed({1'b0, y_center});

wire [17:0] dx2 = dx * dx;
wire [16:0] dy2 = dy * dy;
   reg  [10:0] counter;
wire left = SW[0];
wire right = SW[1];
wire up = SW[2];
wire down = SW[3];
// Further assignments go here...
assign resetn = KEY[0];
assign done_x = (x == 8'd159);
    assign done_y = (y == 7'd119);
assign color = (dx2 + dy2 <= circle_radius2) ? circle_color : back_color;
assign plot = 1;

always @(posedge CLK_50)
begin
if (!resetn) begin
x_center <= reset_x_center;
y_center <= reset_y_center;
x <= 0;
y <= 0;
end
else if (done_y==0) begin
if (done_x==1) begin
x <= 0;
y <= y + 1;
end
x <= x + 1;
end
else begin
if (left && (x_center > circle_radius+1)) begin
if(counter == 500) begin
  counter <= 0;
x_center <= x_center - 1;
end
else counter <= counter + 1;
end else
if (right && (x_center + circle_radius < 8'd159)) begin
if(counter == 500) begin
  counter <= 0;
x_center <= x_center + 1;
end
else counter <= counter + 1;
end else
if (up && (y_center > circle_radius+1)) begin
if(counter == 500) begin
  counter <= 0;
y_center <= y_center - 1;
end
else counter <= counter + 1;
end else
if (down && (y_center + circle_radius < 8'd119)) begin
if(counter == 500) begin
  counter <= 0;
y_center <= y_center + 1;
end
else counter <= counter + 1;
end

if (|SW[3:0]) begin
x <= 0;
y <= 0;

end
end
end



// Define the number of colours as well as the initial background
// image file (.MIF) for the controller.
vga_adapter VGA(
.resetn(resetn),
.clock(CLK_50),
.colour(color),
.x(x),
.y(y),
.plot(plot),
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
defparam VGA.BACKGROUND_IMAGE = "display.mif";

endmodule

typedef enum logic [1:0] { IDLE,SEEN_1,SEEN_10,SEEN_101 } state_t;

module sequence_detector_1011 (
input wire logic clk,
input wire logic rst,
input wire logic in,
output var  logic detected
);

state_t CS,NS;

always_comb begin
  NS = CS;
  case(CS)
    IDLE      :  NS = in ? SEEN_1 : IDLE;
    SEEN_1    :  NS = in ? SEEN_1 : SEEN_10;
    SEEN_10   :  NS = in ? SEEN_101 : IDLE;
    SEEN_101  :  NS = in ? SEEN_1 : SEEN_10;
  endcase
 end
 
always_ff @(posedge clk or negedge rst) begin
  if(rst == 0)
   CS <= IDLE;
  else
   CS <= NS;
 end
 
 assign detected = (CS == SEEN_101 && in);
 
 endmodule
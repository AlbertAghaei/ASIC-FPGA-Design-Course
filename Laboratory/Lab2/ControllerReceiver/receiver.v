module receiver(
    input clk,
    input Rx,
    input rst,
    output reg [2:0]key
);

parameter idle=4'b0000 ,Start=4'b0001,SC=4'b0010,TC1=4'b0111,TC2=4'b1000,C=4'b1001,T=4'b1010,S1=4'b1011,S2=4'b1100,C1=4'b1101,C2=4'b1110;
reg [3:0] CS , NS;

always @(*)
begin
    case(CS)
    idle: if(Rx) NS=idle;
          else NS=Start;
    Start: if(Rx) NS=SC;
          else NS=TC1;
    SC: if(Rx) NS=C1;
          else NS=S1;
    C1: if(Rx) NS=idle;
          else NS=C2;
    C2:  NS=idle;
    S1: if(Rx) NS=S2;
          else NS=idle;
    S2:  NS=idle; 
    TC1: if(Rx) NS=TC2;
          else NS=idle;
    TC2: if(Rx) NS=C;
          else NS=T;
    C:  NS=idle;
    T:  NS=idle;
   //default: NS=idle;
   endcase
     
end
always@(posedge clk)  begin
    if(rst)
       CS<=idle;
       else 
       CS<=NS;
	 case(CS) 
	     Start: key<=3'b111;
        C2: key<=3'b011;
        S2: key<=3'b001;
        C:  key<=3'b100;
        T:  key<=3'b010;
		 // default : key<=3'b000;
    endcase
end

//always @(*) begin
  //  case(CS) 
	 //    Start: key=3'b111;
      //  C2: key=3'b011;
        //S2: key=3'b001;
        //C:  key=3'b100;
        //T:  key=3'b010;
		  //default : key=3'b000;
    //endcase
//end
endmodule

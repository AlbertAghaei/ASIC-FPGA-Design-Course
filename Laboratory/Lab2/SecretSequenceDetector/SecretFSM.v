module SecretFSM (
    input clk,          // Clock signal
    input rst,          // Reset signal
    input [2:0] key,    // 3-bit input representing button presses
    output reg trigger  // Output signal to reset the timer
);

    parameter start=4'b0001,cross1=4'b0010,Circle=4'b0011,Square=4'b0100,Triangle=4'b0101,cross2=4'b0110;

    reg [3:0] CS, NS; // Define state registers

    // State transition
    always @(posedge clk) begin
        if (rst)
            CS <= start;
        else
            CS <= NS;
    end

    // Next state logic
    always @(*) begin
        case (CS)
           start:
           begin
            if(key==3'b000)
            begin
            NS= start;
            trigger=1'b0;
            end 
            else if (key==3'b001) 
            begin
            NS= start;
            trigger=1'b0;
            end 
            else if (key==3'b010)
            begin
            NS= start;
            trigger=1'b0;
            end  
            else if (key==3'b011)
            begin
            NS= start;
            trigger=1'b0;
            end  
            else if (key==3'b100)
            begin
            NS= cross1;
            trigger=1'b0;
            end 
            else 
            begin
            NS= start;
            trigger=1'b0;
            end 
           end
           cross1:
           begin
            if(key==3'b000)
            begin
            NS= cross1;
            trigger=1'b0;
            end  
            else if (key==3'b001)
            begin
            NS= start;
            trigger=1'b0;
            end 
            else if (key==3'b010) 
            begin
            NS= Triangle;
            trigger=1'b0;
            end 
            else if (key==3'b011)
            begin
            NS= start;
            trigger=1'b0;
            end 
            else if (key==3'b100)
            begin
            NS= cross1;
            trigger=1'b0;
            end 
            else 
            begin
            NS= start;
            trigger=1'b0;
            end
            
           end
           Triangle:
           begin
            if(key==3'b000) 
            begin
            NS= Triangle;
            trigger=1'b0;
            end
            else if (key==3'b001)
            begin
            NS= Square;
            trigger=1'b0;
            end 
            else if (key==3'b010)
            begin
            NS= Triangle;
            trigger=1'b0;
            end 
            else if (key==3'b011)
            begin
            NS= start;
            trigger=1'b0;
            end 
            else if (key==3'b100)
            begin
            NS= cross1;
            trigger=1'b0;
            end 
            else
            begin
            NS= start;
            trigger=1'b0;
            end 
           end
           Square:
           begin
            if(key==3'b000) 
            begin
            NS= Square;
            trigger=1'b0;
            end 
            else if (key==3'b001)
            begin
            NS= Square;
            trigger=1'b0;
            end 
            else if (key==3'b010)
            begin
            NS= Triangle;
            trigger=1'b0;
            end 
            else if (key==3'b011)
            begin
            NS= start;
            trigger=1'b0;
            end 
            else if (key==3'b100)
            begin
            NS= cross2;
            trigger=1'b0;
            end 
            else
            begin
            NS= start;
            trigger=1'b0;
            end 
           end
           cross2:
           begin
            if(key==3'b000)
            begin
            NS= cross2;
            trigger=1'b0;
            end 
            else if (key==3'b001)
            begin
            NS= Square;
            trigger=1'b0;
            end 
            else if (key==3'b010)
            begin
            NS= Triangle;
            trigger=1'b0;
            end 
            else if (key==3'b011)
            begin
            NS= Circle;
            trigger=1'b0;
            end 
            else if (key==3'b100)
            begin
            NS= cross2;
            trigger=1'b0;
            end 
            else
            begin
            NS= start;
            trigger=1'b0;
            end 
           end
           Circle:
            begin
             NS= start;
             trigger=1'b1;
            end
            default:
            begin
             NS= start;
             trigger=1'b1;
            end
        endcase
    end

    // Output logic
   // always @(posedge clk or posedge rst) begin
     //   if (rst)
       //     trigger <= 1'b0;
        //else if (state == S5)
          //  trigger <= 1'b1; // Set trigger when full sequence is detected
        //else
          //  trigger <= 1'b0;
    //end

endmodule

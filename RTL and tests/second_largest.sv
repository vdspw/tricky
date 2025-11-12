/* -----------Second Largest Number Finder----------- 

    [clokced seq unisinded nos.]---->| 2nd largest number finder |                 
    [clk]--------------------------->|                           |  ------> [dout]             
    [reset_n]----------------------->|                           |
    [din]--------------------------->|                           |
                        +------------------------------------------+



*/
module model #(parameter
  DATA_WIDTH = 32
) (
  input clk,
  input resetn,
  input [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
);

logic [DATA_WIDTH-1:0] largest, second_largest;

    always @(posedge clk ) begin
        if (~resetn) begin
            largest        <= '0;
            second_largest <= '0;
        end 
        else if ((din > largest && din > second_largest))begin
          largest <=  din;
          second_largest <= largest;
        end
        else if(din > second_largest)begin
          second_largest <= din;
        end
    end

    assign dout = second_largest;

endmodule
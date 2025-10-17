// Fiar arbiter.
// Design description -> has 2 requests as inputs onr req is going to 
// granted at a time.
// if both requests are high they recive grants aleternatively.

module arbiter (
  input logic clk,
  input logic reset,
  input logic req_1,
  input logic req_2,
  output logic grant_1,
  output logic grant_2
);
  
  logic toggle; // stores the last granted req
  
  always_ff@(posedge clk or posedge reset)begin
    if(reset)begin
      toggle <= 1'b0;
      grant_1<= 1'b0;
      grant_2<= 1'b0;
    end
    else begin
      grant_1 <= 1'b0;
      grant_2 <= 1'b0;
      
      if(req_1 & req_2)begin
        if(toggle == 1'b0)begin
          grant_1 <= 1'b1;
          toggle <= 1'b1;
          end else begin
          grant_2 <= 1'b1;
          toggle <= 1'b0;
          end
      end
      else if(req_1)
        grant_1 <= 1'b1;
      else
        grant_2 <= 1'b1;
    end
  end
  
endmodule

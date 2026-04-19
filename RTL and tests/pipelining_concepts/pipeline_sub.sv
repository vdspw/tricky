// pipeline RTL 
// y = |a -b|
// stage 1 --> a-b , stage 2 --> if negative negate it 

module pipeline_two (
  input logic signed [7:0] a,b,
  input logic clk,
  output logic [7:0] y
);
  
  //signed subtraction widened to 9 bits to avoid overflow
  logic signed [8:0] diff;
  
  always_ff@(posedge clk) begin
    diff <= a -b;
  end
  
  //absolute value 
  always_ff@(posedge clk)begin
    y <= (diff < 0) ? -diff : diff;
  end
    
 
  
endmodule

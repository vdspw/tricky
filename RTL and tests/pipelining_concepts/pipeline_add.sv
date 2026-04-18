// pipelining the addition equation.
// y = a + b + c + d + e
// stage 1 -> (a + b) , stage 2 -> (c + d) , parallely caary e

module pipeline_one (
  input logic [7:0] a,b,c,d,e,
  input logic clk,
  output logic [10:0] y
);
  
  // stage 1 (a+b)
  logic [7:0]e_d_1;
  logic [8:0] sum_1;
  logic [8:0] sum_2;
  
  always_ff@(posedge clk) begin
    sum_1 <= a + b;
    sum_2 <= c + d;
    e_d_1 <= e;
  end
  
  logic [9:0] sum_3;
  logic [7:0] e_d_2;
  //stage_2
  always_ff@(posedge clk)begin
    sum_3 <= sum_1 + sum_2;
    e_d_2 <= e_d_1;
  end
  
  always_ff@(posedge clk)begin
    y <= sum_3 + e_d_2;
  end
  
endmodule


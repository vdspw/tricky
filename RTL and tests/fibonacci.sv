module fibonacci #(parameter width = 10) (
  input wire clk,
  input reset_n,
  output [width -1 :0] out
);
  
  reg [width - 1:0] a,b;
  assign out = a+b;
  
  always@(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
      a <= {width{1'b0}};
      b <= 1; // on the first cycle the inputs are a =0, b= 1;
    end else begin
      a <= b;
      b <= out;
  end
  end
endmodule

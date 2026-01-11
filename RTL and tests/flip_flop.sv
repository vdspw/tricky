// Modelling a flip_flop in RTL //
/* edge sensitive */

module flip_flop ( input logic clk,
                   input logic reset,
                   input logic in,
                   input logic en,
                  output logic d_out );
  
  always_ff@(posedge clk or posedge reset) begin //async reset
    if(reset) begin
      d_out <= 1'b0;
    end else if(en) begin
      d_out <= in;
    end
  end
  
endmodule

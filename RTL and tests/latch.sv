// Latch RTL model //
/* its a combinational logic -- level sensitive element */

module latch ( input en, input rst, input in , output l_out);
  
  logic l_out_reg;
  
  always_comb begin
    if(rst) begin
      l_out_reg = 1'b0;
    end else if (en)begin
      l_out_reg = 1'b1;
    end else begin
      l_out_reg = l_out;
    end
  end
  
  assign l_out = l_out_reg;
endmodule

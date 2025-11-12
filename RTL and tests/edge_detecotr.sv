module model (
  input clk,
  input resetn,
  input din,
  output dout
);

reg prev_din;
reg out;

always@(posedge clk or negedge resetn) begin
    if(~resetn) begin
        prev_din <= 1'b0;
        out <= 1'b0;
    end
    else begin
        prev_din <= din;
        out <= din & ~prev_din;
    end
end


assign dout = out;

endmodule

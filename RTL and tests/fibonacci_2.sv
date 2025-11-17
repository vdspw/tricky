module model #(parameter
  DATA_WIDTH=32
) (
  input clk,
  input resetn,
  output logic [DATA_WIDTH-1:0] out
);

logic [DATA_WIDTH-1:0] cur_val,prev_val;

always@(posedge clk)begin
 if(!resetn)begin
   cur_val <= 1;
   prev_val <= 0;
 end
 else begin
   cur_val <= cur_val + prev_val;
   prev_val <= cur_val;
 end
end

assign out = cur_val;

endmodule

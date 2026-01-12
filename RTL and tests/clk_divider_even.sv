module model (
  input clk,
  input resetn,
  output logic div2,
  output logic div4,
  output logic div6
);

logic count2;
logic [1:0] count4;
logic [2:0] count6;

always_ff@(posedge clk)begin
  if(!resetn)begin
    count2 <= 'b0;
    count4 <= 'b0;
    count6 <= 'b0;
  end else begin
    count2 <= count2 + 1;
    count4 <= count4 + 1;
    count6 <= (count6 + 1) % 6;
  end
end

assign div2 = (count2 == 1);
assign div4 = (count4 == 1) || (count4 == 2);
assign div6 = (count6 == 1) || (count6 == 2) || (count6 ==3);

endmodule

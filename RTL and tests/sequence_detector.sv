module model (
  input clk,
  input resetn,
  input din,
  output logic dout
);

parameter S0 = 0, S1 = 1, S10 = 2, S101 = 3, S1010 = 4;
logic [2:0] state;

always@(posedge clk)begin
  if(!resetn)begin
    state <= S0;
  end else begin
    case(state)
      S0 : state <= (din ?S1:S0); //detect 1
      S1 : state <= (din ?S1:S10); //detect 0
      S10 : state <= (din ?S101:S0); //detect 1
      S101: state <= (din ?S1 : S1010); //detect 0
      S1010:state <= (din ?S101:S0); //complete
    endcase
    end
  end
  assign dout = (state === S1010 ? 1:0);
endmodule

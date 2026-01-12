module model #(parameter
  DATA_WIDTH = 32
) (
  input  [DATA_WIDTH-1:0] din,
  output logic [$clog2(DATA_WIDTH):0] dout
);

always_comb begin
  dout = 0;

  //if input is all 0's
  if(din == 0)begin
    dout = DATA_WIDTH;
  end else begin
    for(int i=0; i < DATA_WIDTH;i++)begin
      if(din[i]==0)begin
        dout = dout + 1;
      end else 
      break;
    end
  end

end
endmodule

module model #(parameter
  DATA_WIDTH=32
) (
  input  [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
);

genvar i;
generate 
  for(i=0; i<DATA_WIDTH;i++)begin
    assign dout[i] = din [DATA_WIDTH-1 -i];
  end
endgenerate
endmodule

module model #(parameter
  DATA_WIDTH=32
) (
  input [DATA_WIDTH-1:0] din,
  output logic dout
);

int counter;
logic dout_ff;

always_comb begin
  dout_ff = 1'b1; // assuming its already proved
  for(counter = 0 ; counter < DATA_WIDTH/2 ; counter++)begin
   dout_ff = dout_ff & din[DATA_WIDTH - counter] == din[counter];
  end
  
end

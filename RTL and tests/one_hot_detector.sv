module model #(parameter
  DATA_WIDTH = 32
) (
  input  [DATA_WIDTH-1:0] din,
  output logic onehot
);

logic count; // to keep track of ones

always_comb begin
  count = 0;
  for(int i = 0; i< DATA_WIDTH ; i++)begin
    count = count + din[i];
  end
end

assign onehot = count;

endmodule

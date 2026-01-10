//Gray to Binary RTL //

module g_to_b #(parameter WIDTH = 4)
  ( input logic [ WIDTH - 1:0] g_in,
   output logic [WIDTH -1 :0] b_out
  );
  
  always_comb begin
     b_out [WIDTH - 1] = g_in[WIDTH -1]; // MSB unchanged
    
    for(int i = WIDTH - 2; i>=0 ; i--)begin //for lower bits
      b_out[i] = g_in[i] ^ b_out[i+1];
    end
    
  end
  
endmodule
  

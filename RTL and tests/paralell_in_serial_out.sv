/*---- PARALLEL -IN - SERIAL -OUT SHIFT REGISTER ----*/
/*
      +---------------+
      | piso_shift_reg | <---clk,resetn,[15:0] din
      |                | <----- din_en
      |                |
      |                |
      |                |-------> dout
      |                |
      +---------------+
*/
module par_in_ser_out (
    input clk,
    input rst_n,
    input [15:0] din,
    input din_en,
    output logic dout
);

logic [15:0] temp; // Temporary register to hold input data

always@(posedge clk)begin
    if(!resetn)begin
        temp <= 16'b0;
        
    end else if (din_en) begin
        temp <=din; // Load input data into temporary register
    end else begin
          temp <= {1'b0,temp[15:1]}; // Shift right by 1 bit  temp <= temp >> 1;
    end
end
assign dout = temp[0]; // Output the least significant bit

endmodule

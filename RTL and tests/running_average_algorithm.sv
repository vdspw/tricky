// Running average algorithm 

module running_avg_four_inputs ( input logic clk,
                                input logic rst_n,
                                input logic x_valid,
                                input logic [7:0] x_in,
                                output logic y_valid,
                                output logic [7:0] y_out);
  
  // pipeline regs
  logic [7:0] shift_reg [3:0];
  logic [9:0]  sum; // requires extra bits to prevent overflow 
  logic [7:0]  avg;
  
  //sequential
  always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      shift_reg[3] <= '0;
      shift_reg[2] <= '0;
      shift_reg[1] <= '0;
      shift_reg[0] <= '0;
      y_out <= '0;
      y_valid <= '0;
    end else begin
      if(x_valid) begin
        shift_reg[3] <= shift_reg[2]; //on valid start shifting 
        shift_reg[2] <= shift_reg[1];
        shift_reg[1] <= shift_reg[0];
        shift_reg[0] <= x_in;      // the latest value is onto index[0].
      end
      y_valid <= x_valid;
  end
  end
    
  always_comb begin
    sum = shift_reg [3] + shift_reg[2] + shift_reg[1] + shift_reg[0];
    avg = (sum >> 2); //or sum[9:2] discard the lower 2 bits
  end
    
    assign y_out = avg;
endmodule

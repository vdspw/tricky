// accumilator with clear

module acc_with_clr (  input logic clk,
                     input logic rst_n,
                     input logic x_valid,
                     input logic [7:0] x_in,
                     input logic clear,
                     output logic y_valid,
                     output logic [15:0] y_out );
  //pipeline reg
  logic [15:0]acc;
  logic [15:0] next_acc;
  
 
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        acc     <= '0;
        y_valid <= '0;
    end
    else begin
        acc     <= next_acc;
        y_valid <= x_valid;
    end
end
  
  always_comb begin
    if(clear)begin
      next_acc = '0;
    end
    else if(x_valid)
      next_acc = acc + x_in;
    else
      next_acc = acc;
  end
  
  assign y_out = acc;
endmodule

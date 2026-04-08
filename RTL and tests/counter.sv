// counter 

module counter #(parameter WIDTH = 8,
                 parameter MAX = 255 )
  ( input logic clk,
    input logic rst_n,
   input logic en,
   input logic load,
   input logic [WIDTH -1 :0] count_in,
   output logic [WIDTH -1 :0] count_out,
   output logic max_reached,
   output logic overflow );
  
  //internal registers
  logic was_max ; // remebers if last cycle was max with en
  
  always_ff@(posedge clk or negedge rst_n) begin 
    if(!rst_n)begin
      count_out <= '0;
      was_max <= '0;
  end else begin
   	  // priority : load -> en -> hold
    if(load)
      count_out <= count_in; //latch the value immediately
    else if(en)
      if(count_out == MAX)
        count_out <= '0;
     else
      count_out <= count_out + 1'b1; // increment the count
      was_max <= (count_out == MAX) && en;
  end
    
  end
  
  assign max_reached = (count_out == MAX[WIDTH-1:0]);
  assign overflow = was_max;

  
    
    
endmodule

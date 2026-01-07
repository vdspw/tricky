// fixed proirity arbiter -- design code //
/* the LSB gets the highest prioirty */
module fixed_priority_arbiter #(parameter WIDTH = 4)
  ( input logic [WIDTH - 1 : 0] req,
   output logic [WIDTH - 1 : 0] grant );
  
  always_comb begin
    grant = '0; //default
    
    if(req[0])begin
      grant[0] = 1'b1;
    end else if(req[1])begin
      grant[1] = 1'b1;
    end else if (req[2])begin
      grant[2] = 1'b1;
    end else if (req[3])begin
      grant[3] = 1'b1;
    end
  end
endmodule

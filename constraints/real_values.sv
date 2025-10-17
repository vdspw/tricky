// Random real values between 3.5 and 5.5
class addr_gen;
  
  randc int rel_val;
  real val;
  
  constraint c1_real_value{	rel_val inside {[35:55]};}
  
  function void post_randomize();
    val = rel_val/10.0;
    $display("The real value is %0f", val);
  endfunction
  
endclass
      
module tb;
  
  addr_gen ag;
  
  initial begin
    ag = new();
    repeat(10) begin
      ag.randomize();
     // ag.display();
    end
  end
  
endmodule

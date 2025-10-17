// Gen 16 bit address with exactly 9 1's and no consecutive 111 or 000.
class addr_gen;
  
  rand bit [15:0] addr; // 16 bit address.
  
  constraint c1_9ones { $countones(addr)==9; }
 
  constraint c2_consec {
    foreach(addr[i]) {
      if(i<14) {
        !(addr[i]==addr[i+1] && addr[i+1]==addr[i+2]);  
      }
    }
  }  
       
  function void display();
    $display("Address is %0b and ones count is %0d", addr, $countones(addr));
  endfunction
  
endclass
      
module tb;
  
  addr_gen ag;
  
  initial begin
    ag = new();
    repeat(10) begin
      ag.randomize();
      ag.display();
    end
  end
  
endmodule

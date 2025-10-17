// address generator of 4kB alligned addrs.

class addr_gen;
  
  rand int unsigned addr;
  
  constraint c1_addr { addr%4096 ==0;}
  constraint c1_range { addr inside {[4096: 32768]};}
  
  function void display();
    $display("Address is %0d",addr);
  endfunction
  
endclass

module tb;
  
  addr_gen ag;
  
  initial begin
    ag = new();
    repeat(5)begin
    ag.randomize();
    ag.display();
  end
  end
  
endmodule

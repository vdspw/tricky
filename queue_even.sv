//a queue of size 5 containing even numbers only
//

class even_q;
  
  rand bit[7:0] q[$]; //dynamix queue
  
  constraint c1 {
    q.size() == 5; // size is 5.
    foreach (q[i]) q[i] %2 ==0 ; // even number
  }
  
endclass

module tb;
  
  even_q eq = new();
  initial begin
    eq.randomize();
    $display(" Even Queue : %0p ", eq.q);
  end
endmodule

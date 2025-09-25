// Generate a queue from 0 to 9 with all unique values.

class double_queue;
  
  rand bit [3:0] q[$]; // dynamic queue.
  
  constraint c1 {
    
    q.size() == 10;
   
    foreach (q[i]) q[i] inside {[0:9]};
    unique {q};
  }
  
endclass

module tb;
  
  double_queue obj = new();
  
  initial begin
    repeat(5) begin
    obj.randomize();
    $display("exp queue : %0p", obj.q);
    end
  end
  
endmodule

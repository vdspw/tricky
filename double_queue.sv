// constraint such that each queue element is double
// the previous one

class double_queue;
  
  rand bit [7:0] q[5];
  
  constraint c1 {
    
   // q[0] == 1;
    foreach (q[i]) if (i >0) q[i] == 2* q[i-1];
  }
  
endclass

module tb;
  
  double_queue obj = new();
  
  initial begin
    repeat(2) begin
    obj.randomize();
    $display("exp queue : %0p", obj.q);
    end
  end
  
endmodule

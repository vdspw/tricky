// Write a constraint to randomize values divisible by 3 and
// in range 30 to 90

class div_3;
  rand bit [7:0] a; // A should be divisible by 3
  
  constraint c1 {
    a inside {[30:90]};
    a % 3 == 0;
    
  }
  
endclass

module tb;
  
  div_3 d = new();
  
  initial begin
    repeat(5)begin
      d.randomize();
      $display(" A is %0d ", d.a);
    end
  end
  
endmodule

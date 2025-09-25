//Write a constraint to ensure sum of two variables is always even.

class even_sum;
  
  rand bit [3:0] a,b; // 2varaibles 
  
  constraint c1 { (a+b) % 2 == 0;}
  
endclass

module tb;
  
  even_sum obj = new();
  int sum =0;
  
  initial begin
    repeat(5) begin
      obj.randomize();
       sum = obj.a + obj.b;
      $display(" A is %0d ; B is %0d ; SUM is %0d ", obj.a, obj.b, sum);
    end
  end
  
endmodule

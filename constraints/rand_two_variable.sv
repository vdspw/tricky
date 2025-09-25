/Constrain two variables such that one is twice the other and
// their sum is less than 50

class sum_less;
  
  rand bit[7:0] a,b; //  2varaibles
  
  constraint twice{
    a == 2*b; // a is 2 times b.
    a + b <50; // sum is less than 50
    
  }
  
endclass

module tb;
  
  sum_less sl = new();
  initial begin
    repeat(10) begin
      sl.randomize();
      $display(" a : %0d and b : %0d and SUM is %0d",sl.a,sl.b, sl.a+sl.b);
    end
  end
endmodule

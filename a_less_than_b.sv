// Create a constraint where one variable is always less than
// another, both in a given range.

class less_than_other;
  rand bit [7:0] a, b; // 2 varaibles
  
  constraint limits {a inside {[10:50]}; 
                     b inside {[20:60]}; }
  constraint order { a < b;}
  
  
  
endclass

module tb;
  less_than_other lto = new();
  
  initial begin
    repeat(5) begin
      lto.randomize();
      $display(" A is %0d ; B is %0d ", lto.a,lto.b);
    end
  end
  
endmodule

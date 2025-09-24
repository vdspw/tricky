// Generate unique array of 5 elements between 1 and 20. 
// even numbers only.

class unique_array ;
  
  rand bit [4:0] arr[5]; // array of 5 elelmts with 5 it each .
  
  constraint c_range {foreach (arr[i]) arr[i] inside{[1:20]};}
  constraint c_unique {unique {arr};}
  constraint c_even { foreach (arr[i]) arr[i] % 2 ==0 ;}
endclass

module tb;
  
  unique_array u = new();
  initial begin
    repeat(2) begin
    u.randomize();
    $display("Unique array : %p",u.arr);
    end
  end
endmodule

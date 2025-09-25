// Generate a 3-element array such that the sum is even and
// elements are between 1 and 10.

class even_sum_array;
  
  rand bit [5:0] arr[3]; // 3 element array 4 bit each.
  
  constraint c1 { 
    foreach (arr[i])  arr[i] inside {[1:10]};
  }
  
  constraint sum {int'( arr.sum()) %2 ==0;
                 }
endclass

module tb;
  
  even_sum_array obj = new();
  //int sum = 0;
  initial begin
    repeat(5) begin
      obj.randomize();
     // sum = obj.arr.sum();
      $display(" Array is %0p , Sum is %0d ", obj.arr, obj.arr.sum());
    end
  end
  
endmodule

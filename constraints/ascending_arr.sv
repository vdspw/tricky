//write a constraint for sorting a 4-element array
// in ascending order

class sort_array;
  
  rand bit[7:0] arr[4]; // array of 4 elements each 8 bit wide.
  
  constraint c_sort {
    arr[0] <= arr[1];
    arr[1] <= arr[2];
    arr[2] <= arr[3];
    
  }
endclass

module tb;
  
  sort_array s = new();
  
  initial begin
    repeat(2)begin
    s.randomize();
    $display(" Sorted array : %0p", s.arr);
  end
  end
endmodule

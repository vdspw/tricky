// constraint such that the sum of array elements
// equals 100

class sum_100;
  
  rand bit [7:0] arr[5]; // 5 elements array each 8 bit.
  int sum =0;
  
  constraint c1 {
    arr[0] + arr[1] + arr[2] +arr[3] +arr[4] ==100 ;
   
  }
  
endclass

module tb;
  
  sum_100 obj = new();
  
  initial begin
    repeat(5)begin
      obj.randomize();
      $display(" Array is %0p , SUM is %0d ", obj.arr, obj.arr[0] + obj.arr[1] +obj.arr[2]+obj.arr[3]+obj.arr[4]);
    end
  end
  
endmodule

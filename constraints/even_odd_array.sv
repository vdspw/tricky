// Define following constraints for a 4-bit dynamic array. 
//The size of the array should be in between 15 to 20. 
//There should be even numbers in odd location and odd numbers in even locations

class eve_odd_arr;
  
  rand bit [3:0] arr[]; // dynamic array each 4 bit wide.
  
  constraint c1 { arr.size() inside {[15:20]};}
  
  constraint c2 { foreach (arr[i])
    if(i%2==0) 
      arr[i] %2 !=2;
    else	
      arr[i] %2 ==0;
                }
  function void display();
    $display("Array elements : ");
    foreach(arr[i])begin
      $display("arr[%0d] = %0d",i,arr[i]);
    end
    $display("The array is %0p",arr);
  endfunction
                  
endclass

module tb;
  
  eve_odd_arr obj;
  
  initial begin
    obj = new();
    obj.randomize();
    obj.display();
  end
  
endmodule

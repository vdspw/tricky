//Randomize a 2D array in SystemVerilog such that each row
// is sorted

class array_2d;
  
  rand bit [7:0] arr[3][4]; // 2D array: 3 rows, 4 columns
  
  constraint c1 {
    foreach (arr[i,j]) { // Iterate over both dimensions
      if (j < 3) { // Compare up to the second-to-last column
        arr[i][j] <= arr[i][j+1]; // Ensure ascending order in each row
      }
    }
  }
  
endclass
      
module tb;
  
  array_2d obj = new();
  
  initial begin
    if (obj.randomize()) begin
      $display("2D array is: %0p\n", obj.arr);
    end else begin
      $display("Randomization failed!");
    end
  end
endmodule

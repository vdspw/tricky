module unique_array;
  class data;
    rand bit [6:0] data[]; // 7-bit array for values 0 to 127
    int array_size = 5;    // Number of elements in the array

    // Constraint to ensure unique values within a range
    constraint data_values {
      // Set the array size
      data.size() == array_size;
      // Ensure each element is within the 7-bit range (0 to 127)
      foreach (data[i]) data[i] inside {[0:127]};
      // Ensure all elements are unique
      foreach (data[i]) {
        foreach (data[j]) {
          if (i < j) data[i] != data[j]; // Compare only upper triangle to avoid redundancy
        }
      }
    }
  endclass : data

  initial begin
    data cl_ob = new(); // Instantiate the class
    if (cl_ob.randomize()) begin
      $display("Randomization successful. Generated array: %p", cl_ob.data);
      foreach (cl_ob.data[i])
        $display("data[%0d] = %0d", i, cl_ob.data[i]);
    end else begin
      $display("Randomization failed!");
    end
  end
endmodule : unique_array

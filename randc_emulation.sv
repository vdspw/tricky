module randc_function;
  class rand_clas;
    rand bit[1:0] myvar; // Random variable to emulate randc (2-bit, values 0 to 3)
    bit [1:0] list[$];   // Queue to track previously used values
    // Constraint to ensure myvar is unique compared to values in list
    constraint cycle { unique {myvar, list}; }

    // Pre-randomization function to reset the list when all values are used
    function void pre_randomize;
      if (list.size() == 4) list = {}; // Clear list when all 4 values are used
    endfunction

    // Post-randomization function to store the generated value
    function void post_randomize;
      list.push_back(myvar); // Add the newly generated value to the list
    endfunction
  endclass : rand_clas

  // Testbench to demonstrate usage
  initial begin
    int x; // Unused variable (likely a placeholder)
    rand_clas rand_class = new(); // Create an instance of the class
    for (int i = 0; i <= 20; i++) begin
      if (rand_class.randomize()) // Randomize the object
        $display("successful: Var=%0d", rand_class.myvar); // Display the result
    end
  end
endmodule : randc_function

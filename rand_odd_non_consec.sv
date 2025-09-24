// Generate values odd numbers only between 5 and 15 , there should be no consecutive odd values.

class rand_odd_non_conse;
  rand bit [3:0] a; // 4-bit variable
  static bit [3:0] prev_a = 15; // Track previous value, initialized to a valid odd number
  
  constraint c1 {
    a inside {[5:15]}; // a inside 5 to 15
    a % 2 == 1; // a should be odd
    // Ensure non-consecutive odd numbers: |a - prev_a| should be at least 4 (skip one odd number)
    (prev_a == 0) || (a != prev_a + 2) && (a != prev_a - 2);
  }
  
  // Update prev_a after randomization
  function void post_randomize();
    prev_a = a;
  endfunction
endclass

module tb;
  rand_odd_non_conse ronc = new();
  
  initial begin
    $display("Generating unique non-consecutive odd numbers between 5 and 15:");
    repeat(10) begin
      if (ronc.randomize()) begin
        $display(" a = %0d ", ronc.a);
      end else begin
        $display("Randomization failed!");
      end
    end
  end
endmodule

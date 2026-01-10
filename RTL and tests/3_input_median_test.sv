`timescale 1ns / 1ps

module tb_sorting;

  // Testbench signals
  logic [7:0] a, b, c;
  logic [7:0] median_actual;
  logic [7:0] median_expected;
  
  // Expected medians for test cases (hardcoded for verification)
  // Test cases: {a,b,c} → expected median
  
  // Instantiate DUT (Device Under Test)
  sorting dut (
    .a(a),
    .b(b),
    .c(c),
    .median(median_actual)
  );
  
  // Task to compute expected median (brute-force sort for reference)
  task compute_expected;
    input [7:0] in1, in2, in3;
    begin
      // Simple sort: find min, max, then median = total - min - max
      logic [7:0] min_val, max_val;
      min_val = (in1 < in2) ? ((in1 < in3) ? in1 : in3) : ((in2 < in3) ? in2 : in3);
      max_val = (in1 > in2) ? ((in1 > in3) ? in1 : in3) : ((in2 > in3) ? in2 : in3);
      median_expected = in1 + in2 + in3 - min_val - max_val;
    end
  endtask
  
  initial begin
    $display("=== Median Finder Testbench ===");
    $display("Time\t a\t b\t c\t Expected Median\t Actual Median\t PASS/FAIL");
    $display("-------------------------------------------------------------");
    
    // Test Case 1: Sorted ascending
    a = 8'd1; b = 8'd2; c = 8'd3;
    compute_expected(a, b, c);
    #1; $display("%0t\t %0d\t %0d\t %0d\t %0d\t\t\t %0d\t\t\t %s",
                  $time, a, b, c, median_expected, median_actual,
                  (median_actual == median_expected) ? "PASS" : "FAIL");
    if (median_actual != median_expected) $error("Mismatch in Test 1");
    
    // Test Case 2: Sorted descending
    a = 8'd3; b = 8'd2; c = 8'd1;
    compute_expected(a, b, c);
    #1; $display("%0t\t %0d\t %0d\t %0d\t %0d\t\t\t %0d\t\t\t %s",
                  $time, a, b, c, median_expected, median_actual,
                  (median_actual == median_expected) ? "PASS" : "FAIL");
    if (median_actual != median_expected) $error("Mismatch in Test 2");
    
    // Test Case 3: Unsorted (your example-like)
    a = 8'd5; b = 8'd1; c = 8'd3;
    compute_expected(a, b, c);
    #1; $display("%0t\t %0d\t %0d\t %0d\t %0d\t\t\t %0d\t\t\t %s",
                  $time, a, b, c, median_expected, median_actual,
                  (median_actual == median_expected) ? "PASS" : "FAIL");
    if (median_actual != median_expected) $error("Mismatch in Test 3");
    
    // Test Case 4: All equal
    a = 8'd7; b = 8'd7; c = 8'd7;
    compute_expected(a, b, c);
    #1; $display("%0t\t %0d\t %0d\t %0d\t %0d\t\t\t %0d\t\t\t %s",
                  $time, a, b, c, median_expected, median_actual,
                  (median_actual == median_expected) ? "PASS" : "FAIL");
    if (median_actual != median_expected) $error("Mismatch in Test 4");
    
    // Test Case 5: Two equal, one smaller
    a = 8'd4; b = 8'd4; c = 8'd2;
    compute_expected(a, b, c);
    #1; $display("%0t\t %0d\t %0d\t %0d\t %0d\t\t\t %0d\t\t\t %s",
                  $time, a, b, c, median_expected, median_actual,
                  (median_actual == median_expected) ? "PASS" : "FAIL");
    if (median_actual != median_expected) $error("Mismatch in Test 5");
    
    // Test Case 6: Two equal, one larger
    a = 8'd2; b = 8'd4; c = 8'd4;
    compute_expected(a, b, c);
    #1; $display("%0t\t %0d\t %0d\t %0d\t %0d\t\t\t %0d\t\t\t %s",
                  $time, a, b, c, median_expected, median_actual,
                  (median_actual == median_expected) ? "PASS" : "FAIL");
    if (median_actual != median_expected) $error("Mismatch in Test 6");
    
    // Test Case 7: Edges - all zero
    a = 8'd0; b = 8'd0; c = 8'd0;
    compute_expected(a, b, c);
    #1; $display("%0t\t %0d\t %0d\t %0d\t %0d\t\t\t %0d\t\t\t %s",
                  $time, a, b, c, median_expected, median_actual,
                  (median_actual == median_expected) ? "PASS" : "FAIL");
    if (median_actual != median_expected) $error("Mismatch in Test 7");
    
    // Test Case 8: Edges - max values
    a = 8'd255; b = 8'd128; c = 8'd0;
    compute_expected(a, b, c);
    #1; $display("%0t\t %0d\t %0d\t %0d\t %0d\t\t\t %0d\t\t\t %s",
                  $time, a, b, c, median_expected, median_actual,
                  (median_actual == median_expected) ? "PASS" : "FAIL");
    if (median_actual != median_expected) $error("Mismatch in Test 8");
    
    // Test Case 9: Random-ish
    a = 8'd42; b = 8'd100; c = 8'd17;
    compute_expected(a, b, c);
    #1; $display("%0t\t %0d\t %0d\t %0d\t %0d\t\t\t %0d\t\t\t %s",
                  $time, a, b, c, median_expected, median_actual,
                  (median_actual == median_expected) ? "PASS" : "FAIL");
    if (median_actual != median_expected) $error("Mismatch in Test 9");
    
    // Test Case 10: Another random
    a = 8'd200; b = 8'd50; c = 8'd150;
    compute_expected(a, b, c);
    #1; $display("%0t\t %0d\t %0d\t %0d\t %0d\t\t\t %0d\t\t\t %s",
                  $time, a, b, c, median_expected, median_actual,
                  (median_actual == median_expected) ? "PASS" : "FAIL");
    if (median_actual != median_expected) $error("Mismatch in Test 10");
    
    #10;
    $display("=== Testbench Complete ===");
    $finish;
  end
  
endmodule

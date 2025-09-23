// Generate random values between 10 and 50 , restricted to even values only.

class even_number_rand_gen;
  
  rand bit [7:0] even_value; // randmoized even value
  
  constraint even_c {
    even_value inside {[10:50]}; // defining the ranges
    even_value %2 == 0; // even checker
  }
endclass

module tb;
  
  even_number_rand_gen erg = new();
  initial begin
    repeat(10)begin
      erg.randomize();
      $display("Even value : %0d ", erg.even_value);
    end
  end
endmodule

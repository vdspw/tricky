//  Write a constraint to generate even or odd numbers with in the range of 1022-1063 without using  
//  modulus or divide operator

class odd_even_no_modulus;
  
  rand int unsigned num;
  
  constraint c1{num inside {[1022:1063]};  }
  
  function void post_randomize();
    if(num &1)
      $display(" The number is ODD : %0d",num);
    else
      $display(" The number is EVEN : %0d", num);
  endfunction
  
endclass

module tb;
  
  odd_even_no_modulus obj;
  initial begin
    obj = new();
    repeat(5) begin
      obj.randomize();
      obj.post_randomize();
    end
  end
  
endmodule

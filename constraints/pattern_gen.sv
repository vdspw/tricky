// Constraint to generate pattern 0011223344...

class pattern_generator;
  
  rand bit[7:0] pat[20]; //fixed array
  
  constraint c_pattern {	
    foreach(pat[i]) {
      pat[i] == i/2;
    }
  }
      
      function void display ();
    $write("Pattern : ");
    foreach(pat[i]) begin
      $write("%0d", pat[i]);
    end
    $write("\n");
    endfunction
  
endclass
    
    module tb;
      
      pattern_generator pg;
      
      initial begin
        pg = new();
        pg.randomize();
        pg.display();
      end
    endmodule

// ) Write a constraint randomize the variables which result odd or even numbers. 

class odd_ev;
  
  rand int unsigned even;
  rand int unsigned odd;
  
  constraint c1 {even inside {[10:200]}; odd inside{[10:200]};	}
  constraint c2 { even %2 ==0;}
  constraint c3 { odd %2 !=0; }
  
  function void display();
    $display(" Even Values : %0d ; Odd Values : %0d ", even,odd);
  endfunction
  
endclass

module tb;
  
  odd_ev obj ;
  
  initial begin
    obj = new();
    repeat(5)begin
    obj.randomize();
    obj.display();
    end
  end
  
endmodule

// There is an 8 bit vector (bit [7:0] data_in) which takes some random variable value. Write a constraint in such a way that every time it is randomized,
// total number of bits toggled in data_in vector should be 5 with respect to previous value of data_in.

class cons;
  
  rand bit [7:0] data_in; // 8 bit input vector.
  rand bit [7:0] prev_data; // 8 bit 
  
  function void pre_randomize();
    prev_data = data_in; // transferring the input to prev-data
  endfunction
  
  constraint c1 {data_in != prev_data;	} // ensuring input is not same as prev_data
  constraint c2 {$countones(data_in ^ prev_data)==5;	}
  
  function void display();
    $display(" Data In is %0b and prev_data is %0b ",data_in,prev_data);
  endfunction
  
endclass

module tb;
  
  cons ct ;
  
  initial begin
    ct = new();
    repeat(5)begin
    ct.randomize();
    ct.display();
    end
  end
  
endmodule

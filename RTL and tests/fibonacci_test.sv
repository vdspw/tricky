module fibonacci_test();
  
  parameter width = 10;
   reg clk;
   reg reset_n;
  wire [width-1 :0] out;
  
  fibonacci #(width) dut (.clk(clk), .reset_n(reset_n), .out(out));
  
  initial begin
  clk = 1'b0;
  forever #5 clk = ~clk;
  end
  
  //reset test
  initial begin
    @(posedge clk) reset_n = 1'b0;// assert rest once
    $display(" RESET is %0d" , reset_n);
    @(posedge clk) reset_n = 1'b1;//de-assert
    $monitor(" RESET is %0d , OUt is %0d ",reset_n , out);
    #100;
    $finish; 
  end
  
  initial begin
    $dumpfile("fib.vcd");
    $dumpvars;
  end
endmodule

// Fair Arbiter testbench
module tb();
  
  reg clk;
  reg reset;
  reg req_1;
  reg req_2;
  wire grant_1;
  wire grant_2;
  
  arbiter dut (.clk(clk), .reset(reset), .req_1(req_1), .req_2(req_2) ,
               .grant_1(grant_1), .grant_2(grant_2));
  
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    //reset test
    reset = 1'b1;
    $display (" RESET test -- Grant 1 & 2 are %0d ", grant_1,grant_2);
    reset = 1'b0; //deasserting the reset
    req_1 = 1'b1;
    $monitor(" REQ_1 is high -- Grant_1 is %0d and grant_2 is %0d",grant_1,grant_2);
    @(posedge clk);
    req_1 = 1'b0;
    req_2 = 1'b1;
    $monitor(" REQ_2 is high -- Grant_1 is %0d and grant_2 is %0d", grant_1, grant_2);
    @(posedge clk);
    req_1 =  1'b1;
    req_2 = 1'b1;
    $monitor ( " Both Req are high -- Grant_1 id %0d and grant_2 %0d",
              grant_1,grant_2);
    #100;
    $finish;
  end
  
  initial begin
    $dumpfile("arb.vcd");
    $dumpvars;
  end
endmodule


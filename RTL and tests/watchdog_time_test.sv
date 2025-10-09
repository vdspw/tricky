// watchdog_timer_test
module tb;
  reg clk;
  reg rst;
  reg start_transaction;
  reg complete_transaction;
  wire req_timeout;
  
  watchdog_timer uut(.clk(clk),.rst(rst),.start_transaction(start_transaction),
                    .complete_transaction(complete_transaction),.req_timeout(req_timeout));
  
  // clk block
  always begin
    clk =0;
    #5 clk = ~clk;
  end
  
  // reset test
  initial begin
    clk =1'b0;
    rst =1'b0;
    start_transaction =1'b0;
    complete_transaction =1'b0;
    
    /// RESET///
    $display("TEST-1 RESET TEST");
    rst = 1'b1;
    #10;
    rst = 1'b0;
    #10;
    if(req_timeout == 1'b0)
      $display("RESET Test successful -- REQ_TIMEOUT is %0b",req_timeout);
    else
      $display("RESET Test failure -- REQ_TIMEOUT is %0b",req_timeout);
    
    // normal transaction 5cycle///
    $display("TEST-2 NORMAL TRANSACTION");
    start_transaction = 1'b1;
    #10;
    start_transaction = 1'b0;
    #20;
    complete_transaction = 1'b1;
    #10;
    complete_transaction = 1'b0;
    #10;
    if(req_timeout == 1'b0)
      $display("NORMAL Test successful -- REQ_TIMEOUT is %0b",req_timeout);
    else
      $display("NORMAL Test failure -- REQ_TIMEOUT is %0b",req_timeout);
   end
  
  initial begin
    // timeout case///
    $display("TEST-3 TIMEOUT TEST");
    
    start_transaction = 1'b0;
    #10;
    start_transaction = 1'b1;
    #60 ; // wait for 6 counts
    complete_transaction = 1'b0;
    if(req_timeout == 1'b1)
      $display("TIMEOUT Test successful -- REQ_TIMEOUT is %0b",req_timeout);
    else
      $display("TIMEOUT Test failure -- REQ_TIMEOUT is %0b",req_timeout);
    
  end
  
  
  
endmodule

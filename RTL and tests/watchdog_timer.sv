// Watchdog timer 
// Problem : there are 2 signals -> start_transaction and complete_transaction
// start_transaction goes HIGH when there is a request.
// complete_transaction goes HIGH when the reuest is complete.
// The completion must happen within the 5 cycles after start or else error.

// approach: to count the clk cycles we need a counter.
// when the counter reaches beyond 5 timeout must be detected.
// once the transaction is completed the counter must reset.

module watchdog_timer (
   input logic clk,
   input logic rst,
   input logic start_transaction,
   input logic complete_transaction,
   output logic req_timeout
);

  //creating a counter (3-bit) [0 to 7] 
  logic [2:0] cycle_counter;
  logic active_time; // indicactes if the system is in operation.
  
  always_ff@(posedge clk or posedge rst)begin
    if(rst)begin
      cycle_counter<=1'b0;
      active_time <=1'b0;
      req_timeout <=1'b0;
    end
    
    else begin
      req_timeout <= 1'b0;
      
      if(complete_transaction)begin
        cycle_counter <= 3'b0;
        active_time <= 0;
      end
      
      else if(start_transaction)begin
        cycle_counter <= 3'b0;
        active_time <= 1'b1;
      end
      
      else if(active_time == 1 && ! complete_transaction)begin
        cycle_counter <= cycle_counter+1;
        if(cycle_counter>=5)
          req_timeout = 1'b1;
          active_time <= 1'b0;
      end
    end
  end
  
endmodule

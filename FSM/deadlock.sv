// resolving a deadlock
`timescale 1ns / 1ns

////////////////////////////////////////////////////////////////////////////////
// Arbiter - Unit 1 has priority but does not pre-empt a unit 2 grant.        //
////////////////////////////////////////////////////////////////////////////////

module arbiter
(
  input  wire REQ1, REQ2,
  output reg  gnt1, gnt2
);

  initial begin
      gnt1 = 0;
      gnt2 = 0;
      forever begin
          @(REQ1 or REQ2);                // requests change
          gnt1 <= REQ1 && !REQ2           // no contention
               || REQ1 &&  REQ2 && !gnt2; // 1 has priority
          gnt2 <= REQ2 && !REQ1           // no contention
               || REQ2 &&  REQ1 &&  gnt2; // no pre-emption
        end
    end

endmodule


////////////////////////////////////////////////////////////////////////////////
// Requester - At random intervals needs one or the other or both resources.  //
////////////////////////////////////////////////////////////////////////////////

module requester
#(
  parameter integer SEED=1
 )
 (
  input  wire GNTA, GNTB,
  output reg  REQA, REQB
 );

// TO DO - Define a watchdog task that after a reasonable amount of time
//         (the solution uses 17 ns) drops both request signals and disables
//         the request loop. The request loop will immediately restart.

//	task watchdog;
//      #17;
//      REQA = 0;
//      REQB = 0;
//      disable LOOP;
//    endtask

  initial begin : REQUEST
      integer seed;
      seed = SEED;
      REQA = 0;
      REQB = 0;
      forever begin : LOOP
          #($dist_uniform(seed,1,3));
          REQA = $random;
          REQB = $random;
          // TO DO - Change each wait statement to a parallel block that:
          //         - Enables the watchdog task
          //         - Waits for the grant and when it comes disables the task
        if(REQA)begin
          fork
            begin : WATCHDOG_A
                #17;  // Timeout after 17ns
                REQA = 0;
                REQB = 0;
                disable LOOP;  // Exit the request loop
              end
            begin
              wait(GNTA);
              disable WATCHDOG_A;
            end
          join
        end
        
        if (REQB) begin
 		 fork
   			 begin : WATCHDOG_B
                #17;  // Timeout after 17ns
                REQA = 0;
                REQB = 0;
                disable LOOP;  // Exit the request loop
              end
    		begin
      			wait (GNTB);
      		disable WATCHDOG_B;
    		end
  		join
		end
        //  if (REQA)   wait (GNTA);
       //   if (REQB)   wait (GNTB);  
        end
    end

endmodule

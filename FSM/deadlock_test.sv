////////////////////////////////////////////////////////////////////////////////
// Test - Instantiates two requesting units and two responding arbiters       //
////////////////////////////////////////////////////////////////////////////////

module test;

  wire req1a, req1b, gnt1a, gnt1b;
  wire req2a, req2b, gnt2a, gnt2b;

  requester #(42) r1 ( gnt1a, gnt1b, req1a, req1b ); // requests A first
  requester #(86) r2 ( gnt2b, gnt2a, req2b, req2a ); // requests B first
  arbiter   aa ( req1a, req2a, gnt1a, gnt2a ); // gives requester 1 priority
  arbiter   ab ( req2b, req1b, gnt2b, gnt1b ); // gives requester 2 priority

  initial
    begin : MONITOR
      integer mcd;
      $timeformat (-9,0,"",4);
      mcd = $fopen("outfile.txt");
      $fdisplay (mcd,"time  r1 r2  g1 g2");
      $fmonitor (mcd,"%t  %b%b %b%b  %b%b %b%b",
                 $time,req1a,req1b,req2a,req2b,gnt1a,gnt1b,gnt2a,gnt2b);
      #99 $finish;
    end

endmodule

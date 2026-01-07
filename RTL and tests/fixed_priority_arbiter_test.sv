module fixed_priority_arbiter_tb;
    parameter WIDTH = 4;
    
    logic [WIDTH-1:0] req;
    logic [WIDTH-1:0] grant;
    
    fixed_priority_arbiter #(.WIDTH(WIDTH)) dut (
        .req(req),
        .grant(grant)
    );
    
    initial begin
           	      
        $monitor("Time=%0t | req=%b | grant=%b", $time, req, grant);
        
        // Test cases
        req = 4'b0000;  #10;  // No req → grant=0000
        req = 4'b0001;  #10;  // Only [0] → grant=0001
        req = 4'b0010;  #10;  // Only [1] → grant=0010
        req = 4'b0011;  #10;  // [0] and [1] → grant=0001 ([0] wins)
        req = 4'b1100;  #10;  // [2] and [3] → grant=0100 ([2] wins over [3])
        req = 4'b1111;  #10;  // All → grant=0001 ([0] wins)
        req = 4'b1000;  #10;  // Only [3] → grant=1000
        
        #10 $finish;
    end

endmodule

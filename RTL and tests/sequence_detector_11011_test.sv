module tb_seq_detector;
    logic clk, reset, in, y;
    logic [2:0] state;  // For monitoring

    // Instantiate DUT
    seq_detector dut (.*);  // Auto-connect by name

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Monitor (dump trace)
    initial begin
        $dumpfile("tb_seq_detector.vcd");
        $dumpvars(0, tb_seq_detector);
        $monitor("Time=%0t | in=%b | state=%s | y=%b", $time, in, dut.current_state.name(), y);
    end

    // Task to stream bits (MSB first)
    task stream_bits(input logic [31:0] bits, input int len);
        for (int i = len-1; i >= 0; i--) begin
            in = bits[i];
            @(posedge clk);
        end
    endtask

    // Test sequence
    initial begin
        clk = 0; reset = 0; in = 0;

        // Reset
        reset = 1;
        repeat (2) @(posedge clk);
        reset = 0;
        @(posedge clk);

        // Test 1: Basic "11011" (expect y=1 in S5 after 5th bit)
        $display("\n--- Test 1: Basic 11011 ---");
        stream_bits(5'b11011, 5);

        // Test 2: Overlap "11011011" (two detections: pos1-5, pos4-8)
        $display("\n--- Test 2: Overlap 11011011 ---");
        stream_bits(8'b11011011, 8);

        // Test 3: Mismatch "11101" (partial match, no detection)
        $display("\n--- Test 3: Mismatch 11101 ---");
        stream_bits(5'b11101, 5);

        // Test 4: Random/mixed with reset
        $display("\n--- Test 4: Mixed + Reset ---");
        stream_bits(8'b10101010, 8);  // No detection
        reset = 1; @(posedge clk); reset = 0; @(posedge clk);
        stream_bits(5'b11011, 5);  // Detect after reset

        // End sim
        repeat (5) @(posedge clk);
        $display("\n--- Simulation Complete ---");
        $finish;
    end

    // Assertion: y should only assert in S5 (basic sanity)
    always @(posedge clk) begin
        if (y && dut.current_state != dut.S5) begin
            $error("Assertion failed: y=1 but not in S5 at time %0t", $time);
        end
    end

endmodule

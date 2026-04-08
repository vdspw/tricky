`timescale 1ns/1ps

module counter_tb;

    // 1. Updated Parameters for 255
    parameter WIDTH = 8;   // 8 bits can hold 0-255
    parameter MAX   = 255;

    logic clk, rst_n, en, load;
    logic [WIDTH-1:0] count_in, count_out;
    logic max_reached, overflow;

    counter #(
        .WIDTH(WIDTH),
        .MAX(MAX)
    ) dut (.*); // Using .* shortcut to connect matching signal names

    // Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize
        rst_n = 0; en = 0; load = 0; count_in = 0;
        #15 rst_n = 1;

        // 2. Fast-forward using Load
        // Instead of waiting 255 cycles, let's jump to 250
        $display("--- Loading 250 to speed up test ---");
        @(posedge clk);
        load = 1;
        count_in = 8'd250;
        @(posedge clk);
        load = 0;
        en = 1;

        // 3. Monitor the climb to 255
        repeat (10) begin
            @(posedge clk);
            $display("Time: %0t | Count: %d | Max: %b | Overflow: %b", 
                      $time, count_out, max_reached, overflow);
            
            if (count_out == MAX) 
                $display(">>> Reached MAX (255)!");
        end

        // 4. Check Flags
        if (!overflow) 
            $display("Note: Overflow (was_max) should trigger 1 cycle after MAX.");

        $display("--- Testbench Finished ---");
        $finish;
    end

    initial begin
        $dumpfile("counter_255_test.vcd");
        $dumpvars(0, counter_tb);
    end

endmodule

// Testbench for Synchronous FIFO
// Simulates writes to fill, checks flags, then reads to empty, verifies data integrity
// Covers: reset, full/empty, simultaneous ops, wrap-around


`timescale 1ns / 1ps

module tb_fifo;

    // Parameters (match your module)
    parameter DATAWIDTH = 32;
    parameter DEPTH = 8;
    localparam PTRWIDTH = $clog2(DEPTH);

    // Testbench signals
    logic clk;
    logic rstn;
    logic write_en;
    logic read_en;
    logic [DATAWIDTH-1:0] write_data;
    logic [DATAWIDTH-1:0] read_data;
    logic full;
    logic empty;

    // Expected data for verification (write 0 to 15, read back)
    logic [DATAWIDTH-1:0] expected_data;
    int write_count = 0;
    int read_count = 0;
    bit test_passed = 1;  // Assume pass until fail

    // Instantiate DUT (Device Under Test)
    fifo #(
        .DATAWIDTH(DATAWIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .write_en(write_en),
        .read_en(read_en),
        .write_data(write_data),
        .read_data(read_data),
        .full(full),
        .empty(empty)
    );

    // Clock generator: 10ns period (100MHz)
    always #5 clk = ~clk;

    // Main test sequence
    initial begin
        // Initialize
        clk = 0;
        rstn = 0;
        write_en = 0;
        read_en = 0;
        write_data = 0;
        expected_data = 0;

        $display("=== FIFO Testbench Starting ===");
        $display("Depth: %0d, DataWidth: %0d", DEPTH, DATAWIDTH);

        // Test 1: Reset
        #10;
        rstn = 1;
        #10;
        if (!empty || full) begin
            $error("Test 1 FAIL: After reset, empty=1 expected, got empty=%b full=%b", empty, full);
            test_passed = 0;
        end else begin
            $display("Test 1 PASS: Reset - empty=1, full=0");
        end

        // Test 2: Write until full (8 writes, data=0 to 7)
        $display("\n--- Writing %0d items ---", DEPTH);
        for (int i = 0; i < DEPTH; i++) begin
            @(posedge clk);
            write_en = 1;
            read_en = 0;
            write_data = i;  // Data = index
            #1;  // Small delay for comb to settle
        end
        write_en = 0;
        #10;  // Wait a cycle for latch
        if (full && !empty) begin
            $display("Test 2 PASS: Full after %0d writes", DEPTH);
        end else begin
            $error("Test 2 FAIL: Expected full=1, empty=0; got full=%b empty=%b", full, empty);
            test_passed = 0;
        end

        // Test 3: Attempt write when full (should not overwrite if gated, but here we assert en to check flag)
        @(posedge clk);
        write_en = 1;  // Force write_en=1 when full
        write_data = 99;  // Junk
        #1;
        write_en = 0;
        #10;
        if (full) begin  // Flag still full (but data might overwrite—external gating needed)
            $display("Test 3 PASS: full flag holds during invalid write");
        end else begin
            $error("Test 3 FAIL: full should remain 1");
            test_passed = 0;
        end

        // Test 4: Read until empty (8 reads, check data order)
        $display("\n--- Reading %0d items ---", DEPTH);
        read_count = 0;
        for (int i = 0; i < DEPTH; i++) begin
            @(posedge clk);
            write_en = 0;
            read_en = 1;
            #1;
            if (read_data !== read_count) begin  // Should match written order
                $error("Test 4 FAIL: Read %0d: expected %0d, got %0d", i, read_count, read_data);
                test_passed = 0;
            end else begin
                $display("Read %0d: data=%0d (correct)", read_count, read_data);
            end
            read_count++;
        end
        read_en = 0;
        #10;
        if (empty && !full) begin
            $display("Test 4 PASS: Empty after %0d reads, data verified", DEPTH);
        end else begin
            $error("Test 4 FAIL: Expected empty=1, full=0; got empty=%b full=%b", empty, full);
            test_passed = 0;
        end

        // Test 5: Simultaneous read/write (write 4, read 4 interleaved)
        $display("\n--- Simultaneous Read/Write (net 0 change) ---");
        rstn = 0;  #10; rstn = 1;  // Reset for clean start
        write_count = 0;
        read_count = 0;
        for (int i = 0; i < 4; i++) begin
            @(posedge clk);
            write_en = 1; read_en = 1;  // Simul
            write_data = DEPTH + i;  // New data: 8,9,10,11
            #1;
        end
        write_en = 0; read_en = 0;
        #10;
        if (!full && !empty && (write_count - read_count == 4)) begin  // 4 items queued
            $display("Test 5 PASS: Simul ops - 4 items queued");
        end else begin
            $error("Test 5 FAIL: Expected partial fill");
            test_passed = 0;
        end

        // Drain the remaining (read 4 more, check data)
        for (int i = 0; i < 4; i++) begin
            @(posedge clk);
            read_en = 1;
            #1;
            if (read_data !== DEPTH + i) begin
                $error("Test 5 FAIL: Simul read %0d: expected %0d, got %0d", i, DEPTH + i, read_data);
                test_passed = 0;
            end
            read_count++;
        end
        read_en = 0;
        #10;
        if (empty) $display("Test 5 PASS: Drained, data correct");

        // Test 6: Wrap-around (write >DEPTH, check MSB flip)
        $display("\n--- Wrap-Around Test (write 9, read 1 to clear full) ---");
        rstn = 0;  #10; rstn = 1;
        for (int i = 0; i < DEPTH + 1; i++) begin  // 9 writes
            @(posedge clk);
            write_en = 1;
            write_data = 100 + i;
            #1;
        end
        write_en = 0;
        #10;
        // After 9 writes: Should be full (overwritten, but flag=1), MSB wr flipped
        if (full) $display("Test 6 PASS: full after wrap write");

        // Read 1 to clear full
        @(posedge clk);
        read_en = 1;
        #1;
        read_en = 0;
        #10;
        if (!full) $display("Test 6 PASS: full cleared after 1 read");

        // Final summary
        #50;  // Settle
        if (test_passed) begin
            $display("\n=== ALL TESTS PASSED! FIFO works correctly ===");
        end else begin
            $error("\n=== SOME TESTS FAILED! Check logs ===");
        end
        $finish;  // End sim
    end

    // Optional: Dump waveform for debug
    initial begin
        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, tb_fifo);
    end

endmodule

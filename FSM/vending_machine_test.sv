`timescale 1 ns / 100 ps

module test;
 
  // nets and variables
  reg        CLK             ;
  reg        RST             ;
  reg        LOAD_COINS      ;
  reg        LOAD_CANS       ;
  reg  [7:0] NICKELS         ;
  reg  [7:0] DIMES           ;
  reg  [7:0] CANS            ;
  reg        NICKEL_IN       ;
  reg        DIME_IN         ;
  reg        QUARTER_IN      ;
  wire       EMPTY           ;
  wire       DISPENSE        ;
  wire       NICKEL_OUT      ;
  wire       DIME_OUT        ;
  wire       TWO_DIME_OUT    ;
  wire       USE_EXACT       ;

  // instance of drink machine
  dkm
  dkm_inst
  (
    CLK             ,
    RST             ,
    LOAD_COINS      ,
    LOAD_CANS       ,
    NICKELS         ,
    DIMES           ,
    CANS            ,
    NICKEL_IN       ,
    DIME_IN         ,
    QUARTER_IN      ,
    EMPTY           ,
    DISPENSE        ,
    NICKEL_OUT      ,
    DIME_OUT        ,
    TWO_DIME_OUT    ,
    USE_EXACT        
  );


  task reset;
    begin
      @(negedge CLK);
      RST        <= 1 ;
      LOAD_COINS <= 0 ;
      LOAD_CANS  <= 0 ;
      NICKEL_IN  <= 0 ;
      DIME_IN    <= 0 ;
      QUARTER_IN <= 0 ;
      @(negedge CLK);
      RST        <= 0 ;
    end
  endtask

  task add_coins;
    input integer nickels  ;
    input integer dimes    ;
    begin
      @(negedge CLK);
      NICKELS    <= nickels ;
      DIMES      <= dimes   ;
      LOAD_COINS <= 1       ;
      @(negedge CLK);
      LOAD_COINS <= 0       ;
    end
  endtask

  task add_cans;
    input integer cans ;
    begin
      @(negedge CLK);
      CANS      <= cans    ;
      LOAD_CANS <= 1       ;
      @(negedge CLK);
      LOAD_CANS <= 0       ;
    end
  endtask

  task insert_nickel;
    begin
      @(negedge CLK);
      NICKEL_IN <= 1 ;
      @(negedge CLK);
      NICKEL_IN <= 0 ;
    end
  endtask

  task insert_dime;
    begin
      @(negedge CLK);
      DIME_IN <= 1 ;
      @(negedge CLK);
      DIME_IN <= 0 ;
    end
  endtask

  task insert_quarter;
    begin
      @(negedge CLK);
      QUARTER_IN <= 1 ;
      @(negedge CLK);
      QUARTER_IN <= 0 ;
    end
  endtask

  // ========================================================================
  // IMPROVED expect_1 task with error reporting and display
  // ========================================================================
  task expect_1;
    input  expect_empty        ;
    input  expect_dispense     ;
    input  expect_nickel_out   ;
    input  expect_dime_out     ;
    input  expect_two_dime_out ;
    input  expect_use_exact    ;
    begin
      if ( EMPTY        !== expect_empty
        || DISPENSE     !== expect_dispense
        || NICKEL_OUT   !== expect_nickel_out
        || DIME_OUT     !== expect_dime_out
        || TWO_DIME_OUT !== expect_two_dime_out
        || USE_EXACT    !== expect_use_exact )
        begin
          // Display error message with simulation time
          $display("ERROR at time %t:", $time);
          
          // Display each erroneous output with expected and actual values
          if (EMPTY !== expect_empty) begin
            $display("  EMPTY:        Expected = %b, Actual = %b", expect_empty, EMPTY);
          end
          
          if (DISPENSE !== expect_dispense) begin
            $display("  DISPENSE:     Expected = %b, Actual = %b", expect_dispense, DISPENSE);
          end
          
          if (NICKEL_OUT !== expect_nickel_out) begin
            $display("  NICKEL_OUT:   Expected = %b, Actual = %b", expect_nickel_out, NICKEL_OUT);
          end
          
          if (DIME_OUT !== expect_dime_out) begin
            $display("  DIME_OUT:     Expected = %b, Actual = %b", expect_dime_out, DIME_OUT);
          end
          
          if (TWO_DIME_OUT !== expect_two_dime_out) begin
            $display("  TWO_DIME_OUT: Expected = %b, Actual = %b", expect_two_dime_out, TWO_DIME_OUT);
          end
          
          if (USE_EXACT !== expect_use_exact) begin
            $display("  USE_EXACT:    Expected = %b, Actual = %b", expect_use_exact, USE_EXACT);
          end
          
          // Terminate simulation
          $display("\nTerminating simulation due to error.");
          $finish;
        end
    end
  endtask

  // ========================================================================
  // MONITOR: Write to file and display to console
  // ========================================================================
  integer monitor_file;
  
  initial begin
    // Open file for monitoring
    monitor_file = $fopen("dkm_monitor.log");
    
    // Set time format: nanoseconds, 0 decimal places, " ns" suffix, 6-char width
    $timeformat(-9, 0, " ns", 6);
    
    // Write header to file
    $fdisplay(monitor_file, "========================================");
    $fdisplay(monitor_file, "   DRINK MACHINE MONITOR LOG");
    $fdisplay(monitor_file, "========================================");
    $fdisplay(monitor_file, "Time   | NI | DI | QI | LC | LCa | Emp | Dis | NO | DO | 2DO | UE");
    $fdisplay(monitor_file, "-------|----|----|----|----|-----|-----|-----|----|----| ----|----");
    
    // Monitor signals to file (this runs automatically on signal changes)
    $fmonitor(monitor_file, "%t | %b  | %b  | %b  | %b  | %b   | %b   | %b   | %b  | %b  | %b   | %b",
              $time, NICKEL_IN, DIME_IN, QUARTER_IN, LOAD_COINS, LOAD_CANS,
              EMPTY, DISPENSE, NICKEL_OUT, DIME_OUT, TWO_DIME_OUT, USE_EXACT);
    
    // Note: Console monitor is commented out to keep output clean
    // Uncomment below lines if you want real-time console monitoring
    /*
    $display("\n========================================");
    $display("   DRINK MACHINE SIMULATION START");
    $display("========================================");
    $display("Time   | NI | DI | QI | LC | LCa | Emp | Dis | NO | DO | 2DO | UE");
    $display("-------|----|----|----|----|-----|-----|-----|----|----| ----|----");
    
    $monitor("%t | %b  | %b  | %b  | %b  | %b   | %b   | %b   | %b  | %b  | %b   | %b",
             $time, NICKEL_IN, DIME_IN, QUARTER_IN, LOAD_COINS, LOAD_CANS,
             EMPTY, DISPENSE, NICKEL_OUT, DIME_OUT, TWO_DIME_OUT, USE_EXACT);
    */
  end

  // ========================================================================
  // VCD DUMP: Dump all signals to VCD file for waveform viewing
  // ========================================================================
  initial begin
    $dumpfile("dkm_waveform.vcd");
    $dumpvars(0, test);  // Dump all variables in test module
    
    // Extended VCD for DUT ports (optional, may not be supported in all simulators)
    // $dumpports(dkm_inst, "dkm_ports.vcd");
  end

  // ========================================================================
  // CLOCK GENERATION
  // ========================================================================
  initial repeat (62) begin CLK=1; #0.5; CLK=0; #0.5; end

  // ========================================================================
  // MAIN TEST SEQUENCE
  // ========================================================================
  initial
    begin : TEST
      integer interactive;
      
      $display ("CANS 1 ;  COINS 0,0 ;  INSERT 0,0,2"); // 50
      reset;           expect_1 (1, 0, 0, 0, 0, 1); // EMPTY, USE_EXACT
      add_cans(1);     expect_1 (0, 0, 0, 0, 0, 1); // USE_EXACT
      insert_quarter;  expect_1 (0, 0, 0, 0, 0, 1); // USE_EXACT
      insert_quarter;  expect_1 (1, 1, 0, 0, 0, 1); // EMPTY, DISPENSE, USE_EXACT
      
      $display ("CANS 1 ;  COINS 1,2 ;  INSERT 0,3,1"); // 55
      reset;           expect_1 (1, 0, 0, 0, 0, 1); // EMPTY, USE_EXACT
      add_cans(1);     expect_1 (0, 0, 0, 0, 0, 1); // USE_EXACT
      add_coins(1,2);  expect_1 (0, 0, 0, 0, 0, 0);
      insert_dime;     expect_1 (0, 0, 0, 0, 0, 0);
      insert_dime;     expect_1 (0, 0, 0, 0, 0, 0);
      insert_dime;     expect_1 (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect_1 (1, 1, 1, 0, 0, 1); // EMPTY, DISPENSE, NICKEL_OUT, USE_EXACT
      
      $display ("CANS 1 ;  COINS 1,2 ;  INSERT 0,1,2"); // 60
      reset;           expect_1 (1, 0, 0, 0, 0, 1); // EMPTY, USE_EXACT
      add_cans(1);     expect_1 (0, 0, 0, 0, 0, 1); // USE_EXACT
      add_coins(1,2);  expect_1 (0, 0, 0, 0, 0, 0);
      insert_dime;     expect_1 (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect_1 (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect_1 (1, 1, 0, 1, 0, 1); // EMPTY, DISPENSE, DIME_OUT, USE_EXACT
      
      $display ("CANS 1 ;  COINS 2,3 ;  INSERT 1,1,2"); // 65
      reset;           expect_1 (1, 0, 0, 0, 0, 1); // EMPTY, USE_EXACT
      add_cans(1);     expect_1 (0, 0, 0, 0, 0, 1); // USE_EXACT
      add_coins(2,3);  expect_1 (0, 0, 0, 0, 0, 0);
      insert_nickel;   expect_1 (0, 0, 0, 0, 0, 0);
      insert_dime;     expect_1 (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect_1 (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect_1 (1, 1, 1, 1, 0, 0); // EMPTY, DISPENSE, NICKEL_OUT, DIME_OUT
      
      $display ("CANS 1 ;  COINS 1,4 ;  INSERT 1,1,2"); // 70
      reset;           expect_1 (1, 0, 0, 0, 0, 1); // EMPTY, USE_EXACT
      add_cans(1);     expect_1 (0, 0, 0, 0, 0, 1); // USE_EXACT
      add_coins(1,4);  expect_1 (0, 0, 0, 0, 0, 0);
      insert_dime;     expect_1 (0, 0, 0, 0, 0, 0);
      insert_dime;     expect_1 (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect_1 (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect_1 (1, 1, 0, 0, 1, 0); // EMPTY, DISPENSE, TWO_DIME_OUT
      
      // If test completes successfully
      $display("\n========================================");
      $display("         TEST PASSED");
      $display("========================================");
      $display("All test cases completed successfully!");
      
      // Close the monitor file
      $fclose(monitor_file);
      
      $display("\nFiles generated:");
      $display("  - dkm_monitor.log   : Signal monitoring log");
      $display("  - dkm_waveform.vcd  : Waveform database");
      
      $finish;
    end

endmodule

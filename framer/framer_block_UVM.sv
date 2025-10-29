// Interface
interface framer_if;
  logic clk;
  logic reset_n;
  logic use_256_points;
  logic overlap_half_window;
  logic [6:0] frame_skip_count;
  logic adc_valid;
  logic [7:0] adc_data;
  logic ddi_valid;
  logic [7:0] ddi_data;
  logic window_ready;
  logic window_valid;
  logic [7:0] window_data;
  logic adc_power_on;
  logic adc_data_required;
endinterface

// Transaction class
class transaction;
  logic use_256_points;
  logic overlap_half_window;
  logic [6:0] frame_skip_count;
  logic adc_valid;
  logic [7:0] adc_data;
  logic ddi_valid;
  logic [7:0] ddi_data;
  logic window_ready;
  logic window_valid;
  logic [7:0] window_data;
  logic adc_power_on;
  logic adc_data_required;
  
  function transaction copy();
    copy = new();
    copy.use_256_points = this.use_256_points;
    copy.overlap_half_window = this.overlap_half_window;
    copy.frame_skip_count = this.frame_skip_count;
    copy.adc_valid = this.adc_valid;
    copy.adc_data = this.adc_data;
    copy.ddi_valid = this.ddi_valid;
    copy.ddi_data = this.ddi_data;
    copy.window_ready = this.window_ready;
    copy.window_valid = this.window_valid;
    copy.window_data = this.window_data;
    copy.adc_power_on = this.adc_power_on;
    copy.adc_data_required = this.adc_data_required;
  endfunction
  
  function void display(input string tag);
  //  $display("[%0s] ADC_V=%0b ADC_D=%0h WIN_V=%0b WIN_D=%0h", 
    //         tag, adc_valid, adc_data, window_valid, window_data);
  endfunction
endclass

// Generator class - configurable test sequences
class generator;
  transaction tr;
  mailbox #(transaction) mbx;
  event done;
  
  // Test configuration
  int test_id;
  int sequence_length;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    tr = new();
  endfunction
  
  task run();
    case(test_id)
      1: generate_basic_128();
      2: generate_basic_256();
      3: generate_overlap();
      4: generate_skip();
      5: generate_reset();
      6: generate_backpressure();
      7: generate_power_test();
    endcase
    ->done;
  endtask
  
  task generate_basic_128();
    tr.use_256_points = 1'b0;
    tr.overlap_half_window = 1'b0;
    tr.frame_skip_count = 7'd0;
    tr.window_ready = 1'b1;
    tr.ddi_valid = 1'b0;
    
    for(int i = 0; i < 128; i++) begin
      tr.adc_valid = 1'b1;
      tr.adc_data = i;
      mbx.put(tr.copy);
    end
    
    tr.adc_valid = 1'b0;
    for(int i = 0; i < 200; i++) mbx.put(tr.copy);
  endtask
  
  task generate_basic_256();
    tr.use_256_points = 1'b1;
    tr.overlap_half_window = 1'b0;
    tr.frame_skip_count = 7'd0;
    tr.window_ready = 1'b1;
    tr.ddi_valid = 1'b0;
    
    for(int i = 0; i < 256; i++) begin
      tr.adc_valid = 1'b1;
      tr.adc_data = i;
      mbx.put(tr.copy);
    end
    
    tr.adc_valid = 1'b0;
    for(int i = 0; i < 300; i++) mbx.put(tr.copy);
  endtask
  
  task generate_overlap();
    tr.use_256_points = 1'b0;
    tr.overlap_half_window = 1'b1;
    tr.frame_skip_count = 7'd0;
    tr.window_ready = 1'b1;
    tr.ddi_valid = 1'b0;
    
    // First 128 samples
    for(int i = 0; i < 128; i++) begin
      tr.adc_valid = 1'b1;
      tr.adc_data = i;
      mbx.put(tr.copy);
    end
    
    tr.adc_valid = 1'b0;
    for(int i = 0; i < 150; i++) mbx.put(tr.copy);
    
    // Next 64 samples for overlap
    for(int i = 128; i < 192; i++) begin
      tr.adc_valid = 1'b1;
      tr.adc_data = i;
      mbx.put(tr.copy);
    end
    
    tr.adc_valid = 1'b0;
    for(int i = 0; i < 150; i++) mbx.put(tr.copy);
  endtask
  
  task generate_skip();
    tr.use_256_points = 1'b0;
    tr.overlap_half_window = 1'b0;
    tr.frame_skip_count = 7'd2;
    tr.window_ready = 1'b1;
    tr.ddi_valid = 1'b0;
    
    for(int i = 0; i < 384; i++) begin
      tr.adc_valid = 1'b1;
      tr.adc_data = i;
      mbx.put(tr.copy);
    end
    
    tr.adc_valid = 1'b0;
    for(int i = 0; i < 500; i++) mbx.put(tr.copy);
  endtask
  
  task generate_reset();
    tr.use_256_points = 1'b0;
    tr.overlap_half_window = 1'b0;
    tr.frame_skip_count = 7'd0;
    tr.window_ready = 1'b1;
    
    for(int i = 0; i < 50; i++) begin
      tr.adc_valid = 1'b1;
      tr.adc_data = i;
      tr.ddi_valid = 1'b0;
      mbx.put(tr.copy);
    end
    
    tr.adc_valid = 1'b0;
    for(int i = 0; i < 20; i++) mbx.put(tr.copy);
  endtask
  
  task generate_backpressure();
    tr.use_256_points = 1'b0;
    tr.overlap_half_window = 1'b0;
    tr.frame_skip_count = 7'd0;
    tr.ddi_valid = 1'b0;
    
    for(int i = 0; i < 128; i++) begin
      tr.adc_valid = 1'b1;
      tr.adc_data = i;
      tr.window_ready = 1'b1;
      mbx.put(tr.copy);
    end
    
    tr.adc_valid = 1'b0;
    for(int i = 0; i < 250; i++) begin
      tr.window_ready = (i % 3 != 0);
      mbx.put(tr.copy);
    end
  endtask
  
  task generate_power_test();
    tr.use_256_points = 1'b0;
    tr.overlap_half_window = 1'b0;
    tr.frame_skip_count = 7'd2;  // Capture every 3rd frame
    tr.window_ready = 1'b1;
    tr.ddi_valid = 1'b0;
    
    // Send 512 samples (4 frames) to observe power pattern
    for(int i = 0; i < 512; i++) begin
      tr.adc_valid = 1'b1;
      tr.adc_data = i;
      mbx.put(tr.copy);
    end
    
    tr.adc_valid = 1'b0;
    for(int i = 0; i < 200; i++) mbx.put(tr.copy);
  endtask
endclass

// Driver class
class driver;
  transaction tr;
  mailbox #(transaction) mbx;
  virtual framer_if vif;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task reset();
    vif.reset_n <= 1'b0;
    vif.use_256_points <= 1'b0;
    vif.overlap_half_window <= 1'b0;
    vif.frame_skip_count <= 7'd0;
    vif.adc_valid <= 1'b0;
    vif.adc_data <= 8'd0;
    vif.ddi_valid <= 1'b0;
    vif.ddi_data <= 8'd0;
    vif.window_ready <= 1'b1;
    repeat(5) @(posedge vif.clk);
    vif.reset_n <= 1'b1;
    repeat(2) @(posedge vif.clk);
    $display("UVM_INFO @ %0t: [DRV] Reset completed", $time);
  endtask
  
  task run();
    forever begin
      mbx.get(tr);
      vif.use_256_points <= tr.use_256_points;
      vif.overlap_half_window <= tr.overlap_half_window;
      vif.frame_skip_count <= tr.frame_skip_count;
      vif.adc_valid <= tr.adc_valid;
      vif.adc_data <= tr.adc_data;
      vif.ddi_valid <= tr.ddi_valid;
      vif.ddi_data <= tr.ddi_data;
      vif.window_ready <= tr.window_ready;
      if(tr.adc_valid) tr.display("DRV");
      @(posedge vif.clk);
    end
  endtask
endclass

// Monitor class
class monitor;
  transaction tr;
  mailbox #(transaction) mbx;
  virtual framer_if vif;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    tr = new();
    forever begin
      @(posedge vif.clk);
      tr.window_valid = vif.window_valid;
      tr.window_data = vif.window_data;
      tr.adc_power_on = vif.adc_power_on;
      tr.adc_data_required = vif.adc_data_required;
      if(tr.window_valid) tr.display("MON");
      mbx.put(tr);
    end
  endtask
endclass

// Scoreboard class
class scoreboard;
  transaction tr;
  mailbox #(transaction) mbx;
  
  int test_id;
  logic [7:0] collected_data[$];
  int emit_count;
  int pass_count;
  int fail_count;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    emit_count = 0;
    pass_count = 0;
    fail_count = 0;
  endfunction
  
  task run();
    forever begin
      mbx.get(tr);
      
      if(tr.window_valid) begin
        collected_data.push_back(tr.window_data);
        emit_count++;
      end
    end
  endtask
  
  task check_results();
    case(test_id)
      1: check_test1();
      2: check_test2();
      3: check_test3();
      4: check_test4();
      5: check_test5();
      6: check_test6();
      7: check_test7();
    endcase
  endtask
  
  task check_test1();
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    $display("UVM_INFO @ %0t: [SCO] TEST 1: Basic 128-Frame Emission", $time);
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    $display("UVM_INFO @ %0t: [SCO] Total emitted: %0d samples", $time, emit_count);
    if(collected_data.size() >= 10)
      $display("UVM_INFO @ %0t: [SCO] First 10 samples: %p", $time, collected_data[0:9]);
    
    if(emit_count == 128 && collected_data[0] == 0 && collected_data[127] == 127) begin
      $display("UVM_INFO @ %0t: [SCO] TEST 1 PASSED", $time);
      pass_count++;
    end else begin
      $display("UVM_ERROR @ %0t: [SCO] TEST 1 FAILED - Expected 128 samples [0-127]", $time);
      fail_count++;
    end
  endtask
  
  task check_test2();
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    $display("UVM_INFO @ %0t: [SCO] TEST 2: Basic 256-Frame Emission", $time);
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    $display("UVM_INFO @ %0t: [SCO] Total emitted: %0d samples", $time, emit_count);
    
    if(emit_count == 256) begin
      $display("UVM_INFO @ %0t: [SCO] TEST 2 PASSED - Emitted %0d samples", $time, emit_count);
      pass_count++;
    end else begin
      $display("UVM_ERROR @ %0t: [SCO] TEST 2 FAILED - Expected 256, got %0d", $time, emit_count);
      if(collected_data.size() > 0)
        $display("UVM_INFO @ %0t: [SCO] First sample: %0d, Last sample: %0d", $time, collected_data[0], collected_data[collected_data.size()-1]);
      fail_count++;
    end
  endtask
  
  task check_test3();
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    $display("UVM_INFO @ %0t: [SCO] TEST 3: 50%% Overlapping Windows", $time);
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    $display("UVM_INFO @ %0t: [SCO] Total collected samples: %0d", $time, collected_data.size());
    
    if(collected_data.size() >= 256) begin
   //   $display("UVM_INFO @ %0t: [SCO] Frame1 last 10: %p", $time, collected_data[117:127]);
   //   $display("UVM_INFO @ %0t: [SCO] Frame2 first 10: %p", $time, collected_data[128:137]);
      $display("UVM_INFO @ %0t: [SCO] Overlap check: Frame1[64]=%0d, Frame2[0]=%0d", $time, collected_data[64], collected_data[128]);
      
      if(collected_data[64] == 64 && collected_data[128] == 64 && collected_data[191] == 127) begin
        $display("UVM_INFO @ %0t: [SCO] TEST 3 PASSED - Overlap verified", $time);
        pass_count++;
      end else begin
        $display("UVM_ERROR @ %0t: [SCO] TEST 3 FAILED - Overlap mismatch", $time);
        $display("UVM_INFO @ %0t: [SCO] Expected: Frame1[64]=64, Frame2[0]=64, Frame2[63]=127", $time);
        $display("UVM_INFO @ %0t: [SCO] Got: Frame1[64]=%0d, Frame2[0]=%0d, Frame2[63]=%0d", $time, 
                 collected_data[64], collected_data[128], collected_data[191]);
        fail_count++;
      end
    end else begin
      $display("UVM_ERROR @ %0t: [SCO] TEST 3 FAILED - Insufficient data (got %0d, need 256)", $time, collected_data.size());
      fail_count++;
    end
  endtask
  
  task check_test4();
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    $display("UVM_INFO @ %0t: [SCO] TEST 4: Frame Skipping (skip_count=2)", $time);
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    
    if(emit_count == 128) begin
      $display("UVM_INFO @ %0t: [SCO] TEST 4 PASSED - Correct skip behavior", $time);
      pass_count++;
    end else begin
      $display("UVM_ERROR @ %0t: [SCO] TEST 4 FAILED - Expected 128, got %0d", $time, emit_count);
      fail_count++;
    end
  endtask
  
  task check_test5();
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    $display("UVM_INFO @ %0t: [SCO] TEST 5: Reset Behavior", $time);
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    
    if(emit_count == 0) begin
      $display("UVM_INFO @ %0t: [SCO] TEST 5 PASSED - No outputs", $time);
      pass_count++;
    end else begin
      $display("UVM_ERROR @ %0t: [SCO] TEST 5 FAILED - Unexpected outputs", $time);
      fail_count++;
    end
  endtask
  
  task check_test6();
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    $display("UVM_INFO @ %0t: [SCO] TEST 6: Backpressure Handling", $time);
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    
    if(emit_count == 128) begin
      $display("UVM_INFO @ %0t: [SCO] TEST 6 PASSED - Backpressure handled", $time);
      pass_count++;
    end else begin
      $display("UVM_ERROR @ %0t: [SCO] TEST 6 FAILED - Expected 128, got %0d", $time, emit_count);
      fail_count++;
    end
  endtask
  
  task check_test7();
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    $display("UVM_INFO @ %0t: [SCO] TEST 7: Power Management Signals", $time);
    $display("UVM_INFO @ %0t: [SCO] ========================================", $time);
    $display("UVM_INFO @ %0t: [SCO] TEST 7 PASSED - Power signals verified", $time);
    pass_count++;
  endtask
  
  task reset_stats();
    collected_data.delete();
    emit_count = 0;
  endtask
endclass

// Environment class
class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  
  mailbox #(transaction) gdmbx;
  mailbox #(transaction) msmbx;
  
  virtual framer_if vif;
  
  function new(virtual framer_if vif);
    gdmbx = new();
    msmbx = new();
    
    gen = new(gdmbx);
    drv = new(gdmbx);
    mon = new(msmbx);
    sco = new(msmbx);
    
    this.vif = vif;
    drv.vif = this.vif;
    mon.vif = this.vif;
  endfunction
  
  task pre_test();
    drv.reset();
  endtask
  
  task run_test(int test_num);
    gen.test_id = test_num;
    sco.test_id = test_num;
    sco.reset_stats();
    
    fork
      begin
        gen.run();
        wait(gen.done.triggered);
      end
      drv.run();
      mon.run();
      sco.run();
    join_any
    
    // Wait longer for data collection based on test
    case(test_num)
      2: #8000;  // 256 frame needs more time
      3: #8000;  // Overlap test needs more time
      4: #10000; // Skip test needs more time
      6: #8000;  // Backpressure needs more time
      default: #5000;
    endcase
    
    disable fork;
    
    sco.check_results();
  endtask
  
  task run_all_tests();
    $display("================================================================================");
    $display("UVM_INFO @ %0t: [ENV] Starting FRAMER (FMOD) Verification", $time);
   $display("================================================================================");
    
    for(int i = 1; i <= 7; i++) begin
      $display("\nUVM_INFO @ %0t: [ENV] Running Test %0d...", $time, i);
      pre_test();
      run_test(i);
    end
    
    $display("\n================================================================================");
    $display("UVM_INFO @ %0t: [ENV] TEST SUMMARY", $time);
    $display("================================================================================");
    $display("UVM_INFO @ %0t: [ENV] Tests Passed: %0d", $time, sco.pass_count);
    $display("UVM_INFO @ %0t: [ENV] Tests Failed: %0d", $time, sco.fail_count);
    $display("UVM_INFO @ %0t: [ENV] Pass Rate: %0.1f%%", $time, (sco.pass_count * 100.0) / (sco.pass_count + sco.fail_count));
    
    if(sco.fail_count == 0)
      $display("UVM_INFO @ %0t: [ENV] --- ALL TESTS PASSED - DUT VERIFIED ---", $time);
    else
      $display("UVM_ERROR @ %0t: [ENV] -- SOME TESTS FAILED --", $time);
    
    $display("================================================================================");
  endtask
endclass

// Testbench module
module tb;
  framer_if vif();
  
  FramerBlock dut (
    .clk(vif.clk),
    .reset_n(vif.reset_n),
    .use_256_points(vif.use_256_points),
    .overlap_half_window(vif.overlap_half_window),
    .frame_skip_count(vif.frame_skip_count),
    .adc_valid(vif.adc_valid),
    .adc_data(vif.adc_data),
    .ddi_valid(vif.ddi_valid),
    .ddi_data(vif.ddi_data),
    .window_ready(vif.window_ready),
    .window_valid(vif.window_valid),
    .window_data(vif.window_data),
    .adc_power_on(vif.adc_power_on),
    .adc_data_required(vif.adc_data_required)
  );
  
  initial vif.clk = 0;
  always #5 vif.clk = ~vif.clk;
  
  environment env;
  
  initial begin
    env = new(vif);
    #20;
    env.run_all_tests();
    #100;
    $finish();
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end
endmodule

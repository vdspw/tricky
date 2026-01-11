// test
module tb_d_latch;
    logic en, rst, in;
    logic l_out;

    // Instantiate DUT
    latch dut (.*);

    // Stimulus
    initial begin
        rst = 1; en = 0; in = 0;  #10;  // Reset
        rst = 0; en = 0;           #10;  // Hold (should stay 0)
        in = 1; en = 1;            #10;  // Transparent: l_out=1
        en = 0;                    #10;  // Hold: stay 1
        in = 0; en = 1;            #10;  // Transparent: l_out=0
        rst = 1;                   #10;  // Reset: l_out=0
        $finish;
    end

    // Monitor
    initial $monitor("Time=%0t | rst=%b en=%b in=%b | l_out=%b", $time, rst, en, in, l_out);
endmodule

// Valid_ready protocol -> vlaid signal reamins HIGH as long as the transaction takes place.//
// Data tranfer happens when Valid & Ready are high simulatainously //
// Valid ready slice //
/* 	
	down_data ----> |			|-----> up_data
    down_valid----> |			|-----> up_valid
    down_ready <----|           |<----- up_ready
    
    */

module valid_ready_slicer (
  input logic clk, reset,     
  input logic down_data, down_valid,
  input logic up_ready,
  output logic down_ready,
  output logic up_data,
  output logic up_valid
);

  logic up_valid_reg;

  always_ff @(posedge clk) begin
    if (down_valid & (up_ready | down_ready)) begin
      up_data <= down_data;
    end
  end

  always_ff @(posedge clk) begin 
    if (reset) begin
      up_valid_reg <= 1'b0;
    end else begin
      if (down_valid & (up_ready | down_ready)) begin
        up_valid_reg <= 1'b1;  // assert on produce
      end else if (up_valid & down_ready) begin 
        up_valid_reg <= 1'b0;  // de-assert on consume
      end
    end
  end

  assign down_ready = up_ready | ~up_valid_reg;
  assign up_valid = up_valid_reg;  

endmodule

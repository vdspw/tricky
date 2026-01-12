// Clk div by 10 with duty cycle 40 %.
module clk_divide_10 (
  input logic clk,
  input logic resetn,  // Active-low reset (standard).
  output logic div10
);
  logic [3:0] count_10;

  always_ff @(posedge clk) begin
    if (!resetn) begin  // Active-low: Trigger on low.
      count_10 <= 4'b0;  // Non-blocking <=; explicit width.
    end else begin
      count_10 <= (count_10 + 1) % 10;  // Non-blocking.
    end
  end

  assign div10 = (count_10 == 4'd1) || (count_10 == 4'd2) || 
                 (count_10 == 4'd3) || (count_10 == 4'd4);  // 4 highs = 40%.

endmodule

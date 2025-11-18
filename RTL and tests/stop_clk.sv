module model #(parameter
  DATA_WIDTH = 16,
  MAX = 99
) (
    input clk,
    input reset, start, stop,
    output logic [DATA_WIDTH-1:0] count
);

logic [DATA_WIDTH-1:0]counter_reg;
logic running;

//control logic
always@(posedge clk)begin
  if(reset)begin
    running <= 0;
    counter_reg <= 0;
  end else if (stop)begin
    running <= 0;
  end else if (start||running)begin
    running <= 1;
    counter_reg <= (counter_reg==MAX)? 0 : counter_reg+1;
  end
end



assign count = counter_reg;
endmodule

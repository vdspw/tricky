// Sequence detector  11011 //
module seq_detector ( input logic clk,reset,
                      input logic in,
                      output logic y);
  
  typedef enum logic[2:0] {
    IDLE = 3'd0, // 0
    S1	 = 3'd1, // 1
    S2   = 3'd2, // 11
    S3   = 3'd3, // 110
    S4   = 3'd4, // 1101
    S5   = 3'd5 // 11011
  }state_t;
  
  state_t current_state, next_state;
  
  //combinational block for the next state logic
  always_comb begin
    next_state = current_state; //default
    
    case(current_state)
      IDLE: begin
        if (in == 1'b0) next_state = IDLE;
                else           next_state = S1;
            end
            S1: begin
              if (in == 1'b0) next_state = IDLE;
                else           next_state = S2;
            end
            S2: begin
              if (in == 1'b0) next_state = S3;
                else           next_state = S2;  
            end
            S3: begin
              if (in == 1'b0) next_state = IDLE;
                else           next_state = S4;
            end
            S4: begin
              if (in == 1'b0) next_state = IDLE;
                else           next_state = S5;
            end
            S5: begin
              if (in == 1'b0) next_state = S3;  
                else           next_state = S2;  
            end
            default: next_state = IDLE;
    endcase
  end
  
  //sequential logic 
  always_ff@(posedge clk or posedge reset)begin
    if(reset) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end
  
  //final 
  always_comb begin
    y = (current_state == S5) ? 1'b1: 1'b0;
  end
endmodule

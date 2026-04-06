// Threshold detector hysterisis

module threshold_detector_hystersis #(parameter HIGH_THRESH = 200,
                                      parameter LOW_THRESH = 100 )
  ( input logic clk,
    input logic rst_n,
    input logic x_valid,
   input logic [7:0] x_in,
   output logic detected );
  
  typedef enum logic{
    DETECTED = 1'b1, 
    NOT_DETECTED = 1'b0}state_t;
  
  state_t current, next;
  
  // pipeline registers
  logic detected_d;
  
  always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      current <= NOT_DETECTED;
    end else begin
    if (x_valid)
        current <= next;
  end
  end
  
  always_comb begin
    next = current; 
    detected  = (current == DETECTED) ; // driving the o/p from the state
    
    case(current)
      NOT_DETECTED: begin
        if(x_in > HIGH_THRESH)
          next = DETECTED;
      end
      
      DETECTED: begin
                if (x_in < LOW_THRESH)
                    next = NOT_DETECTED; // drop below LOW to turn OFF
            end
      
      default: next = NOT_DETECTED;
    endcase
  end
  
        
endmodule

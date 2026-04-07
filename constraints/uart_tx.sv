// UART_TX 

module uart_tx #(parameter CLK_PER_BIT = 5208)
  ( input logic clk,
   input logic rst_n,
   input logic tx_start,
   input logic [7:0] tx_data,
   output logic tx,
   output logic tx_busy,
   output logic tx_done );
  
  typedef enum logic[1:0] {
    IDLE = 2'b00,
    START = 2'b01,
    DATA = 2'b10,
    STOP = 2'b11
  } state_t ;
  
  state_t current_state,next_state;
  
  logic [12:0] baud_count;
  logic [7:0] shift_reg;
  logic [3:0] bit_count;
  
  //block1 state register- sequential
  always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end
  
  //block2 register values
  always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      baud_count <= '0;
      bit_count <= '0;
      shift_reg <= '0;
      tx_done <= '0;
    end else begin
      tx_done <= '0; // default deassert
      
      case(current_state)
        
        IDLE:begin
          baud_count <= '0;
          bit_count <= '0;
          if(tx_start)
            shift_reg <= tx_data;
        end 
                
        START:begin
          if(baud_count == CLK_PER_BIT-1)begin
            baud_count <= '0;
            bit_count <= '0;
          end else begin
            baud_count <= baud_count + 1;
          end
        end
        
        DATA:begin
          if(baud_count == CLK_PER_BIT-1)begin
            baud_count <= '0;
            shift_reg <= {1'b0, shift_reg[7:1]}; // shift right
            bit_cnt   <= bit_cnt + 1;
          end else
            baud_count <= baud_count + 1;
        end
        
        STOP:begin
          if(baud_count == CLK_PER_BIT-1)begin
            baud_count <= '0;
            tx_done <= 1'b1;
          end else 
            baud_count <= baud_count + 1;
        end
        
      endcase
      
      
    end
  end
  
  //block3: next state
  always_comb begin
    current_state = next_state; // default 
    
    case(current_state)
      IDLE: if(tx_start) next_state = START;
      START: if(baud_cnt == CLKS_PER_BIT-1) next_state = DATA;
      DATA:  if (baud_cnt == CLKS_PER_BIT-1 && bit_cnt==7) next_state = STOP;
      STOP:  if (baud_cnt == CLKS_PER_BIT-1) next_state = IDLE;
      default: next_state = IDLE;
    endcase
  end
  
  //block 4 outputs only 
  always_comb begin
        tx      = 1'b1;
        tx_busy = 1'b0;
        case (current_state)
            IDLE:  begin tx=1'b1; tx_busy=1'b0; end
            START: begin tx=1'b0; tx_busy=1'b1; end
            DATA:  begin tx=shift_reg[0]; tx_busy=1'b1; end
            STOP:  begin tx=1'b1; tx_busy=1'b1; end
        endcase
    end

  
endmodule

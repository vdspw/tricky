// Code your design here

`timescale 1ns / 1ps


module FramerBlock (
    input  logic        clk,
    input  logic        reset_n,

    input  logic        use_256_points, // creates full sample with 256
    input  logic        overlap_half_window, // overlap 50 % of the values 
	input  logic [6:0]  frame_skip_count, // skipping the frames

	input  logic        adc_valid, // valid -ready signals for the handshake (ADC)
	input  logic [7:0]  adc_data,  

	input  logic        ddi_valid, // direct data injection (DDI) 
    input  logic [7:0]  ddi_data,

    input  logic        window_ready, 
    output logic        window_valid,
    output logic [7:0]  window_data,

    output logic        adc_power_on,
    output logic        adc_data_required
);

  	//configuaration validation
  	logic config_valid;
   	//illegal config-- overlap and frame skip together should'nt be enabled at the same time .
  	always_comb begin
      config_valid = 1'b1;
      if(overlap_half_window && (frame_skip_count !=7'd0))begin
        config_valid = 1'b0;
    end
    end
  
    // FSM states --fsm1
    localparam FR_NONE = 2'd0; // when the number of samples in it is LESS than 63
    localparam FR_HALF = 2'd1; // when the number of samples in it is 63
    localparam FR_FULL = 2'd2; // when the number of samples is 128 or 256
	//Fsm2
    localparam IDLE = 1'b0; // stays in this state when there are LESS than 63 samples 
    localparam EMIT = 1'b1; // enters this state when the FSM1 reaches FR_FULL.

  // SRAM (256 x 8)
	logic [7:0] sram [0:255]; // every entry is 8 bit wide and there are 256 entries like that.

    logic [7:0] sample_write_index;
    logic [7:0] sample_read_index;
    logic [7:0] sample_read_count;
    logic [7:0] sample_read_base;

    logic [1:0] frame_state;
    logic       emit_state;
    logic [7:0] frame_counter;

    // pipeline reg
    logic at_boundary_detected;

    
	logic [8:0] frame_size; // we can have frame size(FR_FULL) to have 128 samples or 256 
    assign frame_size = use_256_points ? 9'd256 : 9'd128; // if use_256_points is enabled 

	logic [8:0] emit_frame_size; // frame size to emit
	assign emit_frame_size = overlap_half_window ? (frame_size >> 1) : frame_size; // if overlap frame size is reduced by half ( div by 2) -> right shift

    logic at_emit_boundary;
    assign at_emit_boundary = ((sample_write_index + 1) % emit_frame_size) == 0;

  logic should_write_sram;
  assign should_write_sram = config_valid &&(overlap_half_window ? 1'b1 :
                           (frame_counter % (frame_skip_count + 1)) == 0 );

    // comb block -- power port config
    always_comb begin
      if(!config_valid)begin
        adc_power_on = 1'b0; // illegal configuration should cut off the power to the module
        adc_data_required = 1'b0; // illegal config will not help to accept the data from the ADC
      end else if (frame_skip_count <= 1) begin
        adc_power_on = 1'b1; // if skip count is less than 1 or equal to 1 no point in switching , keep the power supply to the ADC.
        adc_data_required = 1'b1;
      end else begin
        logic[7:0] current_frame_num;
        current_frame_num = sample_write_index/frame_size; // gives the present frame number operations are going on 
        adc_data_required = (current_frame_num %(frame_skip_count+1))==0;
        adc_power_on = (current_frame_num + 1) %(frame_skip_count +1)==0;
      end
        
    end

    // seq block
    always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin							// neg edge reset 
			for (int i = 0; i < 256; i++) sram[i] <= 8'd0;  // fill all the SRAM locations with zeros
            sample_write_index <= 8'd0;  // write pointer is at 0 
            sample_read_index  <= 8'd0;  // read pointer is at 0
            sample_read_count  <= 8'd0;  // read count is 0
            sample_read_base   <= 8'd0;  // read base is 0
            frame_state        <= FR_NONE;  // frame state is at initial state FR_NONE
            emit_state         <= IDLE;   // emit state is at IDLE 
            frame_counter      <= 8'd0;   // frame counter is reset to 0
            window_valid       <= 1'b0;   
            window_data        <= 8'd0;
        end else begin
            window_valid <= 1'b0;
            window_data  <= 8'd0;

            // Reset 
            at_boundary_detected = 1'b0;
			
          if(config_valid)begin
            // Write
            if (adc_valid) begin
                if (should_write_sram) begin
					sram[sample_write_index] <= adc_data;  // writng the ADC data in the SRAM 
                end
                if (at_emit_boundary) at_boundary_detected = 1'b1;
                sample_write_index <= sample_write_index + 1;
            end

            // DDI
            if (ddi_valid) begin
                sram[sample_write_index] <= ddi_data;
                sample_write_index <= sample_write_index + 1;
            end

            // next state --FSM
            if (at_boundary_detected) begin
                if (overlap_half_window) begin
                    if (frame_state == FR_NONE) frame_state <= FR_HALF;
                    else if (frame_state == FR_HALF) frame_state <= FR_FULL;
                end else begin
                    if (should_write_sram) frame_state <= FR_FULL;
                    frame_counter <= frame_counter + 1;
                end
            end

            // Emit state
            if (emit_state == EMIT && window_ready) begin
                window_valid <= 1'b1;
                window_data  <= sram[sample_read_index];
                sample_read_count <= sample_read_count + 1;
                sample_read_index <= sample_read_index + 1;

                if (sample_read_count + 1 >= frame_size) begin
                    emit_state <= IDLE;
                    if (overlap_half_window) begin
                        sample_read_base <= sample_read_base + (frame_size >> 1);
                        frame_state      <= FR_HALF;
                    end else begin
                        frame_state      <= FR_NONE;
                        sample_read_base <= sample_read_index + 1;
                    end
                end
            end
            else if (emit_state == IDLE && frame_state == FR_FULL) begin
                emit_state        <= EMIT;
                sample_read_count <= 8'd0;
                sample_read_index <= sample_read_base;
            end
        end
    end
    end

endmodule



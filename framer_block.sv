// Code your design here

`timescale 1ns / 1ps


module FramerBlock (
    input  logic        clk,
    input  logic        reset_n,

    input  logic        use_256_points,
    input  logic        overlap_half_window,
    input  logic [6:0]  frame_skip_count,

    input  logic        adc_valid,
    input  logic [7:0]  adc_data,

    input  logic        ddi_valid,
    input  logic [7:0]  ddi_data,

    input  logic        window_ready,
    output logic        window_valid,
    output logic [7:0]  window_data,

    output logic        adc_power_on,
    output logic        adc_data_required
);

    // FSM states
    localparam FR_NONE = 2'd0;
    localparam FR_HALF = 2'd1;
    localparam FR_FULL = 2'd2;

    localparam IDLE = 1'b0;
    localparam EMIT = 1'b1;

  // SRAM (256 x 8)
    logic [7:0] sram [0:255];

    logic [7:0] sample_write_index;
    logic [7:0] sample_read_index;
    logic [7:0] sample_read_count;
    logic [7:0] sample_read_base;

    logic [1:0] frame_state;
    logic       emit_state;
    logic [7:0] frame_counter;

    // pipeline reg
    logic at_boundary_detected;

    
    logic [8:0] frame_size;
    assign frame_size = use_256_points ? 9'd256 : 9'd128;

    logic [8:0] emit_frame_size;
    assign emit_frame_size = overlap_half_window ? (frame_size >> 1) : frame_size;

    logic at_emit_boundary;
    assign at_emit_boundary = ((sample_write_index + 1) % emit_frame_size) == 0;

    logic should_write_sram;
    assign should_write_sram = overlap_half_window ? 1'b1 :
                              (frame_counter % (frame_skip_count + 1)) == 0;

    // comb block -- power port config
    always_comb begin
        if (frame_skip_count <= 1) begin
            adc_power_on      = 1'b1;
            adc_data_required = 1'b1;
        end else begin
            logic [7:0] current_frame_num;
            current_frame_num = sample_write_index / frame_size;
            adc_data_required = (current_frame_num % (frame_skip_count + 1)) == 0;
            adc_power_on      = ((current_frame_num + 1) % (frame_skip_count + 1)) == 0;
        end
    end

    // seq block
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (int i = 0; i < 256; i++) sram[i] <= 8'd0;
            sample_write_index <= 8'd0;
            sample_read_index  <= 8'd0;
            sample_read_count  <= 8'd0;
            sample_read_base   <= 8'd0;
            frame_state        <= FR_NONE;
            emit_state         <= IDLE;
            frame_counter      <= 8'd0;
            window_valid       <= 1'b0;
            window_data        <= 8'd0;
        end else begin
            window_valid <= 1'b0;
            window_data  <= 8'd0;

            // Reset 
            at_boundary_detected = 1'b0;

            // Write
            if (adc_valid) begin
                if (should_write_sram) begin
                    sram[sample_write_index] <= adc_data;
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

endmodule



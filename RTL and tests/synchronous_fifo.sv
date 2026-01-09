// Synchronous FIFO //
module fifo #(parameter DATAWIDTH = 32,
              parameter DEPTH = 8,
              localparam PTRWIDTH = $clog2(DEPTH)
             )
  (
    input logic clk, rstn,
    input logic write_en,
    input logic read_en,
    input logic [DATAWIDTH - 1:0] write_data,
    output logic [DATAWIDTH - 1:0] read_data,
    output logic full,
    output logic empty 
 );
 
  // creation of the memory space
  logic [DATAWIDTH -1:0] mem[0:DEPTH-1];
 
  // we need a write and read pointer to read or write in the memory locations
  logic [PTRWIDTH :0] wrptr, wrptrnext; // contains one extra bit.
  logic [PTRWIDTH :0] rdptr, rdptrnext; // contains one extra bit.
 
  // combinational block
  always_comb begin
    wrptrnext = wrptr; // if there is no change stay with the old value
    rdptrnext = rdptr; // if there is no change stay with the old value
    if (write_en) begin
      wrptrnext = wrptr + 1;  // Cleaner: implicit 1
    end
    if (read_en) begin
      rdptrnext = rdptr + 1;
    end
  end
 
  // sequential logic
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      wrptr <= '0; // erasing the values
      rdptr <= '0;
    end else begin
      wrptr <= wrptrnext; // latch the values from the comb_block.
      rdptr <= rdptrnext;
      if (write_en) begin
        mem[wrptr[PTRWIDTH -1:0]] <= write_data;  // Fixed casing
      end
    end
  end
 
  // reading the data
  assign read_data = mem[rdptr[PTRWIDTH -1:0]];  // Fixed casing
 
  // flag logics
  assign empty = (wrptr[PTRWIDTH] == rdptr[PTRWIDTH]) && (wrptr[PTRWIDTH -1:0] == rdptr[PTRWIDTH -1:0]); // when the MSB (extra) bit is equal and lower bits are also equal
 
  assign full = (wrptr[PTRWIDTH] != rdptr[PTRWIDTH]) && (wrptr[PTRWIDTH -1:0] == rdptr[PTRWIDTH -1:0]);
endmodule

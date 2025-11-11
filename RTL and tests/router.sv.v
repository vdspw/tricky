/* Simple router design 
 
 inputs:
    - data_in: input data bus
    - addr: address bus to determine output port
outputs:
    - data_out0: output data bus for port 0
    - data_out1: output data bus for port 1
    - data_out2: output data bus for port 2
    - data_out3: output data bus for port 3
             +---------------------+
din          |                     | 
             |       ROUTER        | 
             |                     |--> data_out0
             |                     |--> data_out1
             |                     |--> data_out2
             |                     |--> data_out3
din_en       |       ROUTER        |
addr         |                     |
             |                     |
             +---------------------+

*/

module router #(paramter 
DATA_WIDTH = 32)
(
    input   [DATA_WIDTH-1:0] data_in,
    input data_en
    input   [ADDR_WIDTH-1:0] addr,
    output reg   [DATA_WIDTH-1:0] data_out0,
    output logic [DATA_WIDTH-1:0] data_out1,
    output logic  [DATA_WIDTH-1:0] data_out2,
    output reg  [DATA_WIDTH-1:0] data_out3
);
assign data_out0 = (din_en  && addr ==  0 )? din: 0;
assign data_out1= (din_en  && addr ==  1) ? din:0;
assign data_out2= (din_en  && addr ==  2) ? din:0;
assign data_out3= (din_en  && addr ==  3) ? din:0;

endmodule
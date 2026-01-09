// Binary to Gray RTL Design (Generic Width)
module b_t_g #(
    parameter WIDTH = 4  // Default 4-bit
) (
    input  logic [WIDTH-1:0] b_ip,  // Binary input [WIDTH-1:0]
    output logic [WIDTH-1:0] g_op   // Gray output [WIDTH-1:0]
);

    always_comb begin
        // MSB unchanged (bit WIDTH-1)
        g_op[WIDTH-1] = b_ip[WIDTH-1];
        
        // Loop for lower bits: g[i] = b[i] ^ b[i+1]
        for (int i = WIDTH-2; i >= 0; i--) begin
            g_op[i] = b_ip[i] ^ b_ip[i+1];
        end
    end

endmodule

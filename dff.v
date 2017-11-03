//------------------------------------------------------------------------
// General DFF
//   Parameterized width (in bits)
//------------------------------------------------------------------------

module dff
#(parameter width = 1)
(
input                   clk,            // Global FPGA Clock
input                   clockEdge,      // Device Clock Edge
input       [width-1:0] D,              // Input
output reg  [width-1:0] Q               // Output
    );

    always @(posedge clk) begin
        if (clockEdge) begin
            Q <= D;
        end
    end
endmodule

//------------------------------------------------------------------------
// Shift Register
//   Parameterized width (in bits)
//   Shift register can operate in two modes:
//      - serial in, parallel out
//      - parallel in, serial out
//------------------------------------------------------------------------

module shiftregister
#(parameter width = 8)
(
input               clk,                // FPGA Clock
input               peripheralClkEdge,  // Edge indicator
input               parallelLoad,       // 1 = Load shift reg with parallelDataIn
input  [width-1:0]  parallelDataIn,     // Load shift reg in parallel
input               serialDataIn,       // Load shift reg serially
output [width-1:0]  parallelDataOut,    // Shift reg data contents
output              serialDataOut       // Positive edge synchronized
);

    reg [width-1:0]      shiftRegisterMem;

    assign parallelDataOut = shiftRegisterMem;
    assign serialDataOut = shiftRegisterMem[width-1];

    always @(posedge clk) begin
        if (parallelLoad) begin
            shiftRegisterMem <= parallelDataIn;
        end
        else if (peripheralClkEdge) begin
            shiftRegisterMem <= { shiftRegisterMem[width-2:0], serialDataIn };
        end
    end
endmodule

//------------------------------------------------------------------------------
// Midpoint checkin 8-bit shift register with input conditioners
//------------------------------------------------------------------------------
`include "shiftregister.v"
`include "inputconditioner.v"

module midpoint(
input           clk,
input           button0,
input           switch0,
input           switch1,
input  [7:0]    parallelDataIn,
output [7:0]    parallelDataOut
                );

    wire serialDataIn;
    wire peripheralClkEdge;
    wire parallelLoad;

    // instantiate shift register
    shiftregister shiftreg (clk, peripheralClkEdge, parallelLoad, parallelDataIn, serialDataIn, parallelDataOut, );

    // instantiate input conditioner on button0
    inputconditioner but0inputcond (clk, button0, , , parallelLoad);

    // instantiate input conditioner on switch0
    inputconditioner sw0inputcond (clk, switch0, serialDataIn, , );

    // instantiate input conditioner on switch1
    inputconditioner sw1inputcond (clk, switch1, , peripheralClkEdge, );

endmodule

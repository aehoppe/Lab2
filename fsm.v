//------------------------------------------------------------------------
// FSM
//------------------------------------------------------------------------

module FSM
(
    input           sclk,         // FPGA clock
    input           cs_pin,       // SPI chip select
    input           shiftReg0,    // SPI master out slave in
    output reg      addr_WE,      //Control signal
    output reg      miso_BUFE,    //Control signal
    output reg      DM_WE,        //Control signal
    output reg      SR_WE         //Control signal
);

  reg[3:0] counter;
  reg[7:0] bitmap;

  reg [5:0] state;
	localparam IDLE = 6'b000000,


endmodule

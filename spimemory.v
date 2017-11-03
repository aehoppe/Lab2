//------------------------------------------------------------------------
// SPI Memory
//------------------------------------------------------------------------

`include "inputconditioner.v"
`include "datamemory.v"
`include "shiftregister.v"
`include "fsm.v"
`include "buffer.v"
`include "dff.v"

module spiMemory
(
    input           clk,        // FPGA clock
    input           sclk_pin,   // SPI clock
    input           cs_pin,     // SPI chip select
    output          miso_pin,   // SPI master in slave out
    input           mosi_pin,   // SPI master out slave in
    output [3:0]    leds,        // LEDs for debugging
    output [7:0]    state
);

  wire serial_in;
  wire sclk_posedge;
  wire sclk_negedge;
  wire cs;

  wire miso_bufe;
  wire dm_we;
  wire addr_we;
  wire sr_we;

  wire [7:0] shift_reg_out_P;
  wire [7:0] data_mem_out;
  wire serial_out;

  wire [7:0] address_latch_out;
  wire [6:0] address;

  wire miso;

  assign address = address_latch_out[6:0];

  inputconditioner mosi_ic(
    .clk(clk),
    .noisysignal(mosi_pin),
    .conditioned(serial_in),
    .positiveedge(),
    .negativeedge()
  );

  inputconditioner sclk_ic(
    .clk(clk),
    .noisysignal(sclk_pin),
    .conditioned(),
    .positiveedge(sclk_posedge),
    .negativeedge(sclk_negedge)
  );

  inputconditioner cs_ic(
    .clk(clk),
    .noisysignal(cs_pin),
    .conditioned(cs),
    .positiveedge(),
    .negativeedge()
  );

  FSM fsm(
    .clk(clk),
    .sclk(sclk_posedge),
    .cs_pin(cs),
    .shiftReg0(mosi_pin),
    .addr_WE(addr_we),
    .miso_BUFE(miso_bufe),
    .DM_WE(dm_we),
    .SR_WE(sr_we),
    .state(state)
  );

  shiftregister shift_reg(
    .clk(clk),
    .peripheralClkEdge(sclk_posedge),
    .parallelLoad(sr_we),
    .parallelDataIn(data_mem_out),
    .serialDataIn(serial_in),
    .parallelDataOut(shift_reg_out_P),
    .serialDataOut(serial_out)
  );

  datamemory data_mem(
    .clk(clk),
    .dataOut(data_mem_out),
    .address(address),
    .writeEnable(dm_we),
    .dataIn(shift_reg_out_P)
  );

  dff #(.width(8)) address_latch(
    .clk(clk),
    .clockEdge(addr_we),
    .D(shift_reg_out_P),
    .Q(address_latch_out)
  );

  dff serial_out_dff(
    .clk(clk),
    .clockEdge(sclk_negedge),
    .D(serial_out),
    .Q(miso)
  );

  buffer miso_buffer(
    .in(miso),
    .en(miso_bufe),
    .out(miso_pin)
  );

endmodule

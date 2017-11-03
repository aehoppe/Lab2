//------------------------------------------------------------------------
// TestBench
//------------------------------------------------------------------------

`timescale 1 ns / 1 ps
`include "fsm.v"

module fsmtestbench();
  wire          clk;          // FPGA clock
  wire          sclk;         // SPI clock
  wire          cs_pin;       // SPI chip select
  wire          shiftReg0;    // SPI master out slave in
  wire          addr_WE;      //Control signal
  wire          miso_BUFE;    //Control signal
  wire          DM_WE;        //Control signal
  wire          SR_WE;         //Control signal
  wire[7:0]          state;

  reg begintest;
  wire dutpassed;
  wire endtest;

  FSM dut(
    .clk(clk),
    .sclk(sclk),
    .cs_pin(cs_pin),
    .shiftReg0(shiftReg0),
    .addr_WE(addr_WE),
    .miso_BUFE(miso_BUFE),
    .DM_WE(DM_WE),
    .SR_WE(SR_WE),
    .state(state)
  );

  fsmtester tester(
    .begintest(begintest),
    .endtest(endtest),
    .dutpassed(dutpassed),
    .clk(clk),
    .sclk(sclk),
    .cs_pin(cs_pin),
    .shiftReg0(shiftReg0),
    .addr_WE(addr_WE),
    .miso_BUFE(miso_BUFE),
    .DM_WE(DM_WE),
    .SR_WE(SR_WE),
    .state(state)
  );

  initial begin
    $dumpfile("fsm.vcd");
    $dumpvars(0, dut);
    begintest=0;
    #10;
    begintest=1;
    #100000;
  end

  always @(posedge endtest) begin
    $display("DUT passed?: %b", dutpassed);
  end
endmodule

module fsmtester(
  input begintest,
  output reg endtest,
  output reg dutpassed,

  output reg      clk,          // FPGA clock
  output reg      sclk,         // SPI clock
  output reg      cs_pin,       // SPI chip select
  output reg      shiftReg0,    // SPI master out slave in
  input           addr_WE,      //Control signal
  input           miso_BUFE,    //Control signal
  input           DM_WE,        //Control signal
  input           SR_WE,         //Control signal
  input[7:0]      state          // state of FSM
);
  reg[7:0] testnum;
  reg statecorrect;
  function statecheck;
    input[7:0] ourstate, correctstate;
    begin
      statecheck = (1 === (ourstate === correctstate));
    end
  endfunction
  function dutcheck;
    input check, check2, dutpassed;
    reg inter;
    begin
      // Demonstrates driving external Global Reg
      inter  = (check == check2);
      dutcheck = (inter & dutpassed);
    end
  endfunction

  function[7:0] dutprint;
    input[7:0] state;
    input integer testnum;
    input dutpassed;
    begin
      if(dutpassed === 1)begin
        $display("Test %d Passed:  State is %b", testnum, state);
      end else begin
        $display("Test %d Failed:  State is %b", testnum, state);
      end
      dutprint = testnum + 1;
    end
  endfunction
  initial begin
    clk=0;
    sclk=0;
    cs_pin=1;
    shiftReg0=0;
    testnum = 0;
    statecorrect = 0;
  end

  always #10 clk=!clk;

  always #500 sclk=!sclk;

  always @(posedge begintest) begin
    endtest = 0;
    dutpassed = 1;

    #1100;

    //** WRITE TEST **//

    // IDLE
    statecorrect = statecheck(state, 8'b00000001);

    dutpassed = dutcheck(0, addr_WE, dutpassed);
    dutpassed = dutcheck(0, miso_BUFE, dutpassed);
    dutpassed = dutcheck(0, DM_WE, dutpassed);
    dutpassed = dutcheck(0, SR_WE, dutpassed);
    dutpassed = dutcheck(1, statecorrect, dutpassed);

    testnum = dutprint(state, testnum, dutpassed);



    // ADDRESS
    cs_pin = 0;
    repeat(6)
    begin
      #1000;
      statecorrect = statecheck(state, 8'b00000010);

      dutpassed = dutcheck(0, addr_WE, dutpassed);
      dutpassed = dutcheck(0, miso_BUFE, dutpassed);
      dutpassed = dutcheck(0, DM_WE, dutpassed);
      dutpassed = dutcheck(0, SR_WE, dutpassed);
      dutpassed = dutcheck(1, statecorrect, dutpassed);

      testnum = dutprint(state, testnum, dutpassed);
    end

    // ADDRESS_WRITE

    #1000;
    statecorrect = statecheck(state, 8'b00000100);


    dutpassed = dutcheck(1, addr_WE, dutpassed);
    dutpassed = dutcheck(0, miso_BUFE, dutpassed);
    dutpassed = dutcheck(0, DM_WE, dutpassed);
    dutpassed = dutcheck(0, SR_WE, dutpassed);
    dutpassed = dutcheck(1, statecorrect, dutpassed);

    testnum = dutprint(state, testnum, dutpassed);

    // WRITE_WAIT
    repeat(8)
    begin
      #1000;
      statecorrect = statecheck(state, 8'b00001000);


      dutpassed = dutcheck(0, addr_WE, dutpassed);
      dutpassed = dutcheck(0, miso_BUFE, dutpassed);
      dutpassed = dutcheck(0, DM_WE, dutpassed);
      dutpassed = dutcheck(0, SR_WE, dutpassed);
      dutpassed = dutcheck(1, statecorrect, dutpassed);

      testnum = dutprint(state, testnum, dutpassed);
    end

    // WRITE_MEM

    #1000;
    statecorrect = statecheck(state, 8'b00010000);


    dutpassed = dutcheck(0, addr_WE, dutpassed);
    dutpassed = dutcheck(0, miso_BUFE, dutpassed);
    dutpassed = dutcheck(1, DM_WE, dutpassed);
    dutpassed = dutcheck(0, SR_WE, dutpassed);
    dutpassed = dutcheck(1, statecorrect, dutpassed);

    testnum = dutprint(state, testnum, dutpassed);

    // DONE
    #1000;
    statecorrect = statecheck(state, 8'b10000000);


    dutpassed = dutcheck(0, addr_WE, dutpassed);
    dutpassed = dutcheck(0, miso_BUFE, dutpassed);
    dutpassed = dutcheck(0, DM_WE, dutpassed);
    dutpassed = dutcheck(0, SR_WE, dutpassed);
    dutpassed = dutcheck(1, statecorrect, dutpassed);

    testnum = dutprint(state, testnum, dutpassed);

    // IDLE
    cs_pin = 1;
    #1000;
    statecorrect = statecheck(state, 8'b00000001);


    dutpassed = dutcheck(0, addr_WE, dutpassed);
    dutpassed = dutcheck(0, miso_BUFE, dutpassed);
    dutpassed = dutcheck(0, DM_WE, dutpassed);
    dutpassed = dutcheck(0, SR_WE, dutpassed);
    dutpassed = dutcheck(1, statecorrect, dutpassed);

    testnum = dutprint(state, testnum, dutpassed);

    if(dutpassed)begin
      $display("You must be a scholar, cuz your writing is on point! (Write Command Passed; %d Tests Passed)", testnum);
    end else begin
      $display("F-F-F-FAILURE! (Write Command Failed)");
    end

    //** READ TEST **//

    shiftReg0 = 1;
    testnum = 0;
    //IDLE
    #1000;
    statecorrect = statecheck(state, 8'b00000001);


    dutpassed = dutcheck(0, addr_WE, dutpassed);
    dutpassed = dutcheck(0, miso_BUFE, dutpassed);
    dutpassed = dutcheck(0, DM_WE, dutpassed);
    dutpassed = dutcheck(0, SR_WE, dutpassed);
    dutpassed = dutcheck(1, statecorrect, dutpassed);

    testnum = dutprint(state, testnum, dutpassed);

    // ADDRESS
    cs_pin = 0;
    repeat(6)
    begin
      #1000;
      statecorrect = statecheck(state, 8'b00000010);

      dutpassed = dutcheck(0, addr_WE, dutpassed);
      dutpassed = dutcheck(0, miso_BUFE, dutpassed);
      dutpassed = dutcheck(0, DM_WE, dutpassed);
      dutpassed = dutcheck(0, SR_WE, dutpassed);
      dutpassed = dutcheck(1, statecorrect, dutpassed);

      testnum = dutprint(state, testnum, dutpassed);
    end

    // ADDRESS_WRITE

    #1000;
    statecorrect = statecheck(state, 8'b00000100);


    dutpassed = dutcheck(1, addr_WE, dutpassed);
    dutpassed = dutcheck(0, miso_BUFE, dutpassed);
    dutpassed = dutcheck(0, DM_WE, dutpassed);
    dutpassed = dutcheck(0, SR_WE, dutpassed);
    dutpassed = dutcheck(1, statecorrect, dutpassed);

    testnum = dutprint(state, testnum, dutpassed);

    // READ_START

    #1000;
    statecorrect = statecheck(state, 8'b00100000);


    dutpassed = dutcheck(0, addr_WE, dutpassed);
    dutpassed = dutcheck(1, miso_BUFE, dutpassed);
    dutpassed = dutcheck(0, DM_WE, dutpassed);
    dutpassed = dutcheck(1, SR_WE, dutpassed);
    dutpassed = dutcheck(1, statecorrect, dutpassed);

    testnum = dutprint(state, testnum, dutpassed);

    // READ

    repeat(7)
    begin
      #1000;
      statecorrect = statecheck(state, 8'b01000000);


      dutpassed = dutcheck(0, addr_WE, dutpassed);
      dutpassed = dutcheck(1, miso_BUFE, dutpassed);
      dutpassed = dutcheck(0, DM_WE, dutpassed);
      dutpassed = dutcheck(0, SR_WE, dutpassed);
      dutpassed = dutcheck(1, statecorrect, dutpassed);

      testnum = dutprint(state, testnum, dutpassed);
    end

    // DONE

    #1000;
    statecorrect = statecheck(state, 8'b10000000);


    dutpassed = dutcheck(0, addr_WE, dutpassed);
    dutpassed = dutcheck(0, miso_BUFE, dutpassed);
    dutpassed = dutcheck(0, DM_WE, dutpassed);
    dutpassed = dutcheck(0, SR_WE, dutpassed);
    dutpassed = dutcheck(1, statecorrect, dutpassed);

    testnum = dutprint(state, testnum, dutpassed);

    // IDLE
    cs_pin = 1;
    #1000;
    statecorrect = statecheck(state, 8'b00000001);


    dutpassed = dutcheck(0, addr_WE, dutpassed);
    dutpassed = dutcheck(0, miso_BUFE, dutpassed);
    dutpassed = dutcheck(0, DM_WE, dutpassed);
    dutpassed = dutcheck(0, SR_WE, dutpassed);
    dutpassed = dutcheck(1, statecorrect, dutpassed);

    testnum = dutprint(state, testnum, dutpassed);


    if(dutpassed)begin
      $display("Oh Dang Son! Your page turning is on fire!! (Read Command Passed; %d Tests Passed)", testnum);
    end else begin
      $display("F-F-F-FAILURE! (Read Command Failed)");
    end
    endtest = 1;
    $finish;

  end
endmodule

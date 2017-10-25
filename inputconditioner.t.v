//------------------------------------------------------------------------
// Input Conditioner test bench
//------------------------------------------------------------------------
`timescale 1 ns / 1 ps
`include "inputconditioner.v"


module testConditioner();

    wire clk;
    wire pin;
    wire conditioned;
    wire rising;
    wire falling;

    reg begintest;
    wire dutpassed;
    wire endtest;

    inputconditioner dut(.clk(clk),
    			 .noisysignal(pin),
			 .conditioned(conditioned),
			 .positiveedge(rising),
			 .negativeedge(falling));

    inputconditionertester tester
    (
      .begintest(begintest),
      .endtest(endtest),
      .dutpassed(dutpassed),
      .pin(pin),
      .clk(clk),
      .conditioned(conditioned),
      .rising(rising),
      .falling(falling)
    );

   initial begin
     $dumpfile("inputconditioner.vcd");
     $dumpvars(0, dut);
     begintest=0;
     #10;
     begintest=1;
     #10000;

   end

   // Display test results ('dutpassed' signal) once 'endtest' goes high
   always @(posedge endtest) begin
     $display("DUT passed?: %b", dutpassed);
   end


    // Generate clock (50MHz)
    //initial clk=0;
    /*always begin
      if (testrun == 1)
        #10 clk=!clk;    // 50MHz Clock
    end*/
    //always #10 clk=!clk;

    /*initial begin
      $dumpfile("inputconditioner.vcd");
      $dumpvars(0, dut);
      pin = 0; #1
      pin = 1; #1
      pin = 0; #2
      pin = 1; #2
      pin = 0; #5
      pin = 1; #5
      pin = 0; #10
      pin = 1; #10
      pin = 0; #20
      pin = 1; #20
      pin = 0; #40
      pin = 1; #40
      pin = 0; #80
      pin = 1; #80
      pin = 0; #160
      pin = 1; #160
      pin = 0; #320
      pin = 1; #320
      $finish;
    end*/
    // Your Test Code
    // Be sure to test each of the three conditioner functions:
    // Synchronization, Debouncing, Edge Detection

endmodule


module inputconditionertester
(
  input begintest,
  output reg endtest,
  output reg dutpassed,

  output reg pin,
  output reg clk,
  input conditioned,
  input rising,
  input falling
  );
  initial begin
    pin=0;
    clk=0;
  end

  always #10 clk=!clk;

  always @(posedge begintest) begin
    endtest = 0;
    dutpassed = 1;
    #100;


    //*** Syncronization Testing Here (???) ***//
    /*pin = 1; #1; pin = 0; #1;
    pin = 1; #1; pin = 0; #1;
    pin = 1; #1; pin = 0; #1;
    pin = 1; #1; pin = 0; #1;
    pin = 1; #1; pin = 0; #1;
    pin = 1; #1; pin = 0; #1;
    pin = 1; #1; pin = 0; #1;
    pin = 1; #1; pin = 0; #1;
    pin = 1; #1; pin = 0; #50;*/
    //If the clock actually had a set and hold time, this signal would cause synchronizer0 to probably have a glitch
    //which synchronizer1 would then remove.

    if(conditioned==1) begin
      $display("Your synchronization is looking on point! (Passed Synchronizer Testing)");
    end

    //*** Debouncing Testing Here ***//
    pin = 1; #40;#1;

    if((conditioned == 1)) begin
      dutpassed = 0;	// Set to 'false' on failure
      $display("Conditioned signal activated at 10 ns of signal. (Test Failed)");
    end

    pin = 0; #200;#19;

    pin = 1; #60;#1;

    if((conditioned == 1)) begin
      dutpassed = 0;	// Set to 'false' on failure
      $display("Conditioned signal activated at 20 ns of signal. (Test Failed)");
    end

    pin = 0; #200;#19;
    pin = 1; #80;#1;

    if((conditioned == 1)) begin
      dutpassed = 0;	// Set to 'false' on failure
      $display("Conditioned signal activated at 30 ns of signal. (Test Failed)");
    end

    pin = 0; #200;#19;
    pin = 1; #100;#1;

    if((conditioned == 0)) begin
      dutpassed = 0;	// Set to 'false' on failure
      $display("Conditioned signal failed to activate at 40 ns of signal. (Test Failed)");
    end

    pin = 0; #200;#19;

    if(dutpassed == 1) begin
      $display("Nice going, Your debouncer works hella fine. (Passed Debouncer Testing)");
    end

    //*** Edge Detection Testing ***//

    pin = 0; #200
    pin = 1; #80; #1;

    if(rising == 1) begin
      dutpassed = 0;
      $display("Rising set too early");
    end
    #20
    if(rising == 0) begin
      dutpassed = 0;
      $display("Rising not set correctly");
    end
    #20
    if(rising == 1) begin
      dutpassed = 0;
      $display("Rising set too late");
    end

    #19;

    pin = 0; #80 #1;

    if(falling == 1) begin
      dutpassed = 0;
      $display("Falling set too early");
    end
    #20
    if(falling == 0) begin
      dutpassed = 0;
      $display("Falling not set correctly");
    end
    #20
    if(falling == 1) begin
      dutpassed = 0;
      $display("Falling set too late");
    end

    #19;

    if(dutpassed == 1) begin
      $display("You really know how to live on the edge! (Passed Edge Detection testing)");
    end

    endtest = 1;

    $finish;
  end

endmodule

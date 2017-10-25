//------------------------------------------------------------------------
// Input Conditioner test bench
//------------------------------------------------------------------------
`timescale 1 ns / 1 ps
`include "inputconditioner.v"


module testConditioner();

    reg clk;
    reg pin;
    wire conditioned;
    wire rising;
    wire falling;

    reg testrun;

    inputconditioner dut(.clk(clk),
    			 .noisysignal(pin),
			 .conditioned(conditioned),
			 .positiveedge(rising),
			 .negativeedge(falling));


    // Generate clock (50MHz)
    initial clk=0;
    /*always begin
      if (testrun == 1)
        #10 clk=!clk;    // 50MHz Clock
    end*/
    always #10 clk=!clk;

    initial begin
      $dumpfile("inputconditioner.vcd");
      $dumpvars(0, dut);
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
    end
    // Your Test Code
    // Be sure to test each of the three conditioner functions:
    // Synchronization, Debouncing, Edge Detection

endmodule

//------------------------------------------------------------------------
// Shift Register test bench
//------------------------------------------------------------------------
`timescale 1 ns / 1 ps
`include "shiftregister.v"

module testshiftregister();

    // instantiate test registers
    reg             clk;
    reg             peripheralClkEdge;
    reg             parallelLoad;
    wire[7:0]       parallelDataOut;
    wire            serialDataOut;
    reg[7:0]        parallelDataIn;
    reg             serialDataIn;

    // Instantiate with parameter width = 8
    shiftregister #(8) dut(.clk(clk),
    		           .peripheralClkEdge(peripheralClkEdge),
    		           .parallelLoad(parallelLoad),
    		           .parallelDataIn(parallelDataIn),
    		           .serialDataIn(serialDataIn), 
    		           .parallelDataOut(parallelDataOut),
    		           .serialDataOut(serialDataOut));

    // instatiate test helper variables
    reg testpassed = 1;
    reg [3:0] index;
    reg [7:0] expected;
    reg s_expected;

    // Generate clock (50MHz)
    initial clk=0;
    always #10 clk=!clk;    // 50MHz Clock

    initial begin
    $dumpfile("shiftregister.vcd");
    $dumpvars(0, dut);

    peripheralClkEdge = 0; #20
    // Set all data to 0, also do a serial data in and see if it is lower priority
    serialDataIn = 1; parallelDataIn = 8'd0; parallelLoad = 1; #20
    peripheralClkEdge = 1; #10 peripheralClkEdge = 0; parallelLoad = 0; #100
    expected = 8'd0;
    if (parallelDataOut != expected) begin
        $display("Test initial parallel set failed, expected pout:%b, got pout:%b", expected, parallelDataOut);
        testpassed = 0;
    end

    // Shift in ones and make sure it's working
    for (index = 0; index < 8; index = index + 1) begin
        serialDataIn = 1; parallelDataIn = 8'd0; parallelLoad = 0; peripheralClkEdge = 1; #20
        peripheralClkEdge = 0; #100
        expected = ~(8'b11111110 << index);
        if (parallelDataOut != expected) begin
            $display("Test shift in 1s failed, expected pout:%b, got pout:%b", expected, parallelDataOut);
            testpassed = 0;
        end
        s_expected = parallelDataOut[7];
        if (serialDataOut != s_expected) begin
            $display("Test shift in 1s failed, expected sout:%b, got sout:%b", s_expected, serialDataOut);
            testpassed = 0;
        end
    end

    // Shift in zeros and make sure it's working
    for (index = 0; index < 8; index = index + 1) begin
        serialDataIn = 0; parallelDataIn = 8'd0; parallelLoad = 0; peripheralClkEdge = 1; #20
        peripheralClkEdge = 0; #100
        expected = 8'b11111110 << index;
        if (parallelDataOut != expected) begin
            $display("Test shift in 0s failed, expected pout:%b, got pout:%b", expected, parallelDataOut);
            testpassed = 0;
        end
        s_expected = parallelDataOut[7];
        if (serialDataOut != s_expected) begin
            $display("Test shift in 0s failed, expected sout:%b, got sout:%b", s_expected, serialDataOut);
            testpassed = 0;
        end
    end

    // Display if we've finished it or not
    if (testpassed) begin
        $display("Tests passed");
    end

    $finish;
    end

endmodule

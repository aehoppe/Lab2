//-------------------------------------------------------------------------------------------
// Testbench for complete SPI memory module
//-------------------------------------------------------------------------------------------

`timescale 1 ns / 1 ps
`include "spimemory.v"

module testSpiMemory();

  wire          clk;        // FPGA clock
  wire          sclk_pin;   // SPI clock
  wire          cs_pin;     // SPI chip select
  wire          miso_pin;   // SPI master in slave out
  wire          mosi_pin;   // SPI master out slave in
  wire [3:0]    leds;        // LEDs for debugging
  wire [7:0]    state;

  reg begintest;
  wire dutpassed;
  wire endtest;

  spiMemory dut(.clk(clk),
                .sclk_pin(sclk_pin),
                .cs_pin(cs_pin),
                .miso_pin(miso_pin),
                .mosi_pin(mosi_pin),
                .leds(leds),
                .state(state));

  spiMemoryTester tester(.begintest(begintest),
                      .endtest(endtest),
                      .dutpassed(dutpassed),
                      .clk(clk),
                      .sclk_pin(sclk_pin),
                      .cs_pin(cs_pin),
                      .mosi_pin(mosi_pin),
                      .miso_pin(miso_pin));

  initial begin
    $dumpfile("spimemory.vcd");
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

endmodule

module spiMemoryTester (
  input begintest,
  output reg endtest,
  output reg dutpassed,

  output reg clk,
  output reg sclk_pin,
  output reg cs_pin,
  output reg mosi_pin,
  input miso_pin
  );

  // Global registers
  reg [6:0] address;
  reg [7:0] rx_data;
  reg [7:0] tx_data;
  reg [7:0] expected;

  // Define clock
  initial clk = 0;
  always #10 clk=!clk;

  // Run test sequence
  always @(posedge begintest) begin
    cs_pin = 1;
    sclk_pin = 1;
    mosi_pin = 1;#10000

    // Basic write test
    address = 7'd10;
    tx_data = 8'd47;
    write_spi(address, tx_data); #10000;
    read_spi(address);

    if (rx_data != tx_data | rx_data === 8'bx) begin
      dutpassed = 0;
      $display("Test SPI writeback failed, wrote %d to %b, got %d", tx_data, address, rx_data);
    end

    #100000;

    //Write all zeros, get all zeros, write all ones get all ones
    address = 7'd56;
    tx_data = 8'b00000000; #10000
    write_spi(address, tx_data); #10000;
    read_spi(address);
    if (rx_data != tx_data | rx_data === 8'bx) begin
      dutpassed = 0;
      $display("Test SPI write zeros failed, wrote %d to %b, got %d", tx_data, address, rx_data);
    end

    #10000;

    //Write all zeros, get all zeros, write all ones get all ones
    address = 7'd56;
    tx_data = 8'b11111111;
    write_spi(address, tx_data); #10000;
    read_spi(address);
    if (rx_data != tx_data | rx_data === 8'bx) begin
      dutpassed = 0;
      $display("Test SPI write ones failed, wrote %d to %b, got %d", tx_data, address, rx_data);
    end

    #10000;

    //Write various different addresses, then read them back
    address = 7'd0; tx_data = 8'd0;
    write_spi(address, tx_data); #10000
    address = 7'd1; tx_data = 8'd1;
    write_spi(address, tx_data); #10000
    address = 7'd2; tx_data = 8'd2;
    write_spi(address, tx_data); #10000
    address = 7'd3; tx_data = 8'd4;
    write_spi(address, tx_data); #10000
    address = 7'd4; tx_data = 8'd8;
    write_spi(address, tx_data); #10000
    address = 7'd5; tx_data = 8'd16;
    write_spi(address, tx_data); #10000

    address = 7'd0; tx_data = 8'd0;
    read_spi(7'd0);
    if (rx_data != 8'd0 | rx_data === 8'bx) begin
      dutpassed = 0;
      $display("Test SPI multiple write failed, wrote %d to %b, got %d", 8'd0, 7'd0, rx_data);
    end #10000;

    address = 7'd1; tx_data = 8'd1;
    read_spi(7'd1);
    if (rx_data != 8'd1 | rx_data === 8'bx) begin
      dutpassed = 0;
      $display("Test SPI multiple write failed, wrote %d to %b, got %d", 8'd1, 7'd1, rx_data);
    end #10000;

    address = 7'd2; tx_data = 8'd2;
    read_spi(7'd2);
    if (rx_data != 8'd2 | rx_data === 8'bx) begin
      dutpassed = 0;
      $display("Test SPI multiple write failed, wrote %d to %b, got %d", 8'd2, 7'd2, rx_data);
    end #10000;

    address = 7'd3; tx_data = 8'd4;
    read_spi(7'd3);
    if (rx_data != 8'd4 | rx_data === 8'bx) begin
      dutpassed = 0;
      $display("Test SPI multiple write failed, wrote %d to %b, got %d", 8'd4, 7'd3, rx_data);
    end #10000;

    address = 7'd4; tx_data = 8'd8;
    read_spi(7'd4);
    if (rx_data != 8'd8 | rx_data === 8'bx) begin
      dutpassed = 0;
      $display("Test SPI multiple write failed, wrote %d to %b, got %d", 8'd8, 7'd4, rx_data);
    end #10000;

    address = 7'd5; tx_data = 8'd16;
    read_spi(7'd5);
    if (rx_data != 8'd16 | rx_data === 8'bx) begin
      dutpassed = 0;
      $display("Test SPI multiple write failed, wrote %d to %b, got %d", 8'd16, 7'd5, rx_data);
    end #10000;

    $finish;
  end


  // Define helper tasks to do SPI transactions
  task read_spi;
    input [6:0] address;
    integer idx;
    begin
      // Begin transaction and clock in address
      cs_pin = 0; #1000;
      for (idx = 0; idx < 7; idx = idx+1) begin
        sclk_pin = 0;
        mosi_pin = address[6 - idx];#1000; // Present data on negative edge
        sclk_pin = 1;#1000; // Return clock high
      end
      // Read-Write bit
      sclk_pin = 0;
      mosi_pin = 1;#1000 // Read
      sclk_pin = 1;#1000
      // Read Back Data
      for (idx = 0; idx < 8; idx = idx + 1) begin
        sclk_pin = 0;#1000 // Negative edge to prompt data
        sclk_pin = 1;
        rx_data[7-idx] = miso_pin;#1000; // Read at positive edge
      end
      #1000;
      // Release CS
      cs_pin = 1;

    end
  endtask

  task write_spi;
    input [6:0] address;
    input [7:0] tx_data;
    integer idx;
    begin
      // Begin transaction and clock in address
      cs_pin = 0; #1000;
      for (idx = 0; idx < 7; idx = idx+1) begin
        sclk_pin = 0;
        mosi_pin = address[6 - idx];#1000; // Present data on negative edge
        sclk_pin = 1;#1000; // Return clock high
      end
      // Read-Write bit
      sclk_pin = 0;
      mosi_pin = 0;#1000 // Write
      sclk_pin = 1;#1000
      //Clock in data
      for (idx = 0; idx < 8; idx = idx+1) begin
        sclk_pin = 0;
        mosi_pin = tx_data[7 - idx];#1000; // Present data on negative edge
        sclk_pin = 1;#1000; // Return clock high
      end
      #1000;
      //Release CS
      cs_pin=1;
    end
  endtask

endmodule

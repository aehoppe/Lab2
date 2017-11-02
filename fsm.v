//------------------------------------------------------------------------
// FSM
//------------------------------------------------------------------------

module FSM
(
    input           clk,          // FPGA clock
    input           sclk,         // SPI clock
    input           cs_pin,       // SPI chip select
    input           shiftReg0,    // SPI master out slave in
    output reg      addr_WE,      //Control signal
    output reg      miso_BUFE,    //Control signal
    output reg      DM_WE,        //Control signal
    output reg      SR_WE         //Control signal
);

  reg[2:0] counter;
  //reg[7:0] bitmap;

  reg [5:0] state;
	localparam IDLE = 6'b000001, ADDRESS = 6'b000010, ADDRESS_WRITE = 6'b000100, WRITE = 6'b001000, READ_START = 6'b010000,  READ = 6'b100000, DONE;

  always @(posedge sclk) begin
    if(state == 6'bx) begin
      state <= IDLE;
    end else begin
      case(state)
        IDLE:
          if(cs_pin == 0) begin
            state <= ADDRESS;
            counter <= 3'b000;
          end else if (cs_pin == 1) begin
            state <= IDLE;
          end

        ADDRESS:
          if(counter < 5) begin
            state <= ADDRESS;
            counter <= counter + 3'b001;
          end else begin
            state <= ADDRESS_WRITE;
          end

        ADDRESS_WRITE:begin
          // addr_WE <= 1;

          counter <= 3'b000;
          if(shiftReg0) begin
            state <= READ;
          end else begin
            state <= WRITE;
          end

        READ_START: begin
          //SR_WE
          //miso_BUFE
          state <= READ;
        end

        READ:
          //miso_BUFE
          if(counter < 6) begin
            state <= READ;
            counter <= counter + 3'b001;
          end else begin
            state <= DONE;
          end

        WRITE_START:
          if(counter)

        DONE:
          if(cs_pin == 0)begin
            state <= IDLE;
          end else begin
            state <= DONE;
          end

        endcase


      end
    end

endmodule

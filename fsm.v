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
    output reg      SR_WE,         //Control signal
    output reg[7:0] state
);

  reg[2:0] counter;
  //reg[7:0] bitmap;

  //reg [7:0] state;

	localparam
  IDLE = 8'b00000001,
  ADDRESS = 8'b00000010,
  ADDRESS_WRITE = 8'b00000100,
  WRITE_WAIT = 8'b00001000,
  WRITE_MEM = 8'b00010000,
  READ_START = 8'b00100000,
  READ = 8'b01000000,
  DONE = 8'b10000000;

  initial state = IDLE;

  always @(posedge cs_pin) begin
    state = IDLE;
  end

  always @(posedge sclk) begin
    //if(state == 8'bx) begin
    //  state <= IDLE;
    //end else begin
    case(state)
      IDLE: begin
        //currstate <= IDLE;
        if(cs_pin == 0) begin
          state = ADDRESS;
          counter <= 3'b000;
        end else if (cs_pin == 1) begin
          state = IDLE;
        end
      end

      ADDRESS: begin
        //currstate <= ADDRESS;
        if(counter < 5) begin
          state = ADDRESS;
          counter <= counter + 3'b001;
        end else begin
          state = ADDRESS_WRITE;
        end
      end

      ADDRESS_WRITE: begin
        //currstate <= ADDRESS_WRITE;
        // addr_WE <= 1;
        counter <= 3'b000;
        if(shiftReg0) begin
          state = READ_START;
        end else begin
          state = WRITE_WAIT;
        end
      end

      READ_START: begin
        //currstate = READ_START;
        //SR_WE
        //miso_BUFE
        state = READ;
      end

      READ: begin
        //miso_BUFE
        //currstate = READ;
        if(counter < 6) begin
          state = READ;
          counter <= counter + 3'b001;
        end else begin
          state = IDLE;
        end
      end

      WRITE_WAIT: begin
        //currstate = WRITE_WAIT;
        if(counter < 7) begin
          state = WRITE_WAIT;
          counter <= counter + 3'b001;
        end else begin
          state = WRITE_MEM;
        end
      end

      WRITE_MEM: begin
        //currstate = WRITE_MEM;
        state = IDLE;
        //DM_WE
      end
    endcase
    case (state)
      //driving - follow traffic laws
      IDLE: begin
        addr_WE <= 0;
        miso_BUFE <= 0;
        DM_WE <= 0;
        SR_WE <= 0;
      end


      ADDRESS: begin
        addr_WE <= 0;
        miso_BUFE <= 0;
        DM_WE <= 0;
        SR_WE <= 0;
      end


      ADDRESS_WRITE: begin
        addr_WE <= 1;
        miso_BUFE <= 0;
        DM_WE <= 0;
        SR_WE <= 0;
      end

      READ_START:begin
        addr_WE <= 0;
        miso_BUFE <= 1;
        DM_WE <= 0;
        SR_WE <= 1;
      end

      READ:begin
        addr_WE <= 0;
        miso_BUFE <= 1;
        DM_WE <= 0;
        SR_WE <= 0;
      end

      WRITE_WAIT:begin
        addr_WE <= 0;
        miso_BUFE <= 0;
        DM_WE <= 0;
        SR_WE <= 0;
      end

      WRITE_MEM:begin
        addr_WE <= 0;
        miso_BUFE <= 0;
        DM_WE <= 1;
        SR_WE <= 0;
      end
    endcase
  end

endmodule

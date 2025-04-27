import Utils :: *;
import Fifo :: *;
import Ehr :: *;

interface Debouncer;
  (* always_ready, always_enabled *)
  method Action receive(Bool in);

  method Bool out;
endinterface

module mkDebouncer(Debouncer);
  Wire#(Bool) _wire <- mkBypassWire;

  Reg#(Bit#(3)) counter <- mkReg(0);

  Reg#(Bit#(3)) state <- mkReg(0);

  rule update;
    if (state[0] == state[1])
      counter <= counter < maxBound ? counter + 1 : maxBound;
    else
      counter <= 0;

    state <= {counter == maxBound ? state[0] : state[2], state[0],_wire?1:0};
  endrule

  method out = state[2] == 1;
  method receive = _wire._write;
endmodule

interface PS2;
  (* always_ready, always_enabled *)
  method Action receive(Bool clk, Bool data);

  method ActionValue#(Bit#(32)) get;
endinterface

typedef enum {Idle, Busy} State deriving(Bits, FShow, Eq);

module mkPS2(PS2);
  Reg#(Bit#(32)) buffer <- mkReg(0);
  Reg#(Bit#(32)) old <- mkReg(0);
  Fifo#(100, Bit#(32)) fifo <- mkFifo;
  Reg#(Bool) prevClk <- mkReg(False);

  let debData <- mkDebouncer;
  let data = debData.out;

  let debClk <- mkDebouncer;
  let clk = debClk.out;

  Reg#(State) state <- mkReg(Idle);
  Reg#(Bit#(32)) counter <- mkReg(0);

  Ehr#(2, Bit#(32)) timer <- mkEhr(0);
  Reg#(Bit#(32)) timerReg <- mkReg(0);

  rule updateClk;
    prevClk <= clk;
    timer[1] <= timer[1] + 1;
  endrule

  rule testClk(prevClk && !clk);
    timerReg <= timer[0];
    timer[0] <= 0;
  endrule

  rule idle if (state == Idle && prevClk && !clk); //  && !data
    if (buffer != 0)
      fifo.enq(buffer);
    //if (buffer != 0)
    //  old <= buffer;

    counter <= 31;
    state <= Busy;
    buffer <= 0;
  endrule

  rule busy if (prevClk && !clk && state == Busy);
    if (timer[0] >= 9000000) state <= Idle;
    else if (counter == 0) state <= Idle;

    counter <= counter - 1;

    buffer <= {truncate(buffer), pack(data)};
  endrule

  method ActionValue#(Bit#(32)) get;
    //return old;
    fifo.deq;
    return fifo.first;
    //return {
    //  0,
    //  fifo.first[0],
    //  fifo.first[1],
    //  fifo.first[2],
    //  fifo.first[3],
    //  fifo.first[4],
    //  fifo.first[5],
    //  fifo.first[6],
    //  fifo.first[7],
    //  fifo.first[8],
    //  fifo.first[9]
    //};
  endmethod

  method Action receive(Bool c, Bool d);
    action
      debClk.receive(c);
      debData.receive(d);
    endaction
  endmethod
endmodule

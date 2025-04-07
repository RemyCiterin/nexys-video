import Printable :: *;
import BlockRam :: *;
import GetPut :: *;
import Utils :: *;
import UART :: *;
import Fifo :: *;
import Ehr :: *;

(* always_enabled, always_ready *)
interface TOP;
  (* prefix="" *)
  method Bit#(1) uart_tx;

  (* prefix="" *)
  method Action uart_rx((* port="uart_rx" *)Bit#(1) rx);

  (* prefix="" *)
  method Bit#(8) led;
endinterface

(* synthesize *)
module mkTop(TOP);
  TxUART txUART <- mkTxUART(723);
  RxUART rxUART <- mkRxUART(723);

  String helloWorld = "Hello world!\n";

  Put#(void) printer <- mkStringPrinter(txUART, helloWorld);

  //Put#(Bit#(32)) printer <- mkPrinter(txUART);

  Reg#(Bit#(32)) cycle <- mkReg(0);

  rule countCycle;
    cycle <= cycle + 1;
  endrule

  rule printCycle;
    //printer.put(cycle);
    printer.put(?);
  endrule

  method uart_tx = txUART.transmit;
  method uart_rx = rxUART.receive;
  method led = txUART.debug;
endmodule

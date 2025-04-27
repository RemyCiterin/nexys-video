import Printable :: *;
import BlockRam :: *;
import GetPut :: *;
import Utils :: *;
import UART :: *;
import Fifo :: *;
import Ehr :: *;
import PS2 :: *;

(* always_enabled, always_ready *)
interface TOP;
  (* prefix="" *)
  method Bit#(1) uart_tx;

  (* prefix="" *)
  method Action uart_rx((* port="uart_rx" *)Bit#(1) rx);

  (* prefix="" *)
  method Bit#(8) led;

  (* prefix="" *)
  method Action ps2_ports((* port="ps2_clk" *)Bool clk, (* port="ps2_data" *)Bool data);
endinterface

(* synthesize *)
module mkTop(TOP);
  TxUART txUART <- mkTxUART(723);
  RxUART rxUART <- mkRxUART(723);

  String helloWorld = "Hello world!\n";

  //Put#(void) printer <- mkStringPrinter(txUART, helloWorld);

  Put#(Bit#(32)) printer <- mkPrinter(txUART);

  Reg#(Bit#(32)) cycle <- mkReg(0);

  PS2 ps2_controller <- mkPS2;

  rule countCycle;
    cycle <= cycle + 1;
  endrule

  rule printCycle;
    let buffer <- ps2_controller.get;
    printer.put(truncate(buffer));
    //printer.put(?);
  endrule

  method uart_tx = txUART.transmit;
  method uart_rx = rxUART.receive;
  method ps2_ports = ps2_controller.receive;
  method led = txUART.debug;
endmodule

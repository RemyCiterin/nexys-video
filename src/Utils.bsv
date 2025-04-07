package Utils;

import FIFOF :: *;

typedef Bit#(TMul#(8, n)) Byte#(numeric type n);
typedef Bit#(TMul#(16, n)) Half#(numeric type n);
typedef Bit#(TMul#(32, n)) Word#(numeric type n);

module mkEmptyFIFOF(FIFOF#(t)) provisos (Bits#(t, size_t));

  method Bool notEmpty = False;
  method Bool notFull = False;

  method t first if (False);
    return ?;
  endmethod

  method Action deq if (False);
    noAction;
  endmethod

  method Action enq(t value) if (False);
    noAction;
  endmethod

  method clear = noAction;
endmodule

endpackage

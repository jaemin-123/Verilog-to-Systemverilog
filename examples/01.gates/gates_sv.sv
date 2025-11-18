`timescale 1ns/1ps
`default_nettype none

module gates_sv (
  input  logic iA,
  input  logic iB,
  output logic oAND,
  output logic oOR,
  output logic oNOT,
  output logic oNAND,
  output logic oNAND2
);

  logic s0;

  // 순수 조합논리
  always_comb begin
    oAND   = iA & iB;
    oOR    = iA | iB;
    oNOT   = ~iA;
    oNAND  = ~(iA & iB);

    s0     = iA & iB;
    oNAND2 = ~s0;
  end

endmodule

`default_nettype wire

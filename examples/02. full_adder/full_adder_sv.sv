`timescale 1ns/1ps
`default_nettype none

module full_adder_sv (
  input  logic iX,
  input  logic iY,
  input  logic iCIN,
  output logic oSUM,
  output logic oCARRY
);

  logic s0, c0, c1;

  // 순수 조합논리
  always_comb begin
    s0     = iX ^ iY;
    c0     = iX & iY;
    c1     = s0 & iCIN;
    oSUM   = s0 ^ iCIN;
    oCARRY = c0 | c1;
  end

endmodule

`default_nettype wire

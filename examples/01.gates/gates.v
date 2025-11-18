// 자료
// module gates (iA, iB, oAND, oOR, oNOT, oNAND, oNAND2);
//   input iA, iB;
//   output oAND, oOR, oNOT, oNAND, oNAND2;

//   wire s0;
//   and U0 (oAND, iA, iB);
//   or U1 (oOR, iA, iB);
//   not U2 (oNOT, iA);
//   nand U3 (oNAND, iA, iB);
//   and U4 (s0, iA, iB);
//   not U5 (oNAND2, s0);

// endmodule

// gpt 수정
`timescale 1ns/1ps
`default_nettype none

module gates (
  input wire iA, iB,
  output wire oAND, oOR, oNOT, oNAND, oNAND2
);
  wire s0;

  and U0 (oAND, iA, iB);
  or U1 (oOR, iA, iB);
  not U2 (oNOT, iA);
  nand U3 (oNAND, iA, iB);
  and U4 (s0, iA, iB);
  not U5 (oNAND2, s0);
endmodule

`default_nettype wire

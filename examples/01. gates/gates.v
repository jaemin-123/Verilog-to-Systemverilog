module gates (iA, iB, oAND, oOR, oNOT, oNAND, oNAND2);
  input iA, iB;
  output oAND, oOR, oNOT, oNAND, oNAND2;

  wire s0;
  and U0 (oAND, iA, iB);
  or U1 (oOR, iA, iB);
  not U2 (oNOT, iA);
  nand U3 (oNAND, iA, iB);
  and U4 (s0, iA, iB);
  not U5 (oNAND2, s0);

endmodule


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

`timescale 1ns/1ps

module tb_gates;
  reg iA, iB;
  wire oAND, oOR, oNOT, oNAND, oNAND2;
  // 이름에 의한 포트 맵핑 사용하여 gates를 인스턴스화
  gates U0 (
  .iA (iA), // 입력신호 iA
  .iB (iB), // 입력신호 iB
  .oAND (oAND), // 출력신호 oAND
  .oOR (oOR), // 출력신호 oOR
  .oNOT (oNOT), // 출력신호 oNOT
  .oNAND (oNAND), // 출력신호 oNAND
  .oNAND2 (oNAND2)); // 출력신호 oNAND2;
  // 입력신호 생성
  initial begin
    iA = 0; iB = 0; #100;
    iA = 0; iB = 1; #100;
    iA = 1; iB = 0; #100;
    iA = 1; iB = 1; #100;
    $stop;
  end

endmodule
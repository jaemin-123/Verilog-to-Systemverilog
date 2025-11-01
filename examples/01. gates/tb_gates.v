// 교재
// `timescale 1ns/1ps

// module tb_gates;
//   reg iA, iB;
//   wire oAND, oOR, oNOT, oNAND, oNAND2;
//   // 이름에 의한 포트 맵핑 사용하여 gates를 인스턴스화
//   gates U0 (
//   .iA (iA), // 입력신호 iA
//   .iB (iB), // 입력신호 iB
//   .oAND (oAND), // 출력신호 oAND
//   .oOR (oOR), // 출력신호 oOR
//   .oNOT (oNOT), // 출력신호 oNOT
//   .oNAND (oNAND), // 출력신호 oNAND
//   .oNAND2 (oNAND2)); // 출력신호 oNAND2;
//   // 입력신호 생성
//   initial begin
//     iA = 0; iB = 0; #100;
//     iA = 0; iB = 1; #100;
//     iA = 1; iB = 0; #100;
//     iA = 1; iB = 1; #100;
//     $stop;
//   end

// endmodule

// gpt
`timescale 1ns/1ps

module tb_gates;
  logic iA, iB;
  wire  oAND, oOR, oNOT, oNAND, oNAND2;

  // DUT (Verilog 버전)
  gates dut (
    .iA(iA), .iB(iB),
    .oAND(oAND), .oOR(oOR), .oNOT(oNOT),
    .oNAND(oNAND), .oNAND2(oNAND2)
  );

  // 파형 덤프
  initial begin
    $dumpfile("vcd/gates.vcd");
    $dumpvars(0, tb_gates);
  end

  // 기대값 함수
  function automatic void expect(input logic a, b);
    logic exp_and   = a &  b;
    logic exp_or    = a |  b;
    logic exp_not   = ~a;
    logic exp_nand  = ~(a & b);
    #1; // 전파 대기
    if (oAND   !== exp_and)  $fatal(1, "AND mismatch: exp=%0b got=%0b",  exp_and,  oAND);
    if (oOR    !== exp_or)   $fatal(1, "OR  mismatch: exp=%0b got=%0b",  exp_or,   oOR);
    if (oNOT   !== exp_not)  $fatal(1, "NOT mismatch: exp=%0b got=%0b",  exp_not,  oNOT);
    if (oNAND  !== exp_nand) $fatal(1, "NAND mismatch: exp=%0b got=%0b", exp_nand, oNAND);
    if (oNAND2 !== exp_nand) $fatal(1, "NAND2 mismatch: exp=%0b got=%0b",exp_nand, oNAND2);
  endfunction

  // 테스트 시퀀스
  initial begin
    iA=0; iB=0; expect(iA,iB);
    iA=0; iB=1; expect(iA,iB);
    iA=1; iB=0; expect(iA,iB);
    iA=1; iB=1; expect(iA,iB);
    $display("PASS: gates");
    $finish;
  end
endmodule

module mux41 (iA,iB,iC,iD,iSEL,oOUT); 
    input [7:0] iA,iB,iC,iD;
    input [1:0] iSEL;
    output [7:0] oOUT;

    assign oOUT = (iSEL == 0) ? iA:
                (iSEL == 1) ? iB:
                (iSEL == 2) ? iC:iD    
endmodule

module top_mux41(
  input  wire [1:0] iSEL_sw, // SW1:MSB, SW0:LSB
  input  wire BTN_A,         // -> iA[0]
  input  wire BTN_B,         // -> iB[0]
  input  wire BTN_C,         // -> iC[0]
  input  wire BTN_D,         // -> iD[0]
  output wire LED0           // oOUT[0]만 표시
);
  // 8비트 입력을 최소화: 상위 7비트는 0, LSB는 버튼
  wire [7:0] iA = {7'b0, BTN_A};
  wire [7:0] iB = {7'b0, BTN_B};
  wire [7:0] iC = {7'b0, BTN_C};
  wire [7:0] iD = {7'b0, BTN_D};

  wire [7:0] oOUT;

  mux41 U0(
    .iA(iA), 
    .iB(iB), 
    .iC(iC), 
    .iD(iD),
    .iSEL(iSEL_sw),
    .oOUT(oOUT)
  );

  assign LED0 = oOUT[0]; // LSB만 LED로 확인
endmodule


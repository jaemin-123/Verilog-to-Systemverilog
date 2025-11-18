`timescale 1ns/1ps
`default_nettype none

module mux41_sv (
  input  logic [7:0] iA,
  input  logic [7:0] iB,
  input  logic [7:0] iC,
  input  logic [7:0] iD,
  input  logic [1:0] iSEL,
  output logic [7:0] oOUT
);

  // 4:1 MUX – 선택 신호에 따라 입력 하나 선택
  always_comb begin
    unique case (iSEL)
      2'd0: oOUT = iA;
      2'd1: oOUT = iB;
      2'd2: oOUT = iC;
      default: oOUT = iD;
    endcase
  end

endmodule

`default_nettype wire

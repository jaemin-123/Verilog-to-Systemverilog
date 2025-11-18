`timescale 1ns/10ps
`default_nettype none

module ALU_sv (
  input  logic [3:0] iA,
  input  logic [3:0] iB,
  input  logic [3:0] iINST,
  output logic [7:0] oRESULT
);

  // 순수 조합논리 ALU
  always_comb begin
    oRESULT = '0;   // 기본값 (default 대비)

    unique case (iINST)
      4'h0:  oRESULT = iA +  iB;   // ADD
      4'h1:  oRESULT = iA -  iB;   // SUB
      4'h2:  oRESULT = iA *  iB;   // MUL
      4'h3:  oRESULT = iA /  iB;   // DIV
      4'h4:  oRESULT = iA %  iB;   // MOD

      4'h5:  oRESULT = ~iA;        // BIT_NOT
      4'h6:  oRESULT = iA &  iB;   // BIT_AND
      4'h7:  oRESULT = iA |  iB;   // BIT_OR
      4'h8:  oRESULT = iA ^  iB;   // BIT_XOR
      4'h9:  oRESULT = iA ~^ iB;   // BIT_XNOR

      4'hA:  oRESULT =  &iA;       // RED_AND
      4'hB:  oRESULT =  |iA;       // RED_OR
      4'hC:  oRESULT = ~&iA;       // RED_NAND
      4'hD:  oRESULT =  ^iA;       // RED_XOR

      4'hE:  oRESULT = iA >> 1;    // RSHFT
      4'hF:  oRESULT = iA << 1;    // LSHFT

      default: oRESULT = '0;
    endcase
  end

endmodule

`default_nettype wire

`timescale 1ns/10ps
module ALU (iA, iB, iINST, oRESULT);
    input [3:0] iA, iB, iINST;
    output [7:0] oRESULT;

    reg [7:0] result;

    always @(iA or iB or iINST)begin
        case(iINST)
            4'h0 : result = iA + iB; // ADD
            4'h1 : result = iA - iB; // SUB
            4'h2 : result = iA * iB; // MUL
            4'h3 : result = iA / iB; // DIV
            4'h4 : result = iA % iB; // MOD
            4'h5 : result = ~iA;     // BIT_NOT
            4'h6 : result = iA & iB; // BIT_AND
            4'h7 : result = iA | iB; // BIT_OR
            4'h8 : result = iA ^ iB; // BIT_XOR
            4'h9 : result = iA ~^ iB;// BIT_XNOR
            4'ha : result = & iA;    // RED_AND
            4'hb : result = | iA;    // RED_OR
            4'hc : result = ~& iA;   // RED_NAND
            4'hd : result = ^ iA;    // RED_XOR
            4'he : result = iA >> 1; // iA를 1비트 우측 이동(RSHFT)
            4'hf : result = iA << 1; // iA를 1비트 좌측 이동(LSHFT)
        endcase
    end
    assign oRESULT = result;
endmodule
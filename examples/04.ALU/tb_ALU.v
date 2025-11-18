`timescale 1ns/10ps

module tb_ALU;
    reg [3:0] iA, iB, iINST;
    wire [7:0] oRESULT;

    ALU U0 (
        .iA (iA),
        .iB (iB),
        .iINST (iINST),
        .oRESULT (oRESULT)
    );

    initial begin
        iA = 4'ha; iB = 4'h6; iINST = 4'h0; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'h1; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'h2; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'h3; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'h4; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'h5; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'h6; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'h7; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'h8; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'h9; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'ha; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'hb; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'hc; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'hd; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'he; #100
        iA = 4'ha; iB = 4'h6; iINST = 4'hf; #100
        $finish;
    end
endmodule
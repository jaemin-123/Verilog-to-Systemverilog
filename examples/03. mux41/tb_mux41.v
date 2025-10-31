`timescale 1ns/10ps

module tb_mux41 
    reg [7:0] iA, iB, iC, iD;
    reg [1:0] iSEL;
    wire [7:0] oOUT;

    mux41 U0 (
        .iA (iA),
        .iB (iB),
        .iC (iC),
        .iD (iD),
        .iSEL (iSEL),
        .oOUT (oOUT));
    
    initial begin 
        iA = 8'h00; iB = 8'h01; iC = 8'h00; iD = 8'h00; iSEL = 2'b00; #100
        iA = 8'h00; iB = 8'h01; iC = 8'h00; iD = 8'h00; iSEL = 2'b01; #100
        iA = 8'h00; iB = 8'h01; iC = 8'h00; iD = 8'h00; iSEL = 2'b10; #100
        iA = 8'h00; iB = 8'h01; iC = 8'h00; iD = 8'h00; iSEL = 2'b11; #100
    end
    
endmodule
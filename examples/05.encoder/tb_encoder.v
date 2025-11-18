`timescale 1ns/10ps

module tb_encoder;

  reg [9:0] iIN;

  wire [3:0] oOUT;

  encoder U0 (
    .iIN (iIN), 
    .oOUT (oOUT));
    initial begin
        iIN = 10'b00_0000_0001;
        #100;
        iIN = 10'b00_0000_0010;
        #100;
        iIN = 10'b00_0000_0100;
        #100;
        iIN = 10'b00_0000_1000;
        #100;
        iIN = 10'b00_0001_0000;
        #100;
        iIN = 10'b00_0010_0000;
        #100;
        iIN = 10'b00_0100_0000;
        #100;
        iIN = 10'b00_1000_0000;
        #100;
        iIN = 10'b01_0000_0000;
        #100;
        iIN = 10'b10_0000_0000;
        #100;
        iIN = 10'b00_0000_0000;
        #100;
        $finish;
    end

endmodule
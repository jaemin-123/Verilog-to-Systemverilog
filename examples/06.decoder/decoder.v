`timescale 1ns/1ps
module decoder (iIN, oOUT);
  input [3:0] iIN;
  output [9:0] oOUT;

  reg [9:0] out;
  always @(iIN) begin
    case (iIN)
    0 : out = 10'b00_0000_0001;
    1 : out = 10'b00_0000_0010;
    2 : out = 10'b00_0000_0100;
    3 : out = 10'b00_0000_1000;
    4 : out = 10'b00_0001_0000;
    5 : out = 10'b00_0010_0000;
    6 : out = 10'b00_0100_0000;
    7 : out = 10'b00_1000_0000;
    8 : out = 10'b01_0000_0000;
    9 : out = 10'b10_0000_0000;
    default : out = 10'b11_1111_1111;
    endcase
  end
  assign oOUT = out;

endmodule
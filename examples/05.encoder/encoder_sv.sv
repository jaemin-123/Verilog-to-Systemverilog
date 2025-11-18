`timescale 1ns/10ps
`default_nettype none

// 10-to-4 Priority 없는 단순 Encoder
module encoder_sv (
  input  logic [9:0] iIN,
  output logic [3:0] oOUT
);

  always_comb begin
    unique case (iIN)
      10'b00_0000_0001: oOUT = 4'b0000;
      10'b00_0000_0010: oOUT = 4'b0001;
      10'b00_0000_0100: oOUT = 4'b0010;
      10'b00_0000_1000: oOUT = 4'b0011;
      10'b00_0001_0000: oOUT = 4'b0100;
      10'b00_0010_0000: oOUT = 4'b0101;
      10'b00_0100_0000: oOUT = 4'b0110;
      10'b00_1000_0000: oOUT = 4'b0111;
      10'b01_0000_0000: oOUT = 4'b1000;
      10'b10_0000_0000: oOUT = 4'b1001;
      default:          oOUT = 4'b1111;
    endcase
  end

endmodule

`default_nettype wire

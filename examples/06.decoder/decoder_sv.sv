`timescale 1ns/1ps
`default_nettype none

// 4-to-10 Decoder (one-hot, default 시 all 1)
module decoder_sv (
  input  logic [3:0] iIN,
  output logic [9:0] oOUT
);

  always_comb begin
    // 기본값
    oOUT = 10'b11_1111_1111;

    unique case (iIN)
      4'd0: oOUT = 10'b00_0000_0001;
      4'd1: oOUT = 10'b00_0000_0010;
      4'd2: oOUT = 10'b00_0000_0100;
      4'd3: oOUT = 10'b00_0000_1000;
      4'd4: oOUT = 10'b00_0001_0000;
      4'd5: oOUT = 10'b00_0010_0000;
      4'd6: oOUT = 10'b00_0100_0000;
      4'd7: oOUT = 10'b00_1000_0000;
      4'd8: oOUT = 10'b01_0000_0000;
      4'd9: oOUT = 10'b10_0000_0000;
      default: /* 위에서 이미 기본값 설정 */ ;
    endcase
  end

endmodule

`default_nettype wire

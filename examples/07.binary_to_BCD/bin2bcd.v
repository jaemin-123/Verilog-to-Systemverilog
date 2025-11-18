`timescale 1ns/10ps
module bin2bcd (iBIN, oBCD);
  input [7:0] iBIN;
  output [11:0] oBCD;

  reg [11:0] bcd;
  integer i;

  assign oBCD = bcd;
  // 더블-더블 알고리즘
  always @(iBIN) begin
    bcd = 12'b0;
    for (i = 0; i < 8; i = i + 1) begin
      if (bcd[3:0] >= 5)
      bcd[3:0] = bcd[3:0] + 3;
      else
      bcd[3:0] = bcd[3:0];
      if (bcd[7:4] >= 5)
      bcd[7:4] = bcd[7:4] + 3;
      else
      bcd[7:4] = bcd[7:4];
      if (bcd[11:8] >= 5)
      bcd[11:8] = bcd[11:8] + 3;
      else
      bcd[11:8] = bcd[11:8];
      bcd = {bcd[10:0], iBIN[7 - i]};
    end
  end

endmodule
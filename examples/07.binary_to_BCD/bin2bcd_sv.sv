`timescale 1ns/10ps
`default_nettype none

module bin2bcd_sv (
  input  logic [7:0]  iBIN,
  output logic [11:0] oBCD
);

  logic [11:0] bcd;
  int          i;

  // 더블-더블(double dabble) 알고리즘
  always_comb begin
    bcd = 12'b0;
    for (i = 0; i < 8; i = i + 1) begin
      if (bcd[3:0]  >= 5) bcd[3:0]  = bcd[3:0]  + 3;
      if (bcd[7:4]  >= 5) bcd[7:4]  = bcd[7:4]  + 3;
      if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
      bcd = {bcd[10:0], iBIN[7 - i]};
    end
  end

  assign oBCD = bcd;

endmodule

`default_nettype wire

`timescale 1ns/10ps
module tb_bin2bcd;
  reg [7:0] iBIN;
  wire [11:0] oBCD;
  bin2bcd UBIN2BCD (
  .iBIN (iBIN), 
  .oBCD (oBCD));
  initial begin
    iBIN = 8'b0; #20;
    while(iBIN < 8'b1111_1111) begin
      $display("iBIN = %b, oBCD = %b, Decimal Value : %d %d %d", iBIN, oBCD, oBCD[11:8], oBCD[7:4], oBCD[3:0]);
      iBIN = iBIN + 1; #20;
    end
    $finish;
  end

endmodule
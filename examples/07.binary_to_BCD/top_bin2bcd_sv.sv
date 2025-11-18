`timescale 1ns/10ps
`default_nettype none

// 14비트 Binary → 4자리 BCD (0000~9999)
// clk 포트는 기존 인터페이스를 유지하기 위해 남겨두지만, 조합 논리만 사용
module bin2bcd (
  input  logic        clk,   // (현재 로직에서는 미사용)
  input  logic [13:0] iBIN,
  output logic [15:0] oBCD
);

  logic [15:0] bcd;
  int          i;

  always_comb begin
    bcd = 16'b0;
    for (i = 0; i < 14; i = i + 1) begin
      if (bcd[3:0]   >= 5) bcd[3:0]   = bcd[3:0]   + 3;
      if (bcd[7:4]   >= 5) bcd[7:4]   = bcd[7:4]   + 3;
      if (bcd[11:8]  >= 5) bcd[11:8]  = bcd[11:8]  + 3;
      if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;
      bcd = {bcd[14:0], iBIN[13 - i]};
    end
  end

  assign oBCD = bcd;

endmodule


// 7-segment 디코더 (조합 논리)
module seven_seg_decoder (
  input  logic [3:0] digit,
  output logic [6:0] segments
);
  always_comb begin
    unique case (digit)
      4'h0: segments = 7'b1000000; // 0
      4'h1: segments = 7'b1111001; // 1
      4'h2: segments = 7'b0100100; // 2
      4'h3: segments = 7'b0110000; // 3
      4'h4: segments = 7'b0011001; // 4
      4'h5: segments = 7'b0010010; // 5
      4'h6: segments = 7'b0000010; // 6
      4'h7: segments = 7'b1111000; // 7
      4'h8: segments = 7'b0000000; // 8
      4'h9: segments = 7'b0010000; // 9
      default: segments = 7'b1111111;
    endcase
  end
endmodule


// Binary 입력을 받아 BCD 변환 후 7-segment 디스플레이 (4자리 지원)
module bin_to_7seg_display (
  input  logic        clk,           // 100MHz 클록
  input  logic        reset,         // 리셋 신호
  input  logic [13:0] binary_input,  // 14비트 이진수 입력 (0~9999)
  output logic [6:0]  seg,           // 7-segment 출력
  output logic [3:0]  an             // digit 선택 신호 (active low)
);

  // Binary to BCD 변환
  logic [15:0] bcd_output;

  bin2bcd bcd_converter (
    .clk (clk),          // 현재 로직에서는 미사용
    .iBIN(binary_input),
    .oBCD(bcd_output)
  );

  // 클록 분주기 - 디스플레이 다중화용
  logic [16:0] clk_divider;
  logic        refresh_clk;

  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      clk_divider <= '0;
    else
      clk_divider <= clk_divider + 1'b1;
  end

  assign refresh_clk = clk_divider[16]; // 약 763Hz

  // 디스플레이 선택 카운터 (2비트로 0~3 순환)
  logic [1:0] digit_select;

  always_ff @(posedge refresh_clk or posedge reset) begin
    if (reset)
      digit_select <= 2'b00;
    else
      digit_select <= digit_select + 2'b01;
  end

  // BCD에서 각 자리수 분리
  logic [3:0] digit0, digit1, digit2, digit3;

  assign digit0 = bcd_output[3:0];     // 일의 자리
  assign digit1 = bcd_output[7:4];     // 십의 자리
  assign digit2 = bcd_output[11:8];    // 백의 자리
  assign digit3 = bcd_output[15:12];   // 천의 자리

  // 현재 선택된 digit
  logic [3:0] current_digit;

  always_comb begin
    unique case (digit_select)
      2'b00: current_digit = digit0;
      2'b01: current_digit = digit1;
      2'b10: current_digit = digit2;
      default: current_digit = digit3;
    endcase
  end

  // Anode 제어 (active low)
  always_comb begin
    unique case (digit_select)
      2'b00: an = 4'b1110; // digit0
      2'b01: an = 4'b1101; // digit1
      2'b10: an = 4'b1011; // digit2
      default: an = 4'b0111; // digit3
    endcase
  end

  // 7-seg 디코더
  seven_seg_decoder u_seg_decoder (
    .digit   (current_digit),
    .segments(seg)
  );

endmodule


module test (
  input  logic clk,
  input  logic in_test,
  output logic out_test
);
  assign out_test = in_test;
endmodule


// 테스트를 위한 top 모듈
module top_module (
  input  logic        clk,
  input  logic [13:0] sw,    // 14비트 스위치 입력 (0~9999)
  input  logic        btnC,  // 센터 버튼 (리셋용)
  input  logic [13:0] sw1,
  input  logic [13:0] sw2,
  output logic [6:0]  seg,
  output logic [6:0]  seg1,
  output logic [3:0]  an
);

  // 리셋 동기화
  logic       reset_sync;
  logic [1:0] reset_ff;

  always_ff @(posedge clk) begin
    reset_ff   <= {reset_ff[0], btnC};
    reset_sync <= reset_ff[1];
  end

  // Binary to 7-segment 디스플레이 인스턴스 0
  bin_to_7seg_display display_inst0 (
    .clk         (clk),
    .reset       (reset_sync),
    .binary_input(sw),
    .seg         (seg),
    .an          (an)
  );

  // Binary to 7-segment 디스플레이 인스턴스 1
  // (※ 현재 seg, an을 공유하면 다중 드라이버가 될 수 있으니
  //    실제 구현/합성에서는 분리하거나 MUX로 합치는 걸 추천)
  bin_to_7seg_display display_inst1 (
    .clk         (clk),
    .reset       (reset_sync),
    .binary_input(sw1),
    .seg         (/* TODO: 별도 seg 신호로 분리 권장 */),
    .an          (/* TODO: 별도 an 신호로 분리 권장 */)
  );

  // 단순 패스스루 테스트
  test u_test (
    .clk     (clk),
    .in_test (sw2[0]),
    .out_test(seg1[0])
  );

endmodule

`default_nettype wire

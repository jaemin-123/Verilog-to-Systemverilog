module bin2bcd(clk, iBIN, oBCD);

 input clk;
 input [13:0] iBIN;
 output [15:0] oBCD;
 
 reg [15:0] bcd;

 integer i;

 assign oBCD = bcd;

 always @(iBIN) begin
  bcd = 16'b0;
  for (i = 0; i < 14; i = i + 1) begin
    if(bcd[3:0] >= 5)
	bcd[3:0] = bcd[3:0] + 3;
    else
	bcd[3:0] = bcd[3:0];
    if(bcd[7:4] >= 5)
	bcd[7:4] = bcd[7:4] + 3;
    else
	bcd[7:4] = bcd[7:4];
    if(bcd[11:8] >= 5)
	bcd[11:8] = bcd[11:8] + 3;
    else
	bcd[11:8] = bcd[11:8];
	if(bcd[15:12] >= 5)
	bcd[15:12] = bcd[15:12] + 3;
    else
	bcd[15:12] = bcd[15:12];
    
    bcd = {bcd[14:0], iBIN[13-i]};
  end
 end

endmodule

// 7-segment 디코더
module seven_seg_decoder(
    input [3:0] digit,
    output [6:0] segments
);
   
    assign segments = (digit == 4'h0) ? 7'b1000000 : // 0
                      (digit == 4'h1) ? 7'b1111001 : // 1
                      (digit == 4'h2) ? 7'b0100100 : // 2
                      (digit == 4'h3) ? 7'b0110000 : // 3
                      (digit == 4'h4) ? 7'b0011001 : // 4
                      (digit == 4'h5) ? 7'b0010010 : // 5
                      (digit == 4'h6) ? 7'b0000010 : // 6
                      (digit == 4'h7) ? 7'b1111000 : // 7
                      (digit == 4'h8) ? 7'b0000000 : // 8
                      (digit == 4'h9) ? 7'b0010000 : // 9
                      7'b1111111; // 기본값

endmodule

// Binary 입력을 받아 BCD 변환 후 7-segment 디스플레이 (4자리 지원)
module bin_to_7seg_display(
    input clk,                    // 100MHz 클록
    input reset,                  // 리셋 신호
    input [13:0] binary_input,    // 14비트 이진수 입력 (0~9999)
    output [6:0] seg,             // 7-segment 출력
    output [3:0] an               // digit 선택 신호 (active low)
);

    // Binary to BCD 변환
    wire [15:0] bcd_output;
   
    bin2bcd bcd_converter(
        .clk(clk),
        .iBIN(binary_input),
        .oBCD(bcd_output)
    );

    // 클록 분주기 - 디스플레이 다중화용
    reg [16:0] clk_divider;
    wire refresh_clk;
   
    always @(posedge clk or posedge reset) begin
        if (reset)
            clk_divider <= 0;
        else
            clk_divider <= clk_divider + 1;
    end
   
    assign refresh_clk = clk_divider[16]; // 약 763Hz
   
    // 디스플레이 선택 카운터 (2비트로 0~3 순환)
    reg [1:0] digit_select;
   
    always @(posedge refresh_clk or posedge reset) begin
        if (reset)
            digit_select <= 0;
        else
            digit_select <= digit_select + 1;
    end
   
    // BCD에서 각 자리수 분리
    wire [3:0] digit0, digit1, digit2, digit3;
   
    assign digit0 = bcd_output[3:0];     // 일의 자리
    assign digit1 = bcd_output[7:4];     // 십의 자리
    assign digit2 = bcd_output[11:8];    // 백의 자리
    assign digit3 = bcd_output[15:12];   // 천의 자리
   
    // 현재 선택된 digit의 값 (조합논리)
    wire [3:0] current_digit;
   
    assign current_digit = (digit_select == 2'b00) ? digit0 :
                          (digit_select == 2'b01) ? digit1 :
                          (digit_select == 2'b10) ? digit2 : digit3;
   
    // Anode 제어 (조합논리) - active low
    assign an = (digit_select == 2'b00) ? 4'b1110 :  // digit0 활성화
                (digit_select == 2'b01) ? 4'b1101 :  // digit1 활성화
                (digit_select == 2'b10) ? 4'b1011 :  // digit2 활성화
                                          4'b0111;   // digit3 활성화
   
    // 7-segment 디코더 인스턴스
    seven_seg_decoder seg_decoder(
        .digit(current_digit),
        .segments(seg)
    );

endmodule

module test(clk, in_test, out_test);
    input clk;
    input in_test;
    output out_test;
   
    assign out_test = in_test;
   
endmodule

// 테스트를 위한 top 모듈
module top_module(
    input clk,
    input [13:0] sw,              // 14비트 스위치 입력 (이진수, 0~9999)
    input btnC,                   // 센터 버튼 (리셋용)
    input [13:0] sw1,
    input [13:0] sw2,
    output [6:0] seg,
    output [6:0] seg1,
    output [3:0] an
);

    // 리셋 동기화
    reg reset_sync;
    reg [1:0] reset_ff;
   
    always @(posedge clk) begin
        reset_ff <= {reset_ff[0], btnC};
        reset_sync <= reset_ff[1];
    end
   
    // Binary to 7-segment 디스플레이 인스턴스
    bin_to_7seg_display display_inst(
        .clk(clk),
        .reset(reset_sync),
        .binary_input(sw),        // 14비트 스위치로 이진수 입력
        .seg(seg),
        .an(an)
    );
    
    bin_to_7seg_display display_inst1(
        .clk(clk),
        .reset(reset_sync),
        .binary_input(sw1),        // 14비트 스위치로 이진수 입력
        .seg(seg),
        .an(an)
    );
    
    test test1(
        .clk(clk),
        .in_test(sw2),
        .out_test(seg1)
    );

endmodule
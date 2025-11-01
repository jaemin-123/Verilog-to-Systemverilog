# Verilog Cheatsheet & Patterns (입문자용)

SystemVerilog 업그레이드: [`systemverilog.md`](systemverilog.md) · 차이표: [`comparison.md`](comparison.md)

---

## 기본 문법
- 모듈/포트
  ```verilog
  module my_and (
    input  a, b,
    output y
  );
    assign y = a & b;
  endmodule
  ```
- 타입
  - `wire`: 연속 할당(`assign`) 등 **넷(net)**으로 구동되는 신호
  - `reg`: `always` 블록 안에서 **대입**되는 변수(레지스터의 의미가 아니라 "절차대입 가능" 이라는 뜻)
- 벡터/폭
  ```verilog
  wire [7:0] d;     // 8비트(상위:7, 하위:0)
  wire       msb = d[7];
  wire [3:0] hi  = d[7:4];
  ```
- 리터럴/특수값
  - `N'진수값` 예: `8'hFF`, `4'd9`, `3'b101`
  - `'0`, `'1`, `'x`, `'z`(폭 자동 맞춤)
- 결합/반복
  ```verilog
  wire [8:0] sum9 = {1'b0, d} + {1'b0, e};   // 0 붙여 캐리 보존
  wire [7:0] fill = {8{en}};                 // en을 8번 반복
  ```
> Do: 산술 전 폭/부호를 명시적으로 맞추기(`{1'b0,a}` 처럼)

> Don't: 서로 다른 폭을 무심코 더하기(경고/의도치 않은 잘림)

> SV 차이점
> - `wire/reg` 대신 `logic` 하나로 통일 가능(단일 드라이버 전제)
> - 타입 추론/엄격한 블록 구분(`always_comb/ff`)

>   자세히 → [sy



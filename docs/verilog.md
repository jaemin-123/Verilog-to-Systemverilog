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
> Do: 산술 전 폭/부호를 명시적으로 맞추기(`{1'b0,a}` 처럼)<br>
> Don't: 서로 다른 폭을 무심코 더하기(경고/의도치 않은 잘림)

> SV 차이점<br>
> - `wire/reg` 대신 `logic` 하나로 통일 가능(단일 드라이버 전제)
> - 타입 추론/엄격한 블록 구분(`always_comb/ff`)

---

## 연속 할당 vs 절차 블록
- **연속 할당(Continuous)** - `assign`으로 **항상** 드라이브(조합식/연결)
  ```verilog
  wire [7:0] y;
  assign y = sel ? a : b;   // 단순 MUX
  ```
- **절차 블록(Procedural)** - `always` 안에는 `reg`에 대입
  - **조합 블록**: `always @*` + **blocking `=`** + **기본값**(래치 방지)
  - **순차 블록**: `always @(posedge clk ...)` + **nonblocking** `<=`
  ```verilog
  // 조합(우선순위 + 기본값)
  reg [7:0] y_c;
  always @* begin
    y_c = 8'h00;                  // 기본값
    if      (sel==2'd0) y_c = a;
    else if (sel==2'd1) y_c = b;
    else if (sel==2'd2) y_c = c;
  end
  
  // 순차(레지스터)
  reg [7:0] q;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= '0;
    else        q <= y_c;
  end
  ```
### 선택 가이드
- 한 줄 연결/산술 → `assign`
- 분기/기본값/여러 단계 계산 → `always @*`
- 플립플롭/카운터/FSM 상태 → `@(posedge clk ...)`
> SV 차이점
> - `always_comb`/`always_ff`으로 의도 명확화(민감도 누락 자동 체크)
> - 변수는 `logic` 사용

---

## 조합회로
- 규칙: `always @*` + blocking `=` + 모든 경로 대입(기본값)

### 4:1 MUX (조합)
```verilog
module mux4 (
  input  [1:0] sel,
  input  [7:0] a0, a1, a2, a3,
  output reg [7:0] y
);
  always @* begin
    y = '0;                // 기본값(래치 방지)
    case (sel)
      2'b00: y = a0;
      2'b01: y = a1;
      2'b10: y = a2;
      default: y = a3;
    endcase
  end
endmodule
```
### 우선순위 인코더(조합 if/else)
```verilog
module prio_enc4 (
  input  [3:0] in,
  output reg [1:0] code,
  output reg       valid
);
  always @* begin
    code  = 2'b00; valid = 1'b0;
    if      (in[3]) begin code = 2'b11; valid = 1'b1; end
    else if (in[2]) begin code = 2'b10; valid = 1'b1; end
    else if (in[1]) begin code = 2'b01; valid = 1'b1; end
    else if (in[0]) begin code = 2'b00; valid = 1'b1; end
  end
endmodule
```
> 조심: 일부 경로 미대입 → **래치 유도**, 항상 기본값 또는 `default`를 둔다

> SV 차이점
> - `always_comb` 사용, `unique/priority case`로 안전성 향상

---

## 순차회로
- 규칙: `@(posedge clk or negedge rst_n)` + **nonblocking `<=`**
- 리셋 정책은 각 규칙에 맞춰 통일


























































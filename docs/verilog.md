# Verilog Cheatsheet & Patterns

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
### DFF + 이네이블
```verilog
module dff_en (
  input       clk, rst_n, en,
  input [7:0] d,
  output reg [7:0] q
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= '0;
    else if (en) q <= d;
  end
endmodule
```
### 동기 카운터
```verilog
module counter8 (
  input clk, rst_n,
  output reg [7:0] cnt
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cnt <= '0;
    else        cnt <= cnt + 1'b1;
  end
endmodule
```
> SV 차이점
> - `always_ff @(posedge clk, negedge rst_n)`로 표기
> - `logic [7:0]` 사용

---

## 블로킹 vs 논블로킹 패턴
| 구분    | 블로킹 `=`      | 논블로킹 `<=`   |
| ----- | ------------ | ------------------------ |
| 시점    | 문장 즉시        | 에지/타임스텝 끝에 일괄  |
| 주 사용처 | **조합**(`@*`) | **순차**(`@(posedge clk)`) |
| 주의    | 미대입 시 래치 | 이전/새값 타이밍 착각 방지 |

### 필수 규칙
- **조합 = `=`, 순차 = `<=`**
- **같은 신호**를 같은 타임스텝에 `=`와 `<=`로 혼용 금지
- 파이프라인 레지스터는 **모두 `<=`**
```verilog
// BAD: 순차 블록에서 =
always @(posedge clk) begin
  q = d;
end
// FIX
always @(posedge clk) begin
  q <= d;
end

// BAD: 동일 블록에서 =로 읽자마자 쓰기(전파)
always @(posedge clk) begin
  q  = d;
  q2 = q;    // q2 ← d
end
// FIX: 둘 다 <= 로 동시 갱신 → q2는 q의 이전값 사용
always @(posedge clk) begin
  q  <= d;
  q2 <= q;
end
```
> SV 차이점
> - `always_ff/always_comb`로 구분 자체를 문법화(도구가 체크)

---

## FSM 템플릿
- 2-프로세스 구조
  - A 상태 레지스터(순차, `<=`)
  - B 다음상태/출력(조합, `=` + 기본값)
```verilog
module fsm_3state (
  input  clk, rst_n, in,
  output reg out
);
  localparam S0=2'd0, S1=2'd1, S2=2'd2;
  reg [1:0] state, next;

  // A) 상태 레지스터
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= S0;
    else        state <= next;
  end

  // B) 다음상태/출력(조합)
  always @* begin
    next = state; out = 1'b0;   // 기본값
    case (state)
      S0: if (in) next = S1;
      S1: if (in) next = S2;
      S2: if (in) next = S0;
      default:    next = S0;
    endcase
    // Moore 예시: out은 상태로만 결정해도 됨
    if (state==S2) out = 1'b1;
  end
endmodule
```
> SV 차이점
> - `typedef enum logic [1:0] {s0,s1,s2} state_e;`
> - `unique case` 로 누락 경로 경고/커버리지 향상

---

## 파라미터/제너레이트
- **파라미터**로 폭/기능 일반화
```verilog
module addN #(parameter W=8) (
  input  [W-1:0] a, b,
  output [W:0]   sum
);
  assign sum = {1'b0, a} + {1'b0, b};
endmodule
```
- **제너레이트**로 반복 인스턴스
```verilog
module and_array #(parameter N=4)(
  input  [N-1:0] a, b,
  output [N-1:0] y
);
  genvar i;
  generate
    for (i=0; i<N; i=i+1) begin : g
      assign y[i] = a[i] & b[i];
    end
  endgenerate
endmodule
```
> SV 차이점
> - `$clog2` 내장함수/타입 안전한 파라미터가 더 편함

---

## 합성 vs 시뮬레이션 주의
- **래치 유도 금지**(조합 블록 기본값/`default` 필수)
- **다중 드라이브 금지**(같은 신호를 여러 곳에서 모는 실수)
- **내부 tri-state 지양**(MUX로 대체), tri-state는 **탑레벨 `inout`에서만
- `casex/casez` 지양(와일드카드 오해 위험)
- 보일러플레이트: 거의 변하지 않고 반복적으로 사용되는 코드(파일 최상/최하)
```verilog
`timescale 1ns/1ps
`default_nettype none
// ...
`default_nettype wire
```
> SV 차이점
> - `always_comb/ff`가 합성 친화적 패턴 강제에 도움

---

## CDC
기본 목표 : **메타안정 확률 최소화 + 데이터 무결성 보장**
- **단일 레벨 신호: 2FF 동기화**
  ```verilog
  // clkA -> clkB
  reg s1, s2;
  always @(posedge clk_b or negedge rst_n) begin
    if (!rst_n) {s2, s1} <= 2'b0;
    else        {s2, s1} <= {s1, async_level_a};
  end
  wire level_b = s2;
  ```
- **단일 펄스: 토글 동기화**(미스 방지)
  ```verilog
  reg tog_a;
  always @(posedge clk_a or negedge rst_n)
    if(!rst_n) tog_a <= 1'b0;
    else if (pulse_a) tog_a <= ~tog_a;

  reg t1_b, t2_b;
  always @(posedge clk_b or negedge rst_n)
    if(!rst_n) {t2_b,t1_b} <= 2'b0;
    else       {t2_b,t1_b} <= {t1_b, tog_a};
  wire pulse_b = t1_b ^ t2_b;
  ```
- **멀티비트 버스**: **비동기 FIFO(Gray 포인터)** 또는 **핸드셰이크(valid/ready)**
- **리셋 해제**: 각 도메인에서 **동기화**
> SV 차이점
> - SVA(어설션)로 CDC 프로토콜 체크 가능(검증 쪽)

---

## 테스트벤치(TB) 기초
- **클록/리셋 생성**, DUT는 보통 `posedge`에서 샘플 → 자극은 **반대 에지**에서 변경하면 경합↓
- 간단한 **self-check**(예상값 비교) 추가
```verilog
`timescale 1ns/1ps
module tb_counter8;
  reg clk=0, rst_n=0;
  wire [7:0] cnt;

  counter8 dut(.clk(clk), .rst_n(rst_n), .cnt(cnt));

  always #5 clk = ~clk;   // 100MHz -> 주기 10ns
  initial begin
    #20 rst_n = 1;        // 리셋 해제(동기 deassert)
    repeat (20) @(negedge clk); // 자극은 반대 에지에서
    $finish;
  end
endmodule
```
> SV 차이점
> - TB에서 class/랜덤/constraint 등 강력한 기능 사용 가능(합성 X)

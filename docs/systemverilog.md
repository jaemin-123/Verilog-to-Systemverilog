# SystemVerilog

> Verilog 기초/패턴은: [verilog.md](verilog.md) · 차이표는: [comparison.md](comparison.md)

---

## 왜 SystemVerilog인가
- **가독성/안전성↑**: `logic`, `always_ff/always_comb`, `enum`, `unique case`
- **타입/패키징↑**: `typedef`, `package`, `interface`로 큰 디자인 구성 깔끔
- **검증 강화**: SVA(어설션), 클래스/랜덤 등(※ 설계 RTL은 합성 가능한 기능만 사용)

> 결론: **Verilog로 기본을 잡은 뒤**, SV의 **디자인 친화 문법**만 먼저 챙겨 쓰자.

---

## 핵심 추가 문법 (입문자가 바로 쓰는 것)

### 1) `logic` — `wire/reg` 대신 단일 타입
- **단일 드라이버** 전제에서 `wire/reg`를 사실상 대체.
- 내부 신호 대부분 `logic`으로 시작하면 편함.

```systemverilog
logic        en;
logic [7:0]  a, b, y;
```

> Verilog → SV  
> `wire/reg` 섞어 쓰던 걸 **`logic`으로 통일**(단, 다중 드라이버는 여전히 금지)

---

### 2) `always_ff` / `always_comb` / `always_latch`
- **의도**를 문법으로 못 박아 줌 → 도구가 잘못된 민감도/혼용을 잡아줌.

```systemverilog
// 순차(플립플롭)
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) q <= '0;
  else        q <= d;
end

// 조합(민감도 자동, 래치 방지 체크)
always_comb begin
  y = '0;
  case (sel)
    2'b00: y = a0;
    2'b01: y = a1;
    2'b10: y = a2;
    default: y = a3;
  endcase
end
```

> Verilog → SV  
> `always @(posedge clk)` → **`always_ff`**, `always @*` → **`always_comb`**

---

### 3) `enum` + `typedef` — 상태/코드의 의미를 타입으로
- 상태/FSM, 인코딩 값들을 **이름 있는 타입**으로 관리.

```systemverilog
typedef enum logic [1:0] {S0, S1, S2} state_e;
state_e state, next;
```

> 장점: 디버깅/커버리지/가독성 좋아지고, 범위 밖 값 사용을 도구가 경고.

---

### 4) `unique` / `priority case`
- `case` 누락/중복을 **런타임/정적**으로 체크.

```systemverilog
unique case (state)
  S0: next = in ? S1 : S0;
  S1: next = in ? S2 : S1;
  S2: next = in ? S0 : S2;
endcase
```

> `unique`는 **상호 배타** 및 **모든 경우 커버** 기대, `priority`는 우선순위 의도.

---

### 5) 패키지/임포트: `package` / `import`
- 상수/타입/함수 등을 공용으로.

```systemverilog
// file: pkg_defs.sv
package pkg_defs;
  parameter int W = 8;
  typedef enum logic [1:0] {S0,S1,S2} state_e;
endpackage

// 사용
import pkg_defs::*;
```

---

### 6) 구조체/packed 타입, `$clog2`
- 버스 묶음/필드 접근이 쉬워지고, 폭 계산 유틸도 강화.

```systemverilog
typedef struct packed {
  logic [7:0] data;
  logic       valid;
} payload_t;

localparam int N = 16;
localparam int A = $clog2(N);
```

---

### 7) 인터페이스/모드포트 (필수는 아님, 맛보기)
- 버스/신호 묶음을 포트로 깔끔히 전달.

```systemverilog
interface bus_if #(parameter W=8) (input logic clk);
  logic        valid, ready;
  logic [W-1:0] data;
  modport m (input ready, output valid, data);  // master
  modport s (input valid, data, output ready);  // slave
endinterface
```

> 작은 디자인에선 **필수 아님**. 팀/프로젝트 규모 커질수록 이점 큼.

---

## Verilog → SystemVerilog 업그레이드: 1:1 패턴

### (A) 조합/순차 기본 패턴
**Verilog**
```verilog
reg [7:0] y, q;
always @* begin
  y = 8'h00;
  if      (sel==2'd0) y = a0;
  else if (sel==2'd1) y = a1;
  else if (sel==2'd2) y = a2;
  else                y = a3;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) q <= '0;
  else        q <= y;
end
```

**SystemVerilog**
```systemverilog
logic [7:0] y, q;
always_comb begin
  y = '0;
  unique case (sel)
    2'd0: y = a0;
    2'd1: y = a1;
    2'd2: y = a2;
    default: y = a3;
  endcase
end

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) q <= '0;
  else        q <= y;
end
```

---

### (B) FSM (2-프로세스, enum + unique case)
**Verilog**
```verilog
localparam S0=2'd0, S1=2'd1, S2=2'd2;
reg [1:0] state, next;
reg       out;

always @(posedge clk or negedge rst_n)
  if (!rst_n) state <= S0; else state <= next;

always @* begin
  next = state; out = 1'b0;
  case (state)
    S0: if (in) next = S1;
    S1: if (in) next = S2;
    S2: if (in) next = S0;
    default:    next = S0;
  endcase
  if (state==S2) out = 1'b1;
end
```

**SystemVerilog**
```systemverilog
typedef enum logic [1:0] {S0,S1,S2} state_e;
state_e state, next;
logic   out;

always_ff @(posedge clk or negedge rst_n)
  if (!rst_n) state <= S0; else state <= next;

always_comb begin
  next = state; out = 1'b0;
  unique case (state)
    S0: if (in) next = S1;
    S1: if (in) next = S2;
    S2: if (in) next = S0;
  endcase
  if (state==S2) out = 1'b1;
end
```

---

### (C) 파라미터/제너레이트 + `$clog2`
**Verilog**
```verilog
module addN #(parameter W=8) (input [W-1:0] a,b, output [W:0] sum);
  assign sum = {1'b0,a} + {1'b0,b};
endmodule
```

**SystemVerilog**
```systemverilog
module addN #(parameter int W=8) (input logic [W-1:0] a,b, output logic [W:0] sum);
  assign sum = {1'b0,a} + {1'b0,b};
endmodule

module and_array #(parameter int N=4)(input  logic [N-1:0] a,b,
                                      output logic [N-1:0] y);
  for (genvar i=0; i<N; ++i) begin : g
    assign y[i] = a[i] & b[i];
  end
endmodule

localparam int N = 16;
localparam int A = $clog2(N); // 주소폭 계산
```

---

## 합성 관점 팁 (Design-Only)

- **쓰면 좋은 것**
  - `logic`, `always_ff/always_comb`, `enum/typedef`, `unique/priority case`
  - `package/import`, `$clog2`, `struct packed`(필드 묶음)
- **주의/제한**
  - 클래스/동적배열/큐/메일박스/랜덤 등은 **TB 전용**(합성 X)
  - `interface`는 합성 도구/플로우 지원 범위 확인(대부분 기본 사용은 OK)
  - `initial` 블록/변수 초기값은 합성 도구 옵션/FPGA에 따라 다름(리셋 논리 권장)
- **리셋 정책**
  - 팀 규칙에 맞추되, 본 문서 예제는 **비동기 assert / 동기 deassert** 가정
  - **리셋 해제 동기화**(각 도메인별) 잊지 말 것

---

## CDC(요약만 — 디자인 규칙 동일)
- **단일 레벨**: 2FF 동기화  
- **단일 펄스**: 토글 동기화  
- **멀티비트**: Async FIFO(Gray 포인터) 또는 Handshake  
- **리셋 해제**: 도메인별 동기화  
- (검증) SVA로 프로토콜/스테이블 윈도우 체크 가능

> 자세한 회로/코드는 [verilog.md#cdc](verilog.md#cdc) 예제 그대로 사용해도 무방(타입만 `logic`으로)

---

## 마이그레이션 체크리스트

1. 타입 → **`logic`** 중심으로 바꾸기(다중 드라이버가 아닌 곳)  
2. 블록 → **`always_ff`/`always_comb`**로 분리  
3. 상태/상수 → **`typedef enum` + `package`**로 공용화  
4. `case` → **`unique`/`priority`** 추가로 안전성 강화  
5. 폭/주소 → **`$clog2`**로 계산  
6. TB 전용 기능(클래스/랜덤 등)은 **설계 RTL에 넣지 않기**  

---

## 네비게이션
- Verilog 기본/패턴: [verilog.md](verilog.md)  
- 차이 요약 표: [comparison.md](comparison.md)  
- 예제 모음(곧 추가): `examples/`  
  - `verilog/`와 `sv/`를 나눠 같은 기능을 1:1로 비교 예정


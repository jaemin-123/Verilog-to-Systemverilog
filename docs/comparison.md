# Verilog vs SystemVerilog (디자인 관점 비교)

> Verilog 패턴: [verilog.md](verilog.md) · SystemVerilog 업그레이드: [systemverilog.md](systemverilog.md)

---

## 요약 표

| 항목 | Verilog | SystemVerilog | 비고/추천 |
|---|---|---|---|
| 기본 타입 | `wire`/`reg` | **`logic`** | 단일 드라이버 전제, SV 권장 |
| 절차 블록 | `always` | **`always_ff/always_comb/always_latch`** | 의도 명확, 에러 감소 |
| 상태 표현 | `parameter`/`localparam` | **`typedef enum`** | 가독성/안전성 ↑ |
| case 안전 | `case` + `default` | **`unique`/`priority case`** | 누락/중복 체크 |
| 패키징 | 없음 | **`package` / `import`** | 공통 상수·타입 공유 |
| 인터페이스 | 없음 | **`interface` / `modport`** | 포트/버스 묶음 |
| 폭 계산 | 사용자 계산 | **`$clog2`** 내장 | 주소폭 등 계산 용이 |
| 구조적 타입 | 기본 배열 | **`struct/union` (packed)** | 버스 필드화 |
| 캐스팅 | 제한 | **정적/동적 cast**(`type'(expr)) | 폭/부호 변환 명시 |
| 어설션 | 제한적 | **SVA** | 검증 강화(합성X) |
| TB 기능 | 제한 | **class/random/constraint, mailbox/queue** | TB 전용(합성X) |
| 초기화 | 합성 의존 | **변수 초기화 문법 지원** | 합성 지원 여부 확인 |
| generate | `generate/endgenerate` | 동일(+문법 개선) | 기능 동일 |
| 학습 난이도 | 낮음 | 중간 | Verilog → SV 업그레이드 권장 |

---

## 주제별 차이 (짧게)

### 1) 타입/블록
- **Verilog**: `wire`(연속), `reg`(절차), `always @*` / `@(posedge clk)`
- **SV**: **`logic`** 하나로 통일(단일 드라이버), **`always_comb` / `always_ff`**
```systemverilog
logic [7:0] y, q;
always_comb   y = sel ? a : b;
always_ff @(posedge clk) q <= y;
```

### 2) 상태/케이스 안전성
- **Verilog**: `localparam` 상수 + `case ... default`
- **SV**: **`typedef enum`**, **`unique case`**로 누락/중복 경고
```systemverilog
typedef enum logic [1:0] {S0,S1,S2} state_e;
unique case(state)  S0: ...; S1: ...; S2: ...; endcase
```

### 3) 패키지/공용 선언
- **SV**: `package`/`import`로 상수·타입 공유
```systemverilog
package cfg;  parameter int W=8;  endpackage
import cfg::*;
```

### 4) 인터페이스/모드포트
- **SV**: 버스 묶음, 방향을 `modport`로 명확화(대형 디자인에 유리)
```systemverilog
interface bus_if #(int W=8); logic valid, ready; logic [W-1:0] data; endinterface
```

### 5) 구조체·폭 계산·캐스팅
- **SV**: `struct packed`로 필드화, `$clog2`로 주소폭 계산, `type'(expr)` 캐스트
```systemverilog
typedef struct packed { logic [7:0] data; logic v; } payload_t;
localparam int A = $clog2(DEPTH);
logic [3:0] x = logic'(some_wider);
```

### 6) 테스트벤치/검증(합성 X)
- **SV**: class/constraint/randomization, mailbox/queue, **SVA** 등 풍부
- **디자인 RTL에는 사용 금지**, TB에서만 사용

---

## 선택 가이드
- **작은 모듈/학습 초반**: Verilog만으로 충분  
- **가독성·안전성·팀 협업**: **SV 핵심(logic / always_ff/comb / enum / unique)** 채택  
- **검증·대규모 설계**: 패키지/인터페이스/SVA까지 **SV 필수**

---

## 마이그레이션 체크리스트 (실무 압축)

1. 타입을 **`logic`**으로 교체(다중 드라이버 아닌 곳)  
2. 블록을 **`always_ff` / `always_comb`**로 분리  
3. 상태를 **`typedef enum`**으로, `unique/priority case` 적용  
4. 공통 상수/타입을 **`package`**로 이동, `import`로 사용  
5. 폭/주소 계산은 **`$clog2`**, 필드는 **`struct packed`**로 묶기  
6. RTL에는 **TB 전용 기능 금지**(class/random/queue/SVA 등)  

---

## 흔한 함정 (Gotchas)

- `logic`이라도 **다중 드라이버 금지**(연속·절차 혼용 X)  
- `always_comb` 안에서 **블로킹 `=` + 모든 경로 대입**(래치 방지)  
- `unique case`라도 **미정의 값(X/Z)**가 들어오면 default가 유용할 수 있음  
- 변수 초기화는 **합성 도구/FPGA 옵션 의존** → **리셋 논리**를 기본으로  
- `casex/casez`는 Verilog/SV 모두에서 **지양**(와일드카드 오해 위험)

---

## 미니 예제: 같은 기능, 두 언어

**Verilog**
```verilog
localparam S0=2'd0, S1=2'd1, S2=2'd2;
reg [1:0] state, next;
always @(posedge clk or negedge rst_n)
  if(!rst_n) state <= S0; else state <= next;
always @* begin
  next = state;
  case (state)
    S0: if(in) next = S1;
    S1: if(in) next = S2;
    S2: if(in) next = S0;
    default:   next = S0;
  endcase
end
```

**SystemVerilog**
```systemverilog
typedef enum logic [1:0] {S0,S1,S2} state_e;
state_e state, next;
always_ff @(posedge clk or negedge rst_n)
  if(!rst_n) state <= S0; else state <= next;
always_comb begin
  next = state;
  unique case (state)
    S0: if(in) next = S1;
    S1: if(in) next = S2;
    S2: if(in) next = S0;
  endcase
end
```

---

## 네비게이션
- Verilog 패턴: [verilog.md](verilog.md)  
- SystemVerilog 업그레이드: [systemverilog.md](systemverilog.md)

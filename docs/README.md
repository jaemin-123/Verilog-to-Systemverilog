# 문서 인덱스 & 기본서 (Fundamentals)

- [조합회로 vs 순차회로](README.md#조합회로-vs-순차회로)
- [블로킹(=) vs 논블로킹(<=)](README.md#블로킹-vs-논블로킹)
- FSM 템플릿 → #fsm-템플릿2-프로세스
- CDC(2-플롭 동기화) → #메타안정-클록-도메인-교차cdc
- Verilog 치트시트 → verilog.md
- SystemVerilog 치트시트 → systemverilog.md
- Verilog vs SV 비교표 → comparison.md

## 조합회로 vs 순차회로

### 1) 개념 요약
- **조합회로(Combinational)**: 현재 입력만으로 출력이 결정됨. 메모리 X.
- **순차회로(Sequential)**: 클록/리셋 등 시간 개념이 있고, **상태(레지스터)**를 기억.

| 구분 | 조합회로 | 순차회로 |
|---|---|---|
| 출력 의존성 | 현재 입력 | 과거 상태 + 현재 입력 |
| 시간 요소 | 없음 | 클록, (비)동기 리셋 |
| 코딩 패턴 | `always @*` + blocking `=` | `always @(posedge clk …)` + nonblocking `<=` |
| 대표 블록 | MUX, 가감산기, 비교기, 디코더 | 레지스터, 카운터, 시프트 레지스터, FSM |
| 주된 함정 | **래치 유도**, 감지식 누락 | `=`/`<=` 혼용, 리셋/이네이블 처리 실수 |

---

### 2) 조합회로 코딩 규칙

**핵심 규칙**
- `always @*` 사용(민감도 자동)  
- **blocking `=`** 사용  
- **모든 경로에서 출력에 값 대입**(기본값 or `default`) → **래치 방지** 

**예: 4:1 MUX**
```verilog
always @* begin
  y = '0;              // 기본값(래치 방지)
  case (sel)
    2'b00: y = a0;
    2'b01: y = a1;
    2'b10: y = a2;
    2'b11: y = a3;
  endcase
end
```

**예: 우선순위 인코더 (if/else)**
```verilog
always @* begin
  code = 2'b00; valid = 1'b0;
  if      (in[3]) begin code = 2'b11; valid = 1'b1; end
  else if (in[2]) begin code = 2'b10; valid = 1'b1; end
  else if (in[1]) begin code = 2'b01; valid = 1'b1; end
  else if (in[0]) begin code = 2'b00; valid = 1'b1; end
end
```

**예: 래치가 생기는 예**
```verilog
// BAD: cond가 거짓일 때 y에 값이 안 들어가서 래치가 유도됨
always @* begin
  if (cond) y = a;
end
```

**수정**
```verilog
always @* begin
  y = '0;          // 기본값
  if (cond) y = a;
end
```
또는
```verilog
always @* begin
  if (cond) y = a;
  else y = '0;
end
```

---

### 3) 순차회로 코딩 규칙

**핵심 규칙**
- `always @(posedge clk or negedge rst_n)` 등 클록/리셋 감지식 사용  
- **nonblocking `<=`** 사용(레지스터 간 동시 업데이트)  
- 리셋은 **동기/비동기** 중 프로젝트 규칙에 맞춰 통

**예: 비동기 Low 리셋 DFF**
```verilog
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) q <= '0;
  else        q <= d;
end
```

**예: 동기 리셋 + 이네이플**
```verilog
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) q <= '0;
  else        q <= d;
end
```

---

## 블로킹 vs 논블로킹

### 1) 한눈 비교
| 구분 | 블로킹 `=` | 논블로킹 `<=` |
|---|---|---|
| 업데이트 시점 | 문장 실행 **즉시** | 타임스텝/에지 **끝에 일괄** |
| 주 사용처 | **조합** 블록(`always @*`) | **순차** 블록(`@(posedge clk …)`) |
| 장점 | 임시변수 계산 순서 표현 쉬움 | 레지스터들의 **동시 업데이트** 보장 |
| 흔한 위험 | 일부 경로 미대입 → **래치** 유도 | 이전값/새값 타이밍 오해 |

**철칙**
- **조합 = `=`**, **순차 = `<=`**  
- 같은 신호를 **같은 타임스텝에서 `=`와 `<=`로 혼용 금지**  
- 하나의 신호에는 **드라이버 1개**만(다중 드라이브 금지)

---

### 2) 올바른 패턴

**조합 논리 (always @\*)**
```verilog
always @* begin
  y = '0;            // 기본값(래치 방지)
  case (sel)
    2'b00: y = a0;
    2'b01: y = a1;
    2'b10: y = a2;
    default: y = a3;
  endcase
end
```
**순차 논리 (posedge clk ...)**
```verilog
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) q <= '0;
  else        q <= d;
end
```
**파이프라인 (전부 <= 로 동시 갱신)**
```verilog
always @(posedge clk) begin
  s1 <= a + b;     // 1단
  s2 <= s1 * c;    // 2단: 같은 에지에서 s1의 "이전값" 사용
  y  <= s2;        // 3단
end
```

---

### 3) 흔한 버그와 수정
**(A) 순차 블록에서 `=` 사용**
```verilog
// BAD
always @(posedge clk) begin
  q = d;
end
// FIX
always @(posedge clk) begin
  q <= d;
end
```
**(B) 동일 블록에서 읽자마자 쓰기**
```verilog
// BAD: = 사용 시 q2는 q의 "새 값"을 읽게 됨
always @(posedge clk) begin
  q  = d;
  q2 = q;      // q2 ← d (동일 에지 전달)
end
// FIX: 모두 <= 로 동시 갱신 → q2는 q의 "이전값"을 봄
always @(posedge clk) begin
  q  <= d;
  q2 <= q;
end
```
**(C) 혼용**
```verilog
// BAD: 같은 타임스텝에 q를 = 와 <= 로 둘 다 갱신
always @(posedge clk) begin
  q  =  a;
  q <=  b;
end
```
- 같은 신호는 같은 타임스텝에 **한 형태로만** 갱신

---

### 4) 임시 변수/연산 순서가 중요한 경우
**조합 계산은 블로킹 `=`로 “순서대로” 기술**
```verilog
always @* begin
  t1 = a + b;     // 즉시 t1 갱신
  t2 = t1 ^ c;    // t1의 새 값을 사용
  y  = t2 & d;
end
```
**순차 블록에서는 레지스터 갱신은 반드시 `<=`**
```verilog
always @(posedge clk) begin
  acc <= a + b;   // 레지스터 갱신은 <=
  q   <= acc ^ c;
end
```

---

### 5) 테스트벤치(TB)
- DUT가 `@(posedge clk)`에서 샘플하므로, 자극 변경은 **반대 에지`@(negedge clk)`**에서
- TB에서도 DUT 신호를 드라이브 할 떄는 **`<=`**를 쓰면 경합을 줄일 수 있음

---

### 6) 체크리스트
1. `always @*` + `=` + 기본값(조합)
2. `@(posedge clk ...)` + `<=`(순차)
3. 동일 신호 `=`/`<=` 혼용 금지
4. 동일 타임스텝 중복 대입 금지
5. 파이프라인/레지스터는 전부 `<=`
6. 조합 임시 변수는 `=`로 순서 표현

---

## FSM(유한 상태 기계, Finite State Machine)

### 1) FSM
입력의 시간적 흐름에 따라 **상태**를 저장하고, 그 상태와 입력으로 **다음 상태**와 **출력**을 결정하는 순차회로
- **Moore**: 출력이 **현재 상태**만으로 결정
- **Mealy**: 출력이 **현재 상태 + 입력**으로 결정 (보통 반 클록 빨리 반응)

### 2) 상태 인코딩
- **binary(순차)**: 비트 수 적음, 비교적 조밀
- **one-hot**: 상태 수 = 플립플롭 수, 조합 경로 짧아 타이밍에 유리(FPGA에서 자주 사용)
- **gray**: 인접 전환에서 1비트만 바뀌게 함(특수 용도)

### 3) 2-프로세스 템플릿(권장)
- (A) **상태 레지스터**: `@(posedge clk …)` — nonblocking `<=`
- (B) **다음 상태/출력 조합**: `@*` — blocking `=`, 기본값 필수(래치 방지)

```verilog
// 예: 간단한 2상태 토글 FSM (Mealy 스타일 예시 포함)
module fsm_toggle (
  input  clk, rst_n, in,
  output reg out
);
  // 1) 상태 인코딩 (binary)
  localparam S0 = 1'b0,
             S1 = 1'b1;

  reg state, next;

  // 2) 상태 레지스터 (순차)
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= S0;
    else        state <= next;
  end

  // 3) 다음 상태/출력 로직 (조합)
  always @* begin
    // 기본값 (래치 방지)
    next = state;
    out  = 1'b0;

    case (state)
      S0: begin
        // Mealy 예: 입력이 1일 때 즉시 out 반응
        if (in) begin
          next = S1;
          out  = 1'b1;
        end
      end
      S1: begin
        if (in) begin
          next = S0;
          out  = 1'b1;
        end
      end
      default: begin
        next = S0;
        out  = 1'b0;
      end
    endcase
  end
endmodule
```
## 규칙

- **순차 블록(레지스터)** → `<=`, **조합 블록** → `=`
- **조합 블록의 `next`/`out`에 기본값을 먼저 대입** (모든 경로 커버)
- **`case`에는 `default`를 넣기** (합성기 최적화/안전)

---

## 4) Moore vs Mealy 간단 비교

| 항목 | Moore | Mealy |
|---|---|---|
| **출력 의존** | 상태 | 상태 + 입력 |
| **반응 속도** | 한 클록 느릴 수 있음 | **빠름**(입력 변화에 즉시) |
| **글리치 가능성** | 낮음(상태 FF 출력) | 있을 수 있음(조합 경로) |
| **사용 팁** | 안정적 출력이 필요할 때 | 즉각 반응이 중요할 때(필터링 유의) |

---

## 5) One-hot 인코딩 템플릿

```verilog
// 상태가 3개면 FF 3개(one-hot). S0=001, S1=010, S2=100
localparam S0=3'b001, S1=3'b010, S2=3'b100;
reg [2:0] state, next;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) state <= S0;
  else        state <= next;
end

always @* begin
  next = 3'b000;   // 기본값 (one-hot에서는 다음 상태 비트 직접 셋)
  out  = 1'b0;

  case (1'b1)
    state[S0]: begin
      // ...
      next = in ? S1 : S0;
    end
    state[S1]: begin
      // ...
      next = in ? S2 : S1;
    end
    state[S2]: begin
      // ...
      next = in ? S0 : S2;
    end
    default: next = S0;
  endcase
end
```
- 도구에 따라`(fsm_encoding = "one-hot")`같은 어트리뷰트로도 지정 가능

---

### 6) 체크리스트
1. 조합 블록에 기본값 넣었나(래치 방지)?
2. 순차 블록은 **항상** `<=`
3. 리셋 후 합리적 초기 상태로 들어가나?
4. Mealy 출력에 글리치/메타안정 이슈는 없는가?(필요 시 FF로 1클록 지연)
5. 상태/출력 폭이 명확한가(슬라이스/결합 실수 방지)?

---

## 메타안정 / 클록 도메인 교차(CDC)
(내용…)

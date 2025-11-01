# Digital Design with Verilog & SystemVerilog

> Verilog 상세: [verilog.md](verilog.md) · SystemVerilog 상세: [systemverilog.md](systemverilog.md) · 차이표: [comparison.md](comparison.md)

## 빠른 길찾기
- [공통 코딩 규칙](#공통-코딩-규칙)
- [연속 할당 vs 절차 블록](#연속-할당-vs-절차-블록)
- [조합회로 vs 순차회로](#조합회로-vs-순차회로)
- [블로킹(=) vs 논블로킹(<=)](#블로킹-vs-논블로킹)
- [FSM(유한 상태 기계, Finite State Machine)](#fsm유한-상태-기계-finite-state-machine)
- [CDC(메타안정 / 클록 도메인 크로싱, CDC)](#메타안정--클록-도메인-크로싱cdc)
- [디자인 체크리스트](#디자인-체크리스트)

---

## 학습 로드맵 (요약)
1. **언어 최소 단위**(모듈/포트/비트폭/부호/연산자) → [Verilog 기본](verilog.md#기본-문법) / [SV 업그레이드](systemverilog.md#핵심-추가-문법)  
2. **연속 할당 vs 절차 블록** (`assign` vs `always`) → [패턴과 선택 기준](#연속-할당-vs-절차-블록)  
3. **조합/순차 패턴**: `@*`+`=` / `@(posedge clk)`+`<=` → [조합/순차](#조합회로-vs-순차회로)  
4. **블로킹 vs 논블로킹** 핵심 규칙 → [블로킹/논블로킹](#블로킹-vs-논블로킹)  
5. **클록/리셋 규칙**: `clk`, `rst_n`(비동기 assert/동기 deassert)  
6. **FSM(2-프로세스 템플릿)**, Moore/Mealy  
7. **파라미터/제너레이트**로 재사용성 높이기  
8. **합성 vs 시뮬 차이 & 안전 규칙**  
9. **CDC 기초**: 2FF/토글/Async FIFO  
10. **테스트벤치 기초**(자극 타이밍/셀프체크)

---

## 공통 코딩 규칙
- **클록/리셋 네이밍**: `clk`, `rst_n`(active-low)으로 통일  
- **리셋 정책**: 비동기 assert / **동기 deassert**(해제는 클록 동기화 필수)  
- **조합/순차 규칙**:  
  - 조합 → `always @*` + **blocking `=`** + **기본값 대입**(래치 방지)  
  - 순차 → `@(posedge clk …)` + **nonblocking `<=`**  
- **case 사용**: `default` 필수, `casex/casez`(와일드카드)는 지양  
- **assign vs always**: 단순식/연결은 `assign`, 분기·기본값·여러 단계 계산은 `always @*`  
- **버스 폭/부호**: 산술 전 **명시적 확장**(캐리·부호 보존)  
- **트라이스테이트**: 탑레벨 `inout`에서만 `1'bz` 사용(내부는 MUX)
- **파일 보일러플레이트**:
  ```verilog
  `timescale 1ns/1ps
  `default_nettype none
  // ...
  `default_nettype wire
  ```

---

## 연속 할당 vs 절차 블록

- **연속 할당(Continuous Assignment)**: `assign`으로 **넷(net: wire 등)**을 상시 드라이브.  
  - 합성 관점에서 **순수 조합식/단순 연결**에 가장 적합.
  - 문장 순서 개념이 없고, 입력 변화 시 항상 즉시 재평가.
  - 예)
    ```verilog
    wire [7:0] sum  = a + b;     // 선언과 동시에 연속 할당
    assign y = (sel) ? a : b;    // 단순 MUX 연결
    ```

- **절차 블록(Procedural Block)**: `always`(또는 SV의 `always_comb/ff`) 안에서 **변수(reg/logic)**에 대입.  
  - **분기/기본값/여러 단계 계산** 같은 “절차적” 조합이나, **클록 기반 순차**에 사용.
  - **조합 블록**: `always @*` + **blocking `=`** + **기본값**  
    **순차 블록**: `@(posedge clk …)` + **nonblocking `<=`**
  - 예)
    ```verilog
    // 조합: 우선순위/기본값 등 절차가 필요할 때
    reg [7:0] y;
    always @* begin
      y = 8'h00;           // 기본값(래치 방지)
      if (sel==2'd0) y = a;
      else if (sel==2'd1) y = b;
      else if (sel==2'd2) y = c;
      // default 경로 존재 → 래치 X
    end

    // 순차: 플립플롭(레지스터) 갱신
    reg [7:0] q;
    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) q <= '0;
      else       q <= y;
    end
    ```

### 언제 `assign`, 언제 `always`?
- **`assign`**: 단일 표현식/간단 연결/비트 조합(게이트 수준 포함).  
  예) 신호 네이밍 정리, 상위포트 연결, 쉬운 MUX/산술 한 줄짜리.
- **`always @*`**: 분기(`if/else`/`case`), **기본값** 필요, 단계적 계산/임시변수 필요할 때.
- **`@(posedge clk)`**: 레지스터/파이프라인/카운터/FSM 상태 등 **순차** 로직.

### 합성/안전 규칙 요약
- **같은 신호 다중 드라이버 금지**(연속/절차 혼합 드라이브 X).
  ```verilog
  // BAD: y를 assign과 always 둘 다에서 모는 경우
  assign y = a | b;
  always @* y = c;  // 금지
  ```
- **조합 블록은 모든 경로 대입**(기본값 or `default`) → **래치 방지**
- **내부 tri-state 금지**, tri-state는 **탑레벨 `inout`**에서만

---

## 조합회로 vs 순차회로
- 조합(Combinational): 현재 입력만으로 출력 결정(메모리 X) `always @*` + `=` + 기본값
- 순차(Sequential): 클록/리셋과 **상태(레지스터)** `@(posedge clk ...)` + `<=`
| 구분     | 조합회로                | 순차회로                             |
| ------ | ------------------- | -------------------------------- |
| 출력 의존성 | 현재 입력               | 과거 상태 + 현재 입력                    |
| 시간 요소  | 없음                  | 클록, (비)동기 리셋                     |
| 코딩 패턴  | `always @*` + `=`   | `always @(posedge clk …)` + `<=` |
| 대표 블록  | MUX, 가감산기, 비교기, 디코더 | 레지스터, 카운터, 시프트, FSM              |
| 주된 함정  | **래치 유도**           | `=`/`<=` 혼용, 리셋/EN 처리 실수         |
- 규칙: **조합=`=`/순차=`<=`**, 같은 신호를 같은 타임스텝에 혼용 금지

---

## 블로킹(=) vs 논블로킹(<=)
| 구분      | 블로킹 `=`                | 논블로킹 `<=`                     |
| ------- | ---------------------- | ----------------------------- |
| 업데이트 시점 | 문장 실행 **즉시**           | 에지/타임스텝 **끝에 일괄**             |
| 주 사용처   | **조합** 블록(`always @*`) | **순차** 블록(`@(posedge clk …)`) |
| 장점      | 임시변수 계산 순서 표현 쉬움       | 레지스터 **동시 업데이트**              |
| 흔한 위험   | 경로 미대입 → **래치** 유도     | 이전/새값 타이밍 오해                  |

### 핵심 규칙
- **조합 = `=`, 순차 = `<=`
- 같은 신호를 **같은 타임스텝에 `=`와 `<=`로 혼용 금지**
- 파이프라인 레지스터는 **모두 `<=`**로
예시(버그 → 수정)
```verilog
// BAD: 순차 블록에서 =
always @(posedge clk) begin
  q = d;
end
// FIX
always @(posedge clk) begin
  q <= d;
end
```
```verilog
// BAD: 동일 블록에서 읽자마자 쓰기(=로 인해 전파)
always @(posedge clk) begin
  q  = d;
  q2 = q;  // q2 ← d (동일 에지 전달)
end
// FIX: 모두 <= 로 동시 갱신 → q2는 q의 이전값을 사용
always @(posedge clk) begin
  q  <= d;
  q2 <= q;
end
```

---

## FSM(유한 상태 기계, Finite State Machine)
- 입력의 시간 흐름에 따라 **상태**를 저장하고, 상태+입력으로 **다음 상태/출력**을 결정
- **Moore**(상태만 의존, 안정적)vs**Mealy**(상태+입력, 반응 빠름)
- **2-프로세스 템플릿**
  - A 상태 레지스터(순차, `<=`)
  - B 다음상태/출력(조합, `=` + 기본값)

---

## 메타안정 & 클록 도메인 크로싱(CDC)
- **메타안정**: 비동기 신호가 FF의 **setup/hold** 창을 침범할 때 일시적 불안정
- 대응
  - 단일 **레벨: 2FF 동기화**
  - 단일 **펄스: 토글 동기화**(또는 펄스 폭 확장)
  - **멀티비트**: **비동기 FIFO**(Gray 포인터) 또는 **핸드셰이크**
  - **리셋 해제**: 각 도메인에서 **동기화**(비동기 assert/동기 deassert)

---

## 디자인 체크리스트
1. `always @*` + `=` + **기본값**(조합)
2. `@(posedge clk ...)` + `<=`(순차)
3. 동일 신호 `=`/`<=` 혼용 금지
4. 동일 타임스텝 중복 드라이브 금지
5. 파이프라인 레지스터는 전부 `<=`
6. 조합 임시변수 순서 의존 시 `=`
7. `case`에 `default` 필수, `casex/casez` 지양
8. 리셋: 비동기 assert / 동기 deassert
9. 모든 CDC 경로: 2FF/토글/FIFO/Handshake
10. `default_nettype none`로 타이포 방지

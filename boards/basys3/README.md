# Digital Design with Verilog & SystemVerilog

> Verilog 상세: [verilog.md](verilog.md) · SystemVerilog 상세: [systemverilog.md](systemverilog.md) · 차이표: [comparison.md](comparison.md)

## 빠른 길찾기
- [공통 코딩 규칙](#공통-코딩-규칙)
- [조합회로 vs 순차회로](#조합회로-vs-순차회로)
- [블로킹(=) vs 논블로킹(<=)](#블로킹-vs-논블로킹)
- [FSM(유한 상태 기계, Finite State Machine)](#fsm유한-상태-기계-finite-state-machine)
- [CDC(메타안정 / 클록 도메인 크로싱, CDC)](#메타안정--클록-도메인-크로싱cdc)
- [디자인 체크리스트](#디자인-체크리스트)

---

1. **언어 최소 단위**(모듈/포트/비트폭/부호/연산자) → [Verilog 기본](verilog.md#기본-문법) / [SV 업그레이드](systemverilog.md#핵심-추가-문법)
2. **연속 할당 vs 절차 블록** (`assign` vs `always`)
3. **조합/순차 패턴**: `@*`+`=` / `@(posedge clk)`+`<=`
4. **블로킹 vs 논블로킹** 핵심 규칙
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

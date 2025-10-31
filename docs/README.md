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



## 블로킹 vs 논블로킹
(내용…)

## FSM 템플릿(2-프로세스)
(내용…)

## 메타안정 / 클록 도메인 교차(CDC)
(내용…)

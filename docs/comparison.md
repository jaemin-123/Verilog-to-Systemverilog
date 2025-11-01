# Verilog vs SystemVerilog (디자인 관점 비교)

| 항목 | Verilog | SystemVerilog | 비고/추천 |
|---|---|---|---|
| 기본 타입 | `wire`/`reg` | **`logic`** | 단일 드라이버 전제, SV 권장 |
| 절차 블록 | `always` | **`always_ff/always_comb/always_latch`** | 의도 명확, 에러 감소 |
| 상태 표현 | `parameter`/`localparam` | **`enum typedef`** | 가독성/안전성 ↑ |
| case 안전 | `case` + `default` | **`unique/priority case`** | 커버리지/런타임 경고 |
| 패키지 | X | **`package`/`import`** | 공통 상수/타입 공유 |
| 인터페이스 | X | **`interface`/`modport`** | 포트 묶음/버스 연결 간소화 |
| 어설션 | 제한적 | **SVA** | 설계 검증 강화(TB/에뮬) |
| 배열/구조 | 기본 배열 | **`struct/union`(packed)** | 합성 범위 확인 필요 |
| TB 기능 | 제한 | **class/random/constraint** | TB 전용(디자인 X) |
| 학습 난이도 | 낮음 | 중간 | Verilog → SV 업그레이드 권장 |

## 선택 가이드
- **순수 RTL 설계 규칙**만 필요: Verilog로 충분  
- **가독성/안전성/확장성**을 올리고 싶다: **SV 핵심(logic/always_ff/enum/unique)** 도입  
- **검증/인터페이스/패키징**까지 고려한다: SV 필수

## 마이그레이션 팁(짧게)
1. 타입은 우선 **`logic`**으로 교체  
2. 블록을 **`always_ff/always_comb`**로 분리  
3. 상태는 **`enum`**으로, `unique case` 적용  
4. 공통 상수/타입은 **`package`**로 이동  
5. 큰 버스는 **`interface`**로 정리

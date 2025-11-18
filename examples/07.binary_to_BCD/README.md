# 07. Binary → BCD + 7-Segment Display

> Basys3 (XC7A35T-1CPG236C) · Vivado 2022.2 · Language: Verilog

---

## 1. 예제 개요

- 14비트 이진 입력 `iBIN`(스위치 `sw[13:0]`)을 받아서
  - 4자리 BCD(`oBCD[15:0]`)
  - 4자리 7-segment 디스플레이(`seg[6:0]`, `an[3:0]`)
  로 보여주는 **Binary-to-BCD 변환 + 7세그먼트 표시** 예제
- 구성 블록
  - `bin2bcd` : 14비트 binary → 4자리 BCD (천/백/십/일)
  - `seven_seg_decoder` : 1자리 BCD → 7세그 세그먼트 패턴
  - `bin_to_7seg_display` : 4자리 BCD를 빠르게 돌려가며 4개의 digit에 출력 (멀티플렉싱)
  - `top_module` : Basys3의 스위치/버튼/7세그 핀을 모두 연결하는 Top

---

## 2. 블록 다이어그램

<img width="600" alt="bin2bcd block" src="./images/block.png" />

- 입력: `iBIN[13:0]`  
- 출력: `oBCD[15:0]` (각 4비트가 천/백/십/일 자리를 의미)
- 7세그 표시:
  - `seg[6:0]` : 공용 세그먼트
  - `an[3:0]` : 활성화할 자리 선택 (active low)

---

## 3. 시뮬레이션 파형

<img width="1500" alt="bin2bcd waveform" src="./images/wave.png" />

- `iBIN` 값을 0,1,2,3,… 순서로 증가시키면서
  - `oBCD`가 10진수 표현(BCD)으로 제대로 변환되는지 확인
- 예:  
  - `iBIN = 8'd25` → `oBCD = 12'h025`  
  - `iBIN = 8'd49` → `oBCD = 12'h049`  
- 실제 RTL에서는 14비트/4자리까지 확장해서 0~9999 범위를 지원

---

## 4. 보드 연결 (Basys3 개요)

- 클록
  - `clk` ← W5 (100MHz)
- 입력 스위치
  - `sw[13:0]` ← Basys3 SW0~SW13 (0~9999 이진 입력)
- 7세그먼트
  - `seg[6:0]` ← W7, W6, U8, V8, U5, V5, U7
  - `an[3:0]`  ← U2, U4, V4, W4  (digit0~digit3, active low)
- 버튼
  - `btnC` ← U18 (동기 리셋)
- 필요하다면 BCD 값 일부를 LED에 연결해서 디버깅할 수도 있음  
  (예: `oBCD[3:0]` → LED0~LED3)

전체 제약은 예제 안의 `.xdc` 파일에서 확인.

---

## 5. 파일 구성

```text
examples/07.bin2bcd/
├─ bin2bcd.v              # Binary → BCD 변환 (shift‑add‑3 알고리즘)
├─ seven_seg_decoder.v    # 1자리 BCD → 7-seg 패턴
├─ bin_to_7seg_display.v  # 4자리 BCD → 4개의 7-seg 멀티플렉싱
├─ top_module.v           # Basys3용 Top (스위치/버튼/7세그 연결)
├─ tb_bin2bcd.v           # (옵션) bin2bcd 단위 시뮬레이션용 테스트벤치
├─ bin2bcd_basys3.xdc     # Basys3 핀 제약
└─ README.md              # 이 문서
```

- 실제 레포에서 폴더/파일 이름은 프로젝트 구조에 맞게 조정.

---

## 6. 실행 요약 (Makefile 사용)

레포 **루트**에서 아래처럼 실행한다고 가정.

```bash
# 1) RTL 시뮬레이션 (bin2bcd + 테스트벤치)
$ make xsim EX=bin2bcd

# 2) xsim GUI로 파형 보기
$ make xsim_gui EX=bin2bcd

# 3) 합성/비트스트림 (Top 모듈 이름이 top_module인 경우)
$ make synth EX=bin2bcd DUT=top_module
$ make bit   EX=bin2bcd DUT=top_module

# 4) bit 파일만 모으기 (옵션)
$ make harvest EX=bin2bcd
```

- `EX=bin2bcd` : 이 예제가 들어 있는 폴더 이름
- `DUT=top_module` : 실제 FPGA에 올릴 Top 모듈 이름
- 비트스트림은 `build/bin2bcd/` 또는 `artifacts/bin2bcd/impl/` 에 생성된다고 가정


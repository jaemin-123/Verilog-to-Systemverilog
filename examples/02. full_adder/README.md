# 02. Full Adder – 1-bit 가산기

> Basys3 (XC7A35T-1CPG236C) · Vivado 2022.2 · Language: Verilog / SystemVerilog

---

## 1. 예제 개요

- 입력 `iX`, `iY`, `iCIN`(Carry-In)을 받아서
  - 합(`oSUM`)
  - 자리올림(`oCARRY`)
  를 만드는 **1-bit 풀가산기** 예제
- 내부에서 보조 신호 `s0`, `c0`, `c1`을 이용해
  - XOR + AND + OR 게이트 조합으로 풀가산기를 구성

---

## 2. 블록 다이어그램

```text
examples/02.full_adder/images/block.png
```

![Full Adder block diagram](./images/block.png)

게이트 구성 (예시)

- `U0` : `iX` ⊕ `iY` → `s0`
- `U1` : `iX` · `iY` → `c0`
- `U2` : `s0` ⊕ `iCIN` → `oSUM`
- `U3` : `s0` · `iCIN` → `c1`
- `U4` : `c0` + `c1` → `oCARRY`

---

## 3. 시뮬레이션 파형

```text
examples/02.full_adder/images/wave.png
```

![Full Adder simulation waveform](./images/wave.png)

- 입력 조합(`iX`, `iY`, `iCIN`)을 000 → 001 → 010 → 011 → 100 → 101 → 110 → 111 순서로 변화
- 각 입력에 대해 `oSUM`, `oCARRY`가 트루스 테이블과 일치하는지 확인

---

## 4. 파일 구성

```text
examples/02.full_adder/
├─ full_adder.v      # Verilog RTL
├─ full_adder_sv.sv  # SystemVerilog RTL (옵션)
├─ tb_full_adder.v   # 공통 테스트벤치
├─ images/
│  ├─ block.png      # 블록 다이어그램
│  └─ wave.png       # 시뮬레이션 파형
└─ README.md         # 이 문서
```

- `full_adder.v`  
  - 게이트 조합으로 1-bit 풀가산기 구현
- `full_adder_sv.sv`  
  - 같은 기능을 SystemVerilog 스타일로 작성한 버전 (있으면)
- `tb_full_adder.v`  
  - 3비트 입력(000~111) 전체 패턴을 적용해서 `oSUM`, `oCARRY`를 검증
- `images/*.png`  
  - 포트폴리오 / 문서용 그림

핀맵(XDC), 시뮬레이션/합성/비트스트림 플로우는  
레포 루트의 공통 문서(`README.md`, `doc/flow.md` 등)를 참고.

---

## 5. 실행 요약

레포 **루트**에서 아래처럼 실행한다고 가정.

```bash
# Vivado xsim 시뮬레이션 (콘솔)
$ make xsim EX=examples/02.full_adder

# Vivado xsim GUI
$ make xsim_gui EX=examples/02.full_adder
```

보드 다운로드, ModelSim 사용, Vivado 합성/비트스트림 플로우는  
공통 가이드에 정리하고, 각 예제 README에서는 이 정도 요약만 남기는 구조로 사용.

# 01. Gates – AND / OR / NOT / NAND

> Basys3 (XC7A35T-1CPG236C) · Vivado 2022.2 · Language: Verilog / SystemVerilog

---

## 1. 예제 개요

- 두 입력 `iA`, `iB`에 대해 AND, OR, NOT, NAND 출력을 만드는 가장 기본적인 조합논리 예제
- 동일 기능을 Verilog / SystemVerilog로 작성해서 비교하는 베이스 예제
- 이후 MUX, 카운터, UART 같은 다른 예제들도 **제목/이미지/파일명만 바꿔서** 같은 형태로 정리하는 것을 목표

---

## 2. 블록 다이어그램

```text
examples/01.gates/images/block.png
```

![Gates block diagram](./images/block.png)

게이트 구성

- `U0` : AND (`oAND`)
- `U1` : OR  (`oOR`)
- `U2` : NOT (`oNOT`)
- `U3` : NAND (`oNAND`)
- `U4` + `U5` : AND → NOT 으로 만든 두 번째 NAND (`oNAND2`)

---

## 3. 시뮬레이션 파형

```text
examples/01.gates/images/wave.png
```

![Gates simulation waveform](./images/wave.png)

- `iA`, `iB` 입력을 00 → 01 → 10 → 11 순서로 변화
- 각 출력(`oAND`, `oOR`, `oNOT`, `oNAND`, `oNAND2`)이 트루스 테이블과 일치하는지 확인

---

## 4. 파일 구성

```text
examples/01.gates/
├─ gates.v         # Verilog RTL
├─ gates_sv.sv     # SystemVerilog RTL (옵션)
├─ tb_gates.v      # 공통 테스트벤치
├─ images/
│  ├─ block.png    # 블록 다이어그램
│  └─ wave.png     # 시뮬레이션 파형
└─ README.md       # 이 문서
```

- `gates.v`  
  - AND / OR / NOT / NAND 게이트 조합 회로
- `gates_sv.sv`  
  - 같은 기능을 SystemVerilog 스타일로 작성한 버전 (있으면)
- `tb_gates.v`  
  - `iA`, `iB` 패턴을 4가지 경우(00,01,10,11)로 바꾸며 출력 검증
- `images/*.png`  
  - 포트폴리오 / 문서용 그림

핀맵(XDC), 시뮬레이션/합성/비트스트림 플로우는  
레포 루트의 공통 문서(`README.md`, `doc/flow.md` 등)를 참고.

---

## 5. 실행 요약

레포 **루트**에서 아래처럼 실행한다고 가정.

```bash
# Vivado xsim 시뮬레이션 (콘솔)
make xsim EX=examples/01.gates

# Vivado xsim GUI
make xsim_gui EX=examples/01.gates
```

보드 다운로드, ModelSim 사용, Vivado 합성/비트스트림 플로우는  
공통 가이드에 정리하고, 각 예제 README에서는 이 정도 요약만 남기는 구조로 사용.

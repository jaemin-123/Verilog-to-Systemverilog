# 04. ALU – 4-bit Arithmetic Logic Unit

> Basys3 (XC7A35T-1CPG236C) · Vivado 2022.2 · Language: Verilog / SystemVerilog

---

## 1. 예제 개요

- 4비트 입력 `iA[3:0]`, `iB[3:0]`와  
  연산 선택 코드 `iINST[3:0]`를 받아서  
  8비트 결과 `oRESULT[7:0]`를 만드는 **간단한 ALU 예제**
- `iINST` 값에 따라 덧셈, 뺄셈, 논리 연산(AND/OR/XOR 등)과  
  기타 테스트용 연산들을 포함하도록 구성
- 작은 비트폭이지만, 이후에 8/16/32비트 ALU나 CPU 데이터패스로 확장하기 위한 기본 형태

---

## 2. 블록 다이어그램

<img width="487" height="267" alt="image" src="https://github.com/user-attachments/assets/804093a4-c5d2-496e-9755-49f1baca2e5d" />

- `iA[3:0]` : 첫 번째 피연산자  
- `iB[3:0]` : 두 번째 피연산자  
- `iINST[3:0]` : 연산 선택 코드 (opcode)
  - 예시) `0`=ADD, `1`=SUB, `2`=AND, `3`=OR, `4`=XOR, ...
- `oRESULT[7:0]` : 선택된 연산 결과

---

## 3. 시뮬레이션 파형

<img width="1286" height="125" alt="image" src="https://github.com/user-attachments/assets/4bfb2696-bc6f-4b30-93ae-ae2a3a487c7a" />

- `iA`, `iB`는 고정된 값(예: `iA=0xA`, `iB=0x6`)으로 두고  
  `iINST`를 `0 → 1 → 2 → …` 순서로 증가시키면서  
  각 opcode에 대해 `oRESULT`가 예상 연산 결과와 맞는지 확인
- 파형에서 `iINST` 값이 바뀔 때마다 `oRESULT`가 다른 값으로 점프하는지 보는 식으로  
  **연산 선택 로직이 제대로 동작하는지** 체크

---

## 4. 파일 구성

```text
examples/04.alu/
├─ alu.v            # Verilog RTL
├─ alu_sv.sv        # SystemVerilog RTL (옵션)
├─ tb_alu.v         # 공통 테스트벤치
└─ README.md        # 이 문서
```

- `alu.v`  
  - `case (iINST)` 형태로 여러 연산을 선택하는 4비트 ALU 구현
- `alu_sv.sv`  
  - 같은 기능을 SystemVerilog 스타일(`logic`, `always_comb`, enum opcode 등)로 작성한 버전 (있으면)
- `tb_alu.v`  
  - `iA`, `iB`를 몇 가지 값으로 고정하고, `iINST`를 순차적으로 변경하면서 `oRESULT`를 검증

---

## 5. 실행 요약

레포 **루트**에서 아래처럼 실행한다고 가정.

```bash
# Vivado xsim 시뮬레이션 (콘솔)
$ make xsim EX=ALU

# Vivado xsim GUI
$ make xsim_gui EX=ALU
```


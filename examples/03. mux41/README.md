# 03. Multiplexer – 4-to-1 8-bit MUX

> Basys3 (XC7A35T-1CPG236C) · Vivado 2022.2 · Language: Verilog / SystemVerilog

---

## 1. 예제 개요

- 8비트 입력 `iA`, `iB`, `iC`, `iD` 중에서  
  2비트 선택 신호 `iSEL[1:0]`에 따라 하나를 고르는 **4-to-1 멀티플렉서** 예제
- 동일 기능을 Verilog / SystemVerilog로 작성해서 비교하는 목적

---

## 2. 블록 다이어그램

<img width="538" height="317" alt="image" src="https://github.com/user-attachments/assets/a5891b5d-e059-402d-9464-f7c729c9d32b" />

- `iA[7:0]`, `iB[7:0]`, `iC[7:0]`, `iD[7:0]` : 4개의 8비트 입력
- `iSEL[1:0]` : 선택 신호
  - `00` → `iA`
  - `01` → `iB`
  - `10` → `iC`
  - `11` → `iD`
- `oOUT[7:0]` : 선택된 입력이 전달되는 출력

---

## 3. 시뮬레이션 파형

<img width="1286" height="179" alt="image" src="https://github.com/user-attachments/assets/b931aca9-a657-458f-b39f-a8c8caee99ee" />

- 각 입력에 고정된 값을 넣고  
  `iSEL` 값을 `00 → 01 → 10 → 11` 순서로 바꿔가며 동작 확인
- `iSEL` 값에 따라 `oOUT`이 각각 `iA`, `iB`, `iC`, `iD` 값으로 바뀌는지 확인

---

## 4. 파일 구성

```text
examples/03.mux41/
├─ mux41.v           # Verilog RTL (4-to-1 8bit MUX)
├─ mux41_sv.sv       # SystemVerilog RTL (옵션)
├─ tb_mux41.v        # 공통 테스트벤치
└─ README.md        # 이 문서
```

- `mux41.v`  
  - case문 또는 삼항연산자를 이용해 4:1 멀티플렉서 구현
- `mux41_sv.sv`  
  - 같은 기능을 SystemVerilog 스타일(`logic`, `always_comb` 등)로 작성한 버전 (있으면)
- `tb_mux41.v`  
  - `iSEL`을 0~3으로 바꾸면서 `oOUT`이 해당 입력과 같은지 검증

---

## 5. 실행 요약

레포 **루트**에서 아래처럼 실행한다고 가정.

```bash
# Vivado xsim 시뮬레이션 (콘솔)
$ make xsim EX=mux41

# Vivado xsim GUI
$ make xsim_gui EX=mux41
```

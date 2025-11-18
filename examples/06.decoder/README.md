# 06. Decoder – 4-to-10 Decoder

> Basys3 (XC7A35T-1CPG236C) · Vivado 2022.2 · Language: Verilog / SystemVerilog

---

## 1. 예제 개요

- 4비트 입력 `iIN[3:0]`을 받아서  
  해당 값에 맞는 비트 하나만 1이 되도록 `oOUT[9:0]`으로 내보내는 **4-to-10 디코더** 예제
- 인코더 예제와 짝을 이루는 기본 조합논리 블록

---

## 2. 블록 다이어그램

<img width="482" height="449" alt="image" src="https://github.com/user-attachments/assets/5f9f3519-360f-4068-8d8a-d3d09d3f22d2" />

- `iIN[3:0]` : 0~9 범위의 4비트 이진수 입력
- `oOUT[9:0]` : one-hot 출력
  - `iIN = 0` → `oOUT = 0000000001`
  - `iIN = 1` → `oOUT = 0000000010`
  - ...
  - `iIN = 9` → `oOUT = 1000000000`

---

## 3. 시뮬레이션 파형

<img width="1283" height="83" alt="image" src="https://github.com/user-attachments/assets/c0358d54-cf33-417c-be53-c9b35065269d" />

- `iIN` 값을 0,1,2,3,4,5,6,7,8,9 순서로 증가시키면서  
  `oOUT`이 각 단계마다 해당 비트 하나만 1로 바뀌는지 확인

---

## 4. 파일 구성

```text
examples/06.decoder/
├─ decoder.v        # Verilog RTL (4-to-10 디코더)
├─ decoder_sv.sv    # SystemVerilog RTL (옵션)
├─ tb_decoder.v     # 공통 테스트벤치
└─ README.md          # 이 문서
```

- `decoder.v`  
  - `case (iIN)` 또는 시프트 연산을 이용해 4비트 입력을 10비트 one-hot으로 변환
- `decoder_sv.sv`  
  - 같은 기능을 SystemVerilog 스타일로 작성한 버전 (있으면)
- `tb_decoder.v`  
  - `iIN`을 0~9로 바꿔 가며 `oOUT` one-hot 출력이 정상인지 검증

---

## 5. 실행 요약

레포 **루트**에서 아래처럼 실행한다고 가정.

```bash
# Vivado xsim 시뮬레이션 (콘솔)
$ make xsim EX=decoder

# Vivado xsim GUI
$ make xsim_gui EX=decoder
```

# 05. Encoder – 10-to-4 BCD Encoder

> Basys3 (XC7A35T-1CPG236C) · Vivado 2022.2 · Language: Verilog / SystemVerilog

---

## 1. 예제 개요

- 10비트 입력 `iIN[9:0]` 중 하나만 1이 되는 **one-hot 입력**을 가정하고  
  해당 위치를 4비트 이진수로 변환해서 `oOUT[3:0]`으로 출력하는 **10-to-4 인코더** 예제
- 예를 들어
  - `iIN = 0000000001` → `oOUT = 4'd0`
  - `iIN = 0000000010` → `oOUT = 4'd1`
  - ...
  - `iIN = 1000000000` → `oOUT = 4'd9`

---

## 2. 블록 다이어그램

<img width="404" height="439" alt="image" src="https://github.com/user-attachments/assets/14c5ed80-c778-49c0-8a90-2e2300cc44cd" />

- `iIN[9:0]` : 10개의 one-hot 입력  
- `oOUT[3:0]` : 0~9를 표현하는 4비트 이진수 출력

---

## 3. 시뮬레이션 파형

<img width="1286" height="91" alt="image" src="https://github.com/user-attachments/assets/d86acf9c-efcc-4059-87cf-8c9883d9b4ae" />

- `iIN`을 `0000000001 → 0000000010 → 0000000100 → ... → 1000000000` 순서로 변경
- 각 입력에서 `oOUT`이 0,1,2,3,4,5,6,7,8,9 로 증가하는지 확인

---

## 4. 파일 구성

```text
examples/05.encoder/
├─ encoder10.v        # Verilog RTL (10-to-4 인코더)
├─ encoder10_sv.sv    # SystemVerilog RTL (옵션)
├─ tb_encoder10.v     # 공통 테스트벤치
└─ README.md          # 이 문서
```

- `encoder10.v`  
  - `case`문 또는 `if`문을 이용해 one-hot 입력을 4비트 코드로 변환
- `encoder10_sv.sv`  
  - 같은 기능을 SystemVerilog 스타일(`logic`, `always_comb` 등)로 작성한 버전 (있으면)
- `tb_encoder10.v`  
  - `iIN`을 10개 one-hot 패턴으로 순차 적용하면서 `oOUT`이 0~9인지 검증

---

## 5. 실행 요약

레포 **루트**에서 아래처럼 실행한다고 가정.

```bash
# Vivado xsim 시뮬레이션 (콘솔)
$ make xsim EX=encoder

# Vivado xsim GUI
$ make xsim_gui EX=encoder
```

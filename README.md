# Verilog & SystemVerilog (SV)

- 동일 기능을 Verilog → SystemVerilog로 리팩터링하며 차이점, 베스트프랙티스를 정리
- Basys3 / Zybo-Z7 보드와 Vivado / Quartus 플로우

## 구성
- [Verilog 정리](docs/verilog.md)
- [SystemVerilog(SV) 정리](docs/systemverilog.md)
- [Verilog vs SV 비교표](docs/comparison.md)
- [예제 모음](examples)
- [보드별 가이드](boards)
- [툴체인 플로우](flows)
- 레포 구조 (요약)

---

## 예제 모음 (V→SV 변환 기록)

| 주제 | Verilog | SystemVerilog | Testbench | 메모 |
|---|---|---|---|---|
| 게이트(기초) | [examples/01. gates/gates.v](examples/01.%20gates/gates.v) | [examples/01. gates/gates_sv.sv](examples/01.%20gates/gates_sv.sv) | [examples/01. gates/tb_gates.v](examples/01.%20gates/tb_gates.v) |  |
| 1-bit/풀가산기 | [examples/02.full_adder/full_adder.v](examples/02.full_adder/full_adder.v) | [examples/02.full_adder/full_adder_sv.sv](examples/02.full_adder/full_adder_sv.sv) | [examples/02.full_adder/tb_full_adder.v](examples/02.full_adder/tb_full_adder.v) |  |
| 4:1 MUX | [examples/03. mux41/mux41.v](examples/03.%20mux41/mux41.v) | [examples/03. mux41/mux41_sv.sv](examples/03.%20mux41/mux41_sv.sv) | [examples/03. mux41/tb_mux41.v](examples/03.%20mux41/tb_mux41.v) |  |

## 보드별 가이드

- [Basys3](boards/basys3/)
- [Zybo-Z7](boards/zybo-z7/)

## 툴체인 플로우

- [Vivado](flows/vivado/)
- [Quartus](flows/quartus/)

## 레포 구조 (요약)

- docs/ — Verilog·SV 정리 및 비교
- examples/ — 소형 예제(V→SV 변환 기록)
- boards/ — 보드별 제약/가이드
- flows/ — Vivado/Quartus 스크립트

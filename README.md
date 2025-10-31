# Verilog & SystemVerilog (SV)

- 동일 기능을 Verilog → SystemVerilog로 리팩터링하며 차이점, 베스트프랙티스를 정리
- Basys3 / Zybo-Z7 보드와 Vivado / Quartus 플로우

## 목차
1. 개요와 목표
2. [Verilog 개요](docs/verilog.md)
3. [SystemVerilog(SV) 개요](docs/systemverilog.md)
4. [Verilog vs SV 비교표](docs/comparison.md)
5. 예제 모음
6. 보드별 가이드
7. 툴체인 플로우
8. 레포 구조
9. 로드맵 / 진행 현황

## 1. 개요와 목표
- Verilog로 기본기를 다지고 SV식 RTL 코딩 패턴(logic, always_comb/always_ff, enum 등)으로 리팩터링합니다.
- 동일 주제(게이트, 가산기, 멀티플렉서 등)를 V/SV로 나란히 비교합니다.
- Vivado / Quartus와 Basys3 / Zybo-Z7 환경을 사용합니다.

## 2. Verilog 개요
- 문법 치트시트, 합성 규칙, 흔한 함정은 docs/verilog.md 참고

## 3. SystemVerilog(SV) 개요
- logic, always_comb, always_ff, enum, packed struct, 가변 슬라이스(+:) 등은 docs/systemverilog.md 참고

## 4. Verilog vs SV 비교표
- 핵심 차이, 장단점, 코드 스니펫 비교는 docs/comparison.md 참고

## 5. 예제 모음 (V→SV 변환 기록)
- 01. 게이트(기초)
  - Verilog: examples/01.gates/gates.v
  - SV: examples/01.gates/gates_sv.sv (있으면)
  - TB: examples/01.gates/tb_gates.v
- 02. 1-bit/풀가산기
  - Verilog: examples/02.full_adder/full_adder.v
  - SV: examples/02.full_adder/full_adder_sv.sv (있으면)
  - TB: examples/02.full_adder/tb_full_adder.v
- 03. 4:1 MUX
  - Verilog: examples/03.mux41/mux41.v
  - SV: examples/03.mux41/mux41_sv.sv (있으면)
  - TB: examples/03.mux41/tb_mux41.v

## 6. 보드별 가이드
- Basys3: boards/basys3/
- Zybo-Z7: boards/zybo-z7/
- Intel 보드는 추후 boards/<intel-board>/ 로 추가(QSF/SDC 포함)

## 7. 툴체인 플로우
- Vivado 스크립트: flows/vivado/
- Quartus 스크립트: flows/quartus/
- 플로우 스크립트는 코드와 분리해 재현성을 높이고, 보드/툴이 늘어나도 구조를 유지합니다.

## 8. 레포 구조
- boards/ : 보드별 제약과 가이드(Basys3, Zybo-Z7 등)
- docs/ : Verilog, SV 치트시트와 전반 비교 문서
- examples/ : 소형 예제(V→SV 변환 기록)
- flows/ : Vivado, Quartus 실행 스크립트
- README.md : 이 파일

## 9. 로드맵 / 진행 현황
- [ ] examples/01.gates SV 버전 및 비교 노트 추가
- [ ] examples/02.full_adder SV 버전 및 파형 캡처
- [ ] examples/03.mux41 SV 버전 및 Vivado XSIM 스크립트
- [ ] ALU 토픽 추가(Verilog/SV, TB, 비교문서, 파형)
- [ ] Basys3 다운로드 튜토리얼 이미지/영상 추가
- [ ] Zybo-Z7 예제 1건 동작 확인
- [ ] (선택) UVM 맛보기: 간단 env와 smoke test

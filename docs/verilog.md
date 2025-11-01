# Verilog Cheatsheet & Patterns (입문자용)

**Home → README → Verilog**  
SystemVerilog 업그레이드: [`systemverilog.md`](systemverilog.md) · 차이표: [`comparison.md`](comparison.md)

---

## 목차
- [기본 문법](#기본-문법)
  - [모듈/포트](#모듈포트)
  - [타입](#타입)
  - [벡터/폭](#벡터폭)
  - [리터럴/특수값](#리터럴특수값)
  - [결합/반복](#결합반복)
  - [SV 차이는?](#sv-차이는)
- [연속 할당 vs 절차 블록](#연속-할당-vs-절차-블록)
  - [선택 가이드](#선택-가이드)
  - [SV 차이는?](#sv-차이는-1)
- [조합회로](#조합회로)
  - [SV 차이는?](#sv-차이는-2)
- [순차회로](#순차회로)
  - [SV 차이는?](#sv-차이는-3)
- [블로킹 vs 논블로킹](#블로킹-vs-논블로킹)
  - [SV 차이는?](#sv-차이는-4)
- [FSM 템플릿](#fsm-템플릿)
  - [SV 차이는?](#sv-차이는-5)
- [파라미터/제너레이트](#파라미터제너레이트)
  - [SV 차이는?](#sv-차이는-6)
- [합성 vs 시뮬레이션 주의](#합성-vs-시뮬레이션-주의)
  - [SV 차이는?](#sv-차이는-7)
- [CDC](#cdc)
  - [SV 차이는?](#sv-차이는-8)
- [테스트벤치(TB) 기초](#테스트벤치tb-기초)
  - [SV 차이는?](#sv-차이는-9)
- [네비게이션](#네비게이션)

---

## 기본 문법

### 모듈/포트
```verilog
module my_and (
  input  a, b,
  output y
);
  assign y = a & b;
endmodule

# Verilog 문법 정리 (Cheatsheet)

> 목표: 합성 가능한 RTL 중심으로 Verilog 문법을 빠르게 훑고, 실전에서 자주 쓰는 규칙과 함정을 정리한다.

---

## 1) 모듈 기본 형식
```verilog
`timescale 1ns/1ps

module my_module #(
  parameter WIDTH = 8
)(
  input              clk, rst_n,
  input  [WIDTH-1:0] a, b,
  output [WIDTH-1:0] y
);
  // ...
endmodule
```

## 2) 자료형과 논리값
- net형 : `wire`(연속 할당/ 연결선)
- reg형 : `reg`(절차적 블록에서 대입되는 저장 요소)
- 논리값 : `0`, `1`, `X`(unknown), `Z`(high-Z)
```verilog
wire       w1;
reg  [3:0] r4;
```

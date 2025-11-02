# Gates (AND / OR / NOT / NAND)

> **Board:** Basys3 (XC7A35T-1CPG236C) · **Vivado:** 2022.2 · **Language:** Verilog HDL

<img width="437" height="472" alt="image" src="https://github.com/user-attachments/assets/dd989f9c-6197-4379-9690-53cd69a7ab4b" />


---

## Truth Table
| iA | iB | AND | OR | NOT(iA) | NAND | NAND2 |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 0 | 0 | 0 | 0 | 1 | 1 | 1 |
| 0 | 1 | 0 | 1 | 1 | 1 | 1 |
| 1 | 0 | 0 | 1 | 0 | 1 | 1 |
| 1 | 1 | 1 | 1 | 0 | 0 | 0 |

## Pin Map (Basys3)
| Port  | Pin | IO Std   | Resource |
|------|-----|----------|----------|
| iA     | V17 | LVCMOS33 | SW0  |
| iB     | V16 | LVCMOS33 | SW1  |
| oAND   | U16 | LVCMOS33 | LED0 |
| oOR    | E19 | LVCMOS33 | LED1 |
| oNOT   | U19 | LVCMOS33 | LED2 |
| oNAND  | V19 | LVCMOS33 | LED3 |
| oNAND2 | W18 | LVCMOS33 | LED4 |

---

## Simulation
<img width="1138" height="245" alt="image" src="https://github.com/user-attachments/assets/5d3d3ced-a690-4c46-8217-1d001b92f495" />

### Vivado xsim (Non‑project, 추천)
```bash
# 동일 폴더에 gates.v / tb_gates.v가 있다고 가정
xvlog gates.v tb_gates.v
xelab tb_gates -s tb_gates_sim --debug typical
xsim tb_gates_sim -gui
#위의 3개를 한번에
make gui-xsim
# xsim 콘솔에서:
add_wave -recursive *
run all
```
> **xvlog: 소스 컴파일**
> **xelab: 엘라보(링킹/스냅샷 생성)**
> **xsim: 실행(콘솔/GUI)**

### ModelSim‑Intel / Questa
```tcl
vdel -all
vlib work
vlog +acc gates.v tb_gates.v
vsim tb_gates
add wave -r /*
run -all
```

> 테스트벤치 팁: 배치 실행이면 `$finish` 권장. 파형 로그를 남기려면 `$monitor`/`$dump*`(툴에 따라)를 추가하세요.

---

## Synthesis & Bitstream (Vivado)

1. **Create Project** → `gates.v` 추가, **Top = gates**
2. 아래 **XDC**를 추가
3. **Generate Bitstream** (Synthesis → Implementation → Bitstream)
4. **Open Hardware Manager** → Program Device

```tcl
# .xdc
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports iA]
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports iB]
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports oAND]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports oOR]
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports oNOT]
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports oNAND]
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports oNAND2]
```

> 주의: **Top은 테스트벤치가 아닌 `gates`** 여야 합니다. TB는 시뮬 전용.

---

## Source Code

### `gates.v`
```verilog
`timescale 1ns/1ps
`default_nettype none

module gates(
  input  wire iA, iB,
  output wire oAND, oOR, oNOT, oNAND, oNAND2
);
  wire s0;
  and  U0 (oAND , iA, iB);
  or   U1 (oOR  , iA, iB);
  not  U2 (oNOT , iA);
  nand U3 (oNAND, iA, iB);
  and  U4 (s0, iA, iB);
  not  U5 (oNAND2, s0);
endmodule

`default_nettype wire
```

### `tb_gates.v`
```verilog
`timescale 1ns/1ps
module tb_gates;
  reg  iA, iB;
  wire oAND, oOR, oNOT, oNAND, oNAND2;

  gates U0(.iA(iA), .iB(iB), .oAND(oAND), .oOR(oOR),
           .oNOT(oNOT), .oNAND(oNAND), .oNAND2(oNAND2));

  initial begin
    $monitor("%t iA=%0b iB=%0b AND=%0b OR=%0b NOT=%0b NAND=%0b NAND2=%0b",
             $time, iA,iB,oAND,oOR,oNOT,oNAND,oNAND2);
    iA=0; iB=0; #10;
    iA=0; iB=1; #10;
    iA=1; iB=0; #10;
    iA=1; iB=1; #10;
    $finish;
  end
endmodule
```

---

## Files & Tree
```
01.gates/
  gates.v
  tb_gates.v
  xdc/gates.xdc
  scripts/
    Makefile       # sim-msim / sim-xsim (xelab --debug typical 포함)
    run.do         # ModelSim
    xsim.tcl       # Vivado non-project
  README.md
```

---

## Troubleshooting
- **xsim에서 파형이 안 뜸** → `xelab --debug typical`로 재컴파일.
- **UCIO‑1 / NSTD‑1 경고** → XDC 핀 누락/IOSTANDARD 누락.
- **missing separator** → Makefile 탭/개행(LF) 확인 + BOM 제거.

---

## Tcl (Non‑project)
```bash
vivado -mode batch -source scripts/xsim.tcl
```

# mux41
> Board: Digilent Basys3 (XC7A35T-1CPG236C)  
> Vivado: 2022.2  
> Language: Verilog HDL

<img width="474" height="283" alt="image" src="https://github.com/user-attachments/assets/ff032d51-910c-480d-a2fe-6e0c6db1d5a8" />


---

### Truth Table
| iA | iB | iC | iD | iSEL | oOUT |
|---|---|---|---|---|---|
| iA | iB | iC | iD | 00 | iA |
| iA | iB | iC | iD | 01 | iB |
| iA | iB | iC | iD | 10 | iC |
| iA | iB | iC | iD | 11 | iD |
- 입력 1비트 iSEL 2비트

### 핀 매핑 (Basys3)
| HDL Port | Basys3 Pin | IO Std   | 보드 리소스 |
|---|---|---|---|
| iSEL_sw[0] | V17 | LVCMOS33 | SW0  |
| iSEL_sw[1] | V16 | LVCMOS33 | SW1  |
| LED0  | U16 | LVCMOS33 | LED0 |
| BTN_A | U18 | LVCMOS33 | btnC |
| BTN_B | T18 | LVCMOS33 | btnU |
| BTN_C | W19 | LVCMOS33 | btnL |
| BTN_D | T17 | LVCMOS33 | btnR |
- mux41 module 코드
  - A, B, C, D 각 8개씩 `.xdc` 설정 못함
  - 상위 7비트 0, 첫번째 비트만 버튼으로 입력

---

```
// src/mux41.v
module mux41a(iA, iB, iC, iD, iSEL, oOUT);
    input [7:0] iA, iB, iC, iD;
    input [1:0] iSEL;
    output [7:0] oOUT;
    
    assign oOUT = (iSEL == 0) ? iA:
                (iSEL == 1) ? iB:
                (iSEL == 2) ? iC : iD;
endmodule

module mux41(
  input  wire [1:0] iSEL_sw, // SW1:MSB, SW0:LSB
  input  wire BTN_A,         // -> iA[0]
  input  wire BTN_B,         // -> iB[0]
  input  wire BTN_C,         // -> iC[0]
  input  wire BTN_D,         // -> iD[0]
  output wire LED0           // oOUT[0]만 표시
);
  // 8비트 입력을 최소화: 상위 7비트는 0, LSB는 버튼
  wire [7:0] iA = {7'b0, BTN_A};
  wire [7:0] iB = {7'b0, BTN_B};
  wire [7:0] iC = {7'b0, BTN_C};
  wire [7:0] iD = {7'b0, BTN_D};

  wire [7:0] oOUT;

  mux41a U0(
    .iA(iA), 
    .iB(iB), 
    .iC(iC), 
    .iD(iD),
    .iSEL(iSEL_sw),
    .oOUT(oOUT)
  );

  assign LED0 = oOUT[0]; // LSB만 LED로 확인
endmodule
```

---

- test bench
```
// tb/tb_mux41.v
`timescale 1ns/10ps

module tb_mux41 
    reg [7:0] iA, iB, iC, iD;
    reg [1:0] iSEL;
    wire [7:0] oOUT;

    mux41a U0 (
        .iA (iA),
        .iB (iB),
        .iC (iC),
        .iD (iD),
        .iSEL (iSEL),
        .oOUT (oOUT));
    
    initial begin 
        iA = 8'h00; iB = 8'h01; iC = 8'h00; iD = 8'h00; iSEL = 2'b00; #100
        iA = 8'h00; iB = 8'h01; iC = 8'h00; iD = 8'h00; iSEL = 2'b01; #100
        iA = 8'h00; iB = 8'h01; iC = 8'h00; iD = 8'h00; iSEL = 2'b10; #100
        iA = 8'h00; iB = 8'h01; iC = 8'h00; iD = 8'h00; iSEL = 2'b11; #100
    end
    
endmodule
```

---

- `.xdc` 설정
```
# xdc/mux41.xdc
## Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {iSEL_sw[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {iSEL_sw[1]}]

## LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {LED0}]

##Buttons
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports {BTN_A}] 
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports {BTN_B}] 
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports {BTN_C}] 
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports {BTN_D}]
```

---

- Schematic
<img width="821" height="464" alt="image" src="https://github.com/user-attachments/assets/96e9232e-b07d-4c1a-a5e9-ad8ba3a05711" />

---

- Device layout
<img width="269" height="364" alt="image" src="https://github.com/user-attachments/assets/0c327833-0ffc-4fe0-b14c-7796b5ac7ca7" />

---

- SIMULATION
<img width="670" height="226" alt="image" src="https://github.com/user-attachments/assets/c5a7eddf-11f0-4ad6-ba9d-0eb5e5d496b4" />


---

# `.tcl` 사용법
- 터미널에서 `.tcl`이 있는 폴더에서 실행
```
vivado -mode batch -source mux41.tcl
```



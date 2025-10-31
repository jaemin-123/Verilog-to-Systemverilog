# full_adder
> Board: Digilent Basys3 (XC7A35T-1CPG236C)  
> Vivado: 2022.2  
> Language: Verilog HDL

<img width="716" height="326" alt="image" src="https://github.com/user-attachments/assets/163d5b69-bf32-4101-afa5-7f3cd0c075c8" />

---

### Truth Table
| iX | iY | iCIN | oSUM | oCARRY |
|:-:|:-:|:-:|:-:|:-:|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 | 0 |
| 1 | 0 | 0 | 1 | 0 |
| 1 | 1 | 0 | 0 | 1 |
| 0 | 0 | 1 | 1 | 0 |
| 0 | 1 | 1 | 0 | 1 |
| 1 | 0 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 | 1 |

### 핀 매핑 (Basys3)
| HDL Port | Basys3 Pin | IO Std   | 보드 리소스 |
|---|---|---|---|
| iX      | V17 | LVCMOS33 | SW0  |
| iY      | V16 | LVCMOS33 | SW1  |
| iCIN    | W16 | LVCMOS33 | SW2  |
| oSUM    | U16 | LVCMOS33 | LED0 |
| oCARRY  | E19 | LVCMOS33 | LED1 |
- full_adder module 코드

---

```
// src/full_adder.v
module full_adder (iX, iY, iCIN, oSUM, oCARRY);

    input iX, iY, iCIN;
    output oSUM, oCARRY;

    reg s0, c0, c1;
    reg sum, carry;

    assign oSUM = sum;
    assign oCARRY = carry;

    always @(iX or iY or iCIN) begin
        s0 = iX ^ iY;
        c0 = iX & iY;
        c1 = s0 & iCIN;
        sum = s0 ^ iCIN;
        carry = c0 | c1;
    end
endmodule
```

---

- test bench
```
// tb/tb_full_adder.v
`timescale 1ns/1ps

module tb_full_adder;
    reg iX, iY, iCIN;
    wire oSUM, oCARRY;
    
    full_adder UFA(
        .iX (iX),
        .iY (iY),
        .iCIN (iCIN),
        .oSUM (oSUM),
        .oCARRY (oCARRY));
    
    initial begin
        iX = 0; iY = 0; iCIN = 0; #100;
        iX = 1; iY = 0; iCIN = 0; #100;
        iX = 0; iY = 1; iCIN = 0; #100;
        iX = 1; iY = 1; iCIN = 0; #100;
        iX = 0; iY = 0; iCIN = 1; #100;
        iX = 1; iY = 0; iCIN = 1; #100;
        iX = 0; iY = 1; iCIN = 1; #100;
        iX = 1; iY = 1; iCIN = 1; #100;
    end
endmodule
```

---

- `.xdc` 설정
```
# xdc/full_adder.xdc
## Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {iX}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {iY}]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports {iCIN}]

## LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {oSUM}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {oCARRY}]
```

---

- Schematic
<img width="1029" height="312" alt="image" src="https://github.com/user-attachments/assets/5bf27d4e-7f46-4532-9640-82a6d5acc661" />

---

- Device layout
<img width="174" height="411" alt="image" src="https://github.com/user-attachments/assets/594c3604-1f33-4fb7-950d-01d6d2a73827" />

---

- SIMULATION
<img width="464" height="202" alt="image" src="https://github.com/user-attachments/assets/2537c6c9-b43c-4387-b752-d5df36c46770" />

---

# `.tcl` 사용법
- 터미널에서 `.tcl`이 있는 폴더에서 실행
```
vivado -mode batch -source full_adder.tcl
```


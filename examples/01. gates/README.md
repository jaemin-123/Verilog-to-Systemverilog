# Gates (AND/OR/NOT/NAND)

> Board: Digilent Basys3 (XC7A35T-1CPG236C)  
> Vivado: 2022.2  
> Language: Verilog HDL

<img width="622" height="522" alt="image" src="https://github.com/user-attachments/assets/aa433313-a083-4a60-a4ec-152f0f6f2f6d" />

---

### Truth Table
| iA | iB | AND | OR | NOT(iA) | NAND | NAND2 |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 0 | 0 | 0 | 0 | 1 | 1 | 1 |
| 0 | 1 | 0 | 1 | 1 | 1 | 1 |
| 1 | 0 | 0 | 1 | 0 | 1 | 1 |
| 1 | 1 | 1 | 1 | 0 | 0 | 0 |

### 핀 매핑 (Basys3)
| HDL Port | Basys3 Pin | IO Std   | 보드 리소스 |
|---|---|---|---|
| iA      | V17 | LVCMOS33 | SW0  |
| iB      | V16 | LVCMOS33 | SW1  |
| oAND    | U16 | LVCMOS33 | LED0 |
| oOR     | E19 | LVCMOS33 | LED1 |
| oNOT    | U19 | LVCMOS33 | LED2 |
| oNAND   | V19 | LVCMOS33 | LED3 |
| oNAND2  | W18 | LVCMOS33 | LED4 |
- gates module 코드

---

```
// src/gates.v
module gates (iA, iB, oAND, oOR, oNOT, oNAND, oNAND2);
  input iA, iB;
  output oAND, oOR, oNOT, oNAND, oNAND2;

  wire s0;
  and U0 (oAND, iA, iB);
  or U1 (oOR, iA, iB);
  not U2 (oNOT, iA);
  nand U3 (oNAND, iA, iB);
  and U4 (s0, iA, iB);
  not U5 (oNAND2, s0);

endmodule
```

---

- test bench
```
// tb/tb_gates.v
`timescale 1ns/1ps

module tb_gates;
  reg iA, iB;
  wire oAND, oOR, oNOT, oNAND, oNAND2;
  // 이름에 의한 포트 맵핑 사용하여 gates를 인스턴스화
  gates U0 (
  .iA (iA), // 입력신호 iA
  .iB (iB), // 입력신호 iB
  .oAND (oAND), // 출력신호 oAND
  .oOR (oOR), // 출력신호 oOR
  .oNOT (oNOT), // 출력신호 oNOT
  .oNAND (oNAND), // 출력신호 oNAND
  .oNAND2 (oNAND2)); // 출력신호 oNAND2;
  // 입력신호 생성
  initial begin
    iA = 0; iB = 0; #100;
    iA = 0; iB = 1; #100;
    iA = 1; iB = 0; #100;
    iA = 1; iB = 1; #100;
    $stop;
  end

endmodule
```

---

- Generate Bitstream 진행 시 Synthesis, Implementation 모두 진행 됨
  - 입력(iA, iB)과 출력(oAND, oOR, oNOT, oNAND, oNAND2) `.xdc` 에서 설정 해주어야 함
  -  top module이 test bench 이면 안됨 기본 module이 top 이여야 함

<img width="630" height="533" alt="image" src="https://github.com/user-attachments/assets/0d1b348b-07b7-4845-9bee-96268cb5eeed" />

- `.xdc` 설정
```
# xdc/gates.xdc
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {iA}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {iB}]

set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {oAND}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {oOR}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {oNOT}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports {oNAND}]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports {oNAND2}]
```
<img width="227" height="72" alt="image" src="https://github.com/user-attachments/assets/be6009fe-e017-4c3a-9fa4-56f51448d481" />

---

- 완료

<img width="426" height="401" alt="image" src="https://github.com/user-attachments/assets/d4eb3ddd-cd3e-4551-884b-14809420f4aa" />

---

- Schematic
<img width="1067" height="524" alt="image" src="https://github.com/user-attachments/assets/170a6f5d-e13a-4df9-bb56-dd754b894688" />

---

- Device layout
<img width="209" height="525" alt="image" src="https://github.com/user-attachments/assets/2cb8fa96-c9f8-4c84-aad5-7321e4852938" />

---

- SIMULATION
<img width="525" height="238" alt="image" src="https://github.com/user-attachments/assets/b67d6760-8821-4ca1-96ee-e03c30f538b5" />
<img width="1070" height="635" alt="image" src="https://github.com/user-attachments/assets/f6059fe6-e1c8-4ab4-ac6b-44ef5f5baa8c" />

---

- 보드 연결
<img width="218" height="167" alt="image" src="https://github.com/user-attachments/assets/bfba3198-bc5a-4b8a-8243-b57e9d39b41b" />

- Program Device
<img width="476" height="368" alt="image" src="https://github.com/user-attachments/assets/16b0f6c9-140d-492c-b281-9d2623de0cff" />


<img width="596" height="318" alt="image" src="https://github.com/user-attachments/assets/58e912d4-fe23-4afb-9436-259d31c6ed1f" />

---

# `.tcl` 사용법
- 터미널에서 `.tcl`이 있는 폴더에서 실행
```
vivado -mode batch -source gates.tcl
```


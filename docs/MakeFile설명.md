# Verilog Examples Flow (MSYS2 + Vivado 2022.2)

## 0. 폴더 위치 / 기본 구조

### 0-1. 경로

- Vivado 2022.2:
  - `C:\Xilinx\Vivado\2022.2\bin\vivado.exe`

- Verilog 예제 레포 (예시):
  - `C:\Users\54\Auto_verilog`

MSYS2에서는 이렇게 보임:

```bash
$ cd /c/Users/54/Auto_verilog
$ pwd
/c/Users/54/Auto_verilog
```

### 0-2. 레포 디렉터리 구조

```text
Auto_verilog/
├─ Makefile          # msim/xsim/synth/bit/harvest 공통 Makefile
├─ xsim.tcl          # Vivado xsim 공통 Tcl
├─ xsim_run_vcd.tcl  # (있으면 사용, 없으면 xsim.tcl에서 자동 생성)
├─ synth.tcl         # Vivado 합성 스크립트
├─ bit.tcl           # Vivado 구현 + 비트스트림 스크립트
├─ run.do            # ModelSim/Questa DO 스크립트
├─ gate/             # 예제 (EX=gate 로 사용)
│  ├─ gates.v
│  ├─ tb_gates.v     # tb_*.v 형태의 테스트벤치 (필수)
│  └─ gates.xdc      # 필요하면 XDC
├─ <다른 예제들>     # EX=adder, EX=counter ... 이런 식으로 추가
└─ artifacts/        # harvest 결과 저장용 (자동 생성)
```

**예제 폴더 공통 규칙**

- 각 예제 폴더(EX)는 기본적으로 아래 파일 포함:
  - `*.v`        → RTL
  - `tb_*.v`     → 테스트벤치 (여기서 TOP 이름 자동 추출)
  - 필요 시 `*.xdc`, `example.mk` 추가

---

## 1. MSYS2에서 작업 시작

### 1-1. MSYS2 실행 후 레포로 이동

MSYS2 MinGW64 켠 다음:

```bash
$ cd /c/Users/54/Auto_verilog
$ ls
Makefile  xsim.tcl  gate/  ...
```

### 1-2. Makefile 사용법 확인

```bash
$ make help
```

예상 출력 예:

```text
make xsim  EX=gate                      # Vivado xsim 시뮬
make msim  EX=gate [VSIM=...]          # ModelSim/Questa 시뮬
make synth EX=gate DUT=gates           # 합성 (Top 모듈명 필요)
make bit   EX=gate DUT=gates           # 배치/라우트/비트스트림
옵션: PART=...  XDC=...  OUT=...
```

---

## 2. Vivado xsim 시뮬레이션 (VCD 자동 생성)

### 2-1. 배치 모드 + VCD 생성

예: `EX=gate` 예제 시뮬레이션

```bash
$ cd /c/Users/54/Auto_verilog
$ make xsim EX=gate
```

동작 내용

- 사용 RTL / TB:
  - `gate/*.v`
  - `gate/tb_gates.v`
- 내부 플로우:
  - `xvlog` → `xelab` → `xsim`
- `xsim_run_vcd.tcl`에서 하는 일:
  - `log_wave -recursive *`
  - `open_vcd sim.vcd`
  - `log_vcd *`
  - `run 1 us` (시간 필요하면 수정)
  - `close_vcd`

결과

- 현재 디렉토리에:
  - `sim.vcd` 생성
  - `tb_gates_sim.wdb` 생성 (GUI 파형용)

원하면 GTKWave로 확인:

```bash
$ gtkwave sim.vcd
```

---

### 2-2. xsim GUI 파형 보기

같은 예제를 GUI로 보고 싶을 때:

```bash
$ cd /c/Users/54/Auto_verilog
$ make xsim_gui EX=gate
```

내부 동작

- `make xsim EX=gate XSIM_OPTS=--gui` 실행
- `xsim.tcl`에서:
  - 환경변수 `XSIM_GUI=1` 설정
  - `xsim tb_gates_sim -gui -tclbatch xsim_run_vcd.tcl` 실행
- 1 µs 동안:
  - wdb 파형 기록
  - `sim.vcd` 생성
- xsim 파형 창이 떠서 바로 확인 가능

**GUI 종료 방법**

- MSYS2에서 `Ctrl+C` 누르지 말고  
- 먼저 xsim / Vivado GUI 창 오른쪽 위 `X` 눌러서 종료  
- 그 다음 MSYS2 프롬프트 돌아오면 다음 명령 진행

---

## 3. ModelSim / Questa 시뮬레이션 (선택)

ModelSim이 설치돼 있고, `VSIM` 경로 설정이 된 상태라고 가정.

기본 실행:

```bash
$ cd /c/Users/54/Auto_verilog
$ make msim EX=gate
```

- `run.do` 내부에서:
  - `vlog`, `vsim`, `add wave *`, `run ...` 같은 동작

GUI 직접 실행 예 (도움말 느낌):

```bash
$ vsim -do "set RTL {gate/*.v}; set TB gate/tb_gates.v; set TOP tb_gates; do run.do"
```

---

## 4. Vivado 합성 / 구현 / 비트스트림

### 4-1. 합성 (synth)

예: `EX=gate`, Top 모듈 이름이 `gates` 인 경우

```bash
$ cd /c/Users/54/Auto_verilog
$ make synth EX=gate DUT=gates
```

- `synth.tcl` 인자로 전달:
  - `DUT`, `PART`, `RTL`, `XDC`, `OUT`
- 기본 출력 위치:
  - `build/gate/` 안에 DCP, 합성 리포트 등 생성

### 4-2. 구현 + 비트스트림 (bit)

```bash
$ cd /c/Users/54/Auto_verilog
$ make bit EX=gate DUT=gates
```

- `bit.tcl`에서 구현(implement) + 비트스트림까지 진행
- 기본 출력:
  - `build/gate/*.bit`
  - `build/gate/*.ltx`
  - `build/gate/*.dcp`
  - `build/gate/reports/*.rpt`

---

## 5. 결과물 수집 (harvest)

여러 폴더에 흩어져 있는 결과를  
`artifacts/<예제이름>/` 아래로 모으는 용도.

예: `EX=gate` 결과 모으기

```bash
$ cd /c/Users/54/Auto_verilog
$ make harvest EX=gate
```

수집되는 위치

- `ART_DIR = artifacts/gate` 기준
  - `ART_DIR/sim/`  
    - `sim.vcd`, 각종 `*.wdb`
  - `ART_DIR/impl/`  
    - `*.bit`, `*.ltx`, `*.dcp`
  - `ART_DIR/rpt/`  
    - `util_*.rpt`, `timing_*.rpt`, `drc*.rpt`, `reports/*.rpt` 등

확인 예시

```bash
$ ls artifacts
gate/

$ ls artifacts/gate
impl/  rpt/  sim/

$ ls artifacts/gate/sim
sim.vcd  tb_gates_sim.wdb  ...

$ ls artifacts/gate/impl
*.bit  *.ltx  *.dcp ...

$ ls artifacts/gate/rpt
util_*.rpt  timing_*.rpt  drc*.rpt ...
```

---

## 6. 만들어진 .bit 를 보드에 올리기

### 6-1. Vivado GUI 사용

1. Vivado 2022.2 실행  
2. 프로젝트 생성은 생략하고 **Open Hardware Manager**  
3. `Open Target → Auto Connect`  
4. **Program Device…** 선택  
5. `bitstream file` 에서 `build/gate/xxx.bit` 선택  
6. `OK` 눌러서 다운로드  

→ 이미 만들어 둔 bit 파일만 보드에 올리는 동작

---

### 6-2. Tcl 스크립트로 한 번에 다운로드 (선택)

`program.tcl` 예시:

```tcl
set bitfile "build/gate/gates.bit"   ;# 실제 bit 파일 경로로 수정

open_hw
connect_hw_server
open_hw_target

set dev [lindex [get_hw_devices] 0]
current_hw_device $dev

set_property PROGRAM.FILE $bitfile $dev
program_hw_devices $dev

close_hw_target
disconnect_hw_server
close_hw
exit
```

MSYS2에서 실행:

```bash
$ cd /c/Users/54/Auto_verilog
$ vivado -mode batch -nolog -nojournal -notrace     -source program.tcl
```

---

## 7. 전체 사용 예 (요약)

```bash
$ cd /c/Users/54/Auto_verilog

# 시뮬레이션 + 파형(VCD 포함)
$ make xsim EX=gate

# 구현 + 비트스트림 생성
$ make bit EX=gate DUT=gates

# 결과물 수집
$ make harvest EX=gate
```

`artifacts/gate/` 아래에 모인 파일들을  
보고서 / 포트폴리오에 그대로 활용할 수 있음.

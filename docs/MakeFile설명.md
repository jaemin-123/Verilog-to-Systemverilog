Verilog Examples Flow (MSYS2 + Vivado 2022.2)

0. 폴더 위치 & 디렉터리 구조
--------------------------

0-1. 기본 위치

- Vivado 2022.2 설치:
  C:\Xilinx\Vivado\2022.2\bin\vivado.exe

- 이 레포 위치(예시):
  C:\Users\54\Auto_verilog

MSYS2에서는 같은 경로가 이렇게 보인다.

  cd /c/Users/54/Auto_verilog

0-2. 레포 디렉터리 구조

  Auto_verilog/
  ├─ Makefile          # msim/xsim/synth/bit/harvest 공통 Makefile
  ├─ xsim.tcl          # Vivado xsim용 공통 Tcl
  ├─ xsim_run_vcd.tcl  # (있으면 사용, 없으면 xsim.tcl이 자동 생성)
  ├─ synth.tcl         # Vivado 합성 스크립트
  ├─ bit.tcl           # Vivado 구현 + 비트스트림 스크립트
  ├─ run.do            # ModelSim/Questa용 DO 스크립트
  ├─ gate/             # 예제 1 (EX=gate 로 사용)
  │  ├─ gates.v
  │  ├─ tb_gates.v     # tb_*.v 형태의 테스트벤치 (필수)
  │  └─ gates.xdc      # 필요하면 XDC
  ├─ <다른 예제들>     # EX=adder, EX=counter ... 이런 식으로 추가
  └─ artifacts/        # harvest 결과가 쌓이는 곳 (자동 생성)

규칙
- 각 예제 폴더(EX)는 최소 아래 파일을 가진다.
  - *.v      : RTL
  - tb_*.v   : 테스트벤치 (Makefile이 여기서 TOP 이름을 자동 추출)
  - 필요 시 *.xdc, example.mk 등 추가

1. MSYS2에서 Vivado Makefile 사용 시작하기
------------------------------------------

1-1. MSYS2 실행 & 레포로 이동

1) Windows에서 MSYS2 MinGW64 실행
2) 레포 디렉터리로 이동

  cd /c/Users/54/Auto_verilog
  pwd
  ls

- Makefile, xsim.tcl, gate/ 등이 보여야 정상.

1-2. Makefile 도움말 확인

  make help

예상 출력:

  make xsim  EX=gate                      # Vivado xsim 시뮬
  make msim  EX=gate [VSIM=...]          # ModelSim/Questa 시뮬
  make synth EX=gate DUT=gates           # 합성 (Top 모듈명 필요)
  make bit   EX=gate DUT=gates           # 배치/라우트/비트스트림
  옵션: PART=...  XDC=...  OUT=...

2. Vivado xsim 시뮬레이션 (VCD 자동 생성)
-----------------------------------------

2-1. 배치 모드(콘솔) + VCD 파일

예: gate 예제를 시뮬레이션

  cd /c/Users/54/Auto_verilog
  make xsim EX=gate

동작:
- gate/*.v + gate/tb_gates.v 를 이용해
  - xvlog → xelab → xsim 순서로 실행
- xsim_run_vcd.tcl 에 따라:
  - log_wave -recursive *
  - open_vcd sim.vcd
  - log_vcd *
  - run 1 us        (필요시 run 시간 변경 가능)
  - close_vcd
- 현재 디렉터리에 sim.vcd 와 tb_gates_sim.wdb 생성

VCD는 원하면 GTKWave 등으로 바로 볼 수 있다.

  gtkwave sim.vcd    # 설치해둔 경우

2-2. GUI 모드로 파형 보기

같은 예제를 GUI로 돌리고 싶으면:

  cd /c/Users/54/Auto_verilog
  make xsim_gui EX=gate

동작:
- 내부적으로 make xsim EX=gate XSIM_OPTS=--gui 실행
- xsim.tcl 이 XSIM_GUI=1 환경 변수 설정 후
  xsim tb_gates_sim -gui -tclbatch xsim_run_vcd.tcl 실행
- 1us 동안 시뮬레이션하면서:
  - GUI 파형(wdb) 기록
  - sim.vcd 생성
- xsim 파형 창이 뜨고, 파형을 바로 확인 가능

※ GUI 종료할 때:
- MSYS2에서 Ctrl+C 누르지 말고
- xsim/Vivado 창 우측 상단 X 버튼으로 먼저 닫은 뒤,
- MSYS2 프롬프트가 돌아오면 다음 명령을 입력.

3. ModelSim / Questa 시뮬레이션 (선택)
--------------------------------------

ModelSim이 설치되어 있고 VSIM 경로를 맞춰두었다고 가정.

  make msim EX=gate

- run.do 안에서 vlog, vsim, add wave *, run ... 등을 수행

GUI로 보고 싶으면 직접 vsim 에서 -c 를 빼고 실행:

  vsim -do "set RTL {gate/*.v}; set TB gate/tb_gates.v; set TOP tb_gates; do run.do"

4. Vivado 합성 / 구현 / 비트스트림 생성
----------------------------------------

4-1. 합성 (synth)

예: gate 예제, Top 모듈명이 gates 인 경우:

  cd /c/Users/54/Auto_verilog
  make synth EX=gate DUT=gates

- synth.tcl 이 DUT, PART, RTL, XDC, OUT 인자를 받아 합성 실행
- 결과:
  - 기본적으로 build/gate/ 아래에 DCP, 리포트 등이 생성

4-2. 구현 + 비트스트림 생성 (bit)

  cd /c/Users/54/Auto_verilog
  make bit EX=gate DUT=gates

- bit.tcl 이 구현(implement) + 비트스트림까지 실행
- 결과:
  - build/gate/*.bit
  - build/gate/*.ltx
  - build/gate/*.dcp
  - build/gate/reports/*.rpt 등 생성

5. 결과물 수집 (harvest)
------------------------

여러 폴더에 흩어져 있는 결과들을
artifacts/<예제이름>/ 아래로 모으는 용도.

  cd /c/Users/54/Auto_verilog
  make harvest EX=gate

동작:
- ART_DIR = artifacts/gate 기준으로
  - ART_DIR/sim/  : sim.vcd, *.wdb
  - ART_DIR/impl/ : *.bit, *.ltx, *.dcp
  - ART_DIR/rpt/  : util_*.rpt, timing_*.rpt, drc*.rpt, reports/*.rpt 등
- 폴더가 없으면 mkdir -p 로 자동 생성

확인:

  ls artifacts
  ls artifacts/gate
  ls artifacts/gate/sim
  ls artifacts/gate/impl
  ls artifacts/gate/rpt

6. 이미 만들어진 .bit 를 보드에 올리기 (선택)
-----------------------------------------------

6-1. Vivado GUI에서 올리기

1) Vivado 2022.2 실행
2) 프로젝트 생성 없이 Open Hardware Manager
3) Open Target → Auto Connect
4) Program Device… 클릭
5) bitstream file 에서 build/gate/xxx.bit 선택
6) OK

→ 이미 만들어 둔 bit 파일만 보드에 다운로드, 다시 합성/구현할 필요 없음.

6-2. Tcl로 한번에 올리는 스크립트 예시

program.tcl (예시):

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

MSYS2에서:

  vivado -mode batch -nolog -nojournal -notrace     -source program.tcl

요약 루틴 예시
--------------

  cd /c/Users/54/Auto_verilog

  # 시뮬 + 파형(VCD 포함)
  make xsim EX=gate

  # 합성 + 구현 + 비트스트림
  make bit EX=gate DUT=gates

  # 결과 모으기
  make harvest EX=gate

이 흐름으로 Verilog 예제를 정리하고, artifacts/gate/ 아래를
보고서/포트폴리오에 그대로 사용할 수 있다.

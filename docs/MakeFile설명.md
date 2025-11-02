# 수정해야함
# 스크립트 설명

이 문서는 **상위=Makefile**, **하위=도구 스크립트(do/Tcl)** 구조로
시뮬레이션(xsim/ModelSim)과 합성/비트스트림(Vivado)을 **한 줄 명령**으로 재현하는 템플릿입니다.

---

## 1) 루트 Makefile (상위, 한 줄 실행)

> 위치: **/Makefile**

```make
# ===== Orchestrator (root Makefile) =====
VIV ?= vivado
VSIM?= vsim

# 기본 타깃: 도움말
.PHONY: help
help:
	@echo "make sim-xsim        - Vivado xsim 시뮬(비프로젝트)"
	@echo "make sim-msim        - ModelSim 시뮬(비프로젝트)"
	@echo "make synth           - Vivado 합성(Post-Synth 리포트)"
	@echo "make bit             - Vivado 배치/라우트/비트스트림"
	@echo "make clean           - 생성물 삭제"

# ---- Simulation ----
.PHONY: sim-xsim sim-msim
sim-xsim:
	$(VIV) -mode tcl   -source flows/vivado/xsim.tcl

sim-msim:
	$(VSIM) -c -do flows/modelsim/run.do

# ---- Synthesis & Bitstream ----
.PHONY: synth bit
synth:
	$(VIV) -mode batch -source flows/vivado/synth.tcl

bit:
	$(VIV) -mode batch -source flows/vivado/bit.tcl

# ---- Clean (로그/캐시 일괄 제거) ----
.PHONY: clean
clean:
	-rm -rf work transcript vsim.wlf *.wlf *.ucdb
	-rm -rf xsim.dir .Xil *.jou *.log *.wdb *.pb *.str *.backup.*
	-rm -rf build
```

> Vivado/ModelSim이 PATH에 없으면, 환경변수로 경로를 넘길 수 있습니다.
> ```bash
> make sim-xsim VIV="C:/Xilinx/Vivado/2022.2/bin/vivado"
> make sim-msim VSIM="C:/altera/13.0sp1/modelsim_ase/win32aloem/vsim.exe"
> ```

---

## 2) 하위 스크립트 (도구 전용)

### 2.1 ModelSim run.do
> 위치: **flows/modelsim/run.do**

```tcl
vdel -all
vlib work
vlog +acc examples/01.gates/gates.v examples/01.gates/tb_gates.v
vsim tb_gates
add wave -r /*
run -all
quit
```

> 다른 예제를 돌리고 싶으면 소스 경로만 바꾸면 됩니다.
> (또는 run.do 안에서 변수로 경로를 받아도 됩니다.)

---

### 2.2 Vivado xsim (시뮬) – xsim.tcl
> 위치: **flows/vivado/xsim.tcl**

```tcl
# Vivado xsim non-project simulation
set src_rtl [file normalize "examples/01.gates/gates.v"]
set src_tb  [file normalize "examples/01.gates/tb_gates.v"]
set top_tb  "tb_gates"

xvlog $src_rtl $src_tb
xelab $top_tb -s ${top_tb}_sim --debug typical
xsim  ${top_tb}_sim -runall
```

> GUI로 파형 보려면 마지막 줄을 `-gui -onfinish stop` 으로 바꿔서 실행해도 됩니다.

---

### 2.3 Vivado 합성 – synth.tcl
> 위치: **flows/vivado/synth.tcl**

```tcl
file mkdir build

# 디자인 읽기 (필요에 따라 경로 수정)
read_verilog examples/01.gates/gates.v
# 핀 제약이 있다면:
if {[file exists "examples/01.gates/xdc/gates.xdc"]} {
  read_xdc examples/01.gates/xdc/gates.xdc
}

# 디바이스 파트 (Basys3)
set_part xc7a35tcpg236-1

# 합성
synth_design -top gates
write_checkpoint -force build/post_synth.dcp

# 리포트
report_utilization    -file build/util_synth.rpt
report_timing_summary -file build/timing_synth.rpt

exit
```

---

### 2.4 Vivado 배치/라우트/비트스트림 – bit.tcl
> 위치: **flows/vivado/bit.tcl**

```tcl
file mkdir build

# 소스/제약
read_verilog examples/01.gates/gates.v
if {[file exists "examples/01.gates/xdc/gates.xdc"]} {
  read_xdc examples/01.gates/xdc/gates.xdc
}

# 디바이스 파트
set_part xc7a35tcpg236-1

# 합성 → 배치 → 라우트 → 비트스트림
synth_design -top gates
opt_design
place_design
route_design

write_bitstream -force build/gates.bit
report_timing_summary -file build/timing_impl.rpt

exit
```

---

## 3) 사용 예 (루트에서 한 줄)

```bash
# 시뮬레이션
make sim-xsim            # Vivado xsim
make sim-msim            # ModelSim

# 합성/비트
make synth               # Post-Synth 리포트 생성
make bit                 # gates.bit 생성

# 정리
make clean
```

---

## 4) 예제 바꿔 돌리기

- 한 레포에 여러 예제가 있을 때는 **flows 스크립트의 소스 경로**만 바꾸거나,
- `examples/<name>/scripts/`에 예제 전용 xsim.tcl/run.do를 둔 뒤,
  상위 Makefile에서 타깃을 분기할 수도 있습니다.

예)

```make
sim-gates:
	$(VIV) -mode tcl -source flows/vivado/xsim.tcl

sim-adder:
	$(VIV) -mode tcl -source examples/02.full_adder/scripts/xsim.tcl
```

---

## 5) 폴더 이름 추천

- 전역 도구 스크립트: **`flows/vivado`**, **`flows/modelsim`**
- 보드 정의/제약: **`boards/`** (보드별 XDC, 노트)
- 예제별 소스: **`examples/<index>.<name>/`**
- 빌드 산출물: **`build/`** (Make clean으로 삭제)

> 이미 레포에 `flows/`가 있으니 **그 안에 vivado/ modelsim 폴더를 만들고** 이 문서의 스크립트들을 넣는 방식을 권장합니다.

---

## 6) 팁 (실무 감각)

- GUI는 디버깅용, 정식 실행은 **배치/로그/리포트 자동 산출**.
- xsim 파형은 `xelab --debug typical` 필수.
- ModelSim은 `vlog +acc`, `add wave -r /*` 습관화.
- CI가 가능하면 iverilog/verilator로 문법·연결 스모크 테스트 추가.

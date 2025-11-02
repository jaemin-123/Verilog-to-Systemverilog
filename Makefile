# ==== Tools (경로가 PATH에 없으면 실행 시 VIV=..., VSIM=... 로 지정) ====
VIV  ?= vivado
VSIM ?= vsim

# ==== Example 폴더 지정 (필수) ====
EX   ?=          # 예: EX=gate  또는 EX=examples/01.gates
# EX가 꼭 필요한 타깃들만 골라서 검사
NEED_EX := $(filter msim xsim synth bit,$(MAKECMDGOALS))
ifneq ($(NEED_EX),)
  ifeq ($(strip $(EX)),)
    $(error Set EX=<example_dir>  e.g., EX=gate)
  endif
endif

# ==== 자동 추론 ====
RTL  ?= $(EX)/*.v
TB   ?= $(firstword $(wildcard $(EX)/tb_*.v))
TOP  ?= $(notdir $(basename $(TB)))      # tb_gates.v -> tb_gates
XDC  ?= $(EX)/*.xdc
PART ?= xc7a35tcpg236-1
OUT  ?= build/$(notdir $(EX))
DUT  ?=                                     # 합성/비트 시 Top 모듈명(예: gates)

# 선택: 각 예제 폴더의 example.mk 로 오버라이드(DUT, PART 등)
-include $(EX)/example.mk

# ==== Tcl/DO 스크립트 절대경로 ====
XSIM_TCL := $(CURDIR)/xsim.tcl
SYN_TCL  := $(CURDIR)/synth.tcl
BIT_TCL  := $(CURDIR)/bit.tcl
RUN_DO   := $(CURDIR)/run.do

.PHONY: help msim xsim synth bit clean

help:
	@echo "make xsim  EX=gate                      # Vivado xsim 시뮬"
	@echo "make msim  EX=gate [VSIM=...]          # ModelSim/Questa 시뮬"
	@echo "make synth EX=gate DUT=gates           # 합성 (Top 모듈명 필요)"
	@echo "make bit   EX=gate DUT=gates           # 배치/라우트/비트스트림"
	@echo "옵션: PART=$(PART)  XDC=$(XDC)  OUT=$(OUT)"

# -------- ModelSim / Questa --------
msim:
	@test -n "$(TB)" || (echo "ERROR: Testbench not found: $(EX)/tb_*.v"; exit 1)
	@echo "[MSIM] EX=$(EX)  TB=$(TB)  TOP=$(TOP)"
	$(VSIM) -c -do "set RTL {$(RTL)}; set TB $(TB); set TOP $(TOP); do $(RUN_DO)"

# -------- Vivado xsim (simulation) --------
xsim:
	@test -n "$(TB)" || (echo "ERROR: Testbench not found: $(EX)/tb_*.v"; exit 1)
	@echo "[XSIM] EX=$(EX)  TB=$(TB)  TOP=$(TOP)"
	$(VIV) -mode tcl -nolog -nojournal -notrace \
	  -source "$(XSIM_TCL)" -tclargs "$(RTL)" "$(TB)" $(TOP)

# -------- Vivado synthesis --------
synth:
	@test -n "$(DUT)" || (echo "ERROR: set DUT=<top_module> (e.g., DUT=gates)"; exit 1)
	@echo "[SYNTH] EX=$(EX)  DUT=$(DUT)  PART=$(PART)"
	$(VIV) -mode batch -nolog -nojournal -notrace \
	  -source "$(SYN_TCL)" -tclargs $(DUT) $(PART) "$(RTL)" "$(XDC)" "$(OUT)"

# -------- Vivado implement + bitstream --------
bit:
	@test -n "$(DUT)" || (echo "ERROR: set DUT=<top_module> (e.g., DUT=gates)"; exit 1)
	@echo "[BIT] EX=$(EX)  DUT=$(DUT)  PART=$(PART)"
	$(VIV) -mode batch -nolog -nojournal -notrace \
	  -source "$(BIT_TCL)" -tclargs $(DUT) $(PART) "$(RTL)" "$(XDC)" "$(OUT)"

clean:
	-@rm -rf build *.log *.jou *.pb xsim.dir .Xil .xil work transcript vsim.wlf *.wlf

.PHONY: harvest
ART ?= artifacts/$(notdir $(EX))

.PHONY: harvest
ART ?= artifacts/$(notdir $(EX))

harvest:
	@mkdir -p "$(ART)/sim" "$(ART)/rpt" "$(ART)/impl"
	@echo "[HARVEST] EX=$(EX)  OUT=$(OUT)  TOP=$(TOP)"

	# --- 시뮬 파형 ---
	-@[ -f "$(TOP)_sim.wdb" ] && cp -f "$(TOP)_sim.wdb" "$(ART)/sim/" || true
	-@[ -f "sim.vcd" ]        && cp -f "sim.vcd"        "$(ART)/sim/" || true
	-@find . -maxdepth 2 -name "*.wdb" -exec cp -f {} "$(ART)/sim/" \; 2>/dev/null || true

	# --- 검색 루트 결정 ---
	@if [ -n "$(OUT)" ] && [ -d "$(OUT)" ]; then \
	    SRCH="$(OUT)"; \
	else \
	    SRCH="build"; \
	fi; \
	\
	# --- 비트스트림/ILA/체크포인트 ---
	find $$SRCH -name "*.bit" -exec cp -f {} "$(ART)/impl/" \; 2>/dev/null || true; \
	find $$SRCH -name "*.ltx" -exec cp -f {} "$(ART)/impl/" \; 2>/dev/null || true; \
	find $$SRCH -name "*.dcp" -exec cp -f {} "$(ART)/impl/" \; 2>/dev/null || true; \
	\
	# --- 리포트(합성/구현 모두) ---
	find $$SRCH -name "util_*.rpt"      -exec cp -f {} "$(ART)/rpt/" \; 2>/dev/null || true; \
	find $$SRCH -name "timing_*.rpt"    -exec cp -f {} "$(ART)/rpt/" \; 2>/dev/null || true; \
	find $$SRCH -name "drc*.rpt"        -exec cp -f {} "$(ART)/rpt/" \; 2>/dev/null || true; \
	# 혹시 폴더명이 reports로 떨어지는 경우까지 커버
	if [ -d "$$SRCH/reports" ]; then cp -f $$SRCH/reports/*.rpt "$(ART)/rpt/" 2>/dev/null || true; fi; \
	echo "Saved → $(ART)"

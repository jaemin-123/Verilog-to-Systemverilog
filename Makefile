# ==== Tools (경로가 PATH에 없으면 호출 시 VIV=..., VSIM=... 로 덮어쓰기) ====
VIV  ?= vivado
VSIM ?= vsim

# ==== Project auto-discovery ====
# 예제 폴더(ex: EX=examples/01.gates)
EX   ?= examples/01.gates

# 기본 파일 자동 추론
RTL  ?= $(EX)/*.v
TB   ?= $(firstword $(wildcard $(EX)/tb_*.v))
TOP  ?= $(notdir $(basename $(TB)))     # tb_gates.v -> tb_gates
XDC  ?= $(EX)/xdc/*.xdc
PART ?= xc7a35tcpg236-1
OUT  ?= build/$(notdir $(EX))

# 합성/비트용 DUT(Top DUT 모듈명) — 필요 시 커맨드에서 지정하거나 example.mk로 지정
DUT  ?=

# 각 예제 폴더에 선택적으로 example.mk를 두면 여기로 흡수됨 (DUT, PART 등 오버라이드)
-include $(EX)/example.mk

.PHONY: help msim xsim synth bit clean

help:
	@echo "make xsim  EX=examples/01.gates                   # Vivado xsim으로 TB 시뮬"
	@echo "make msim  EX=examples/01.gates [VSIM=...]       # ModelSim/Questa 시뮬"
	@echo "make synth EX=examples/01.gates DUT=gates        # 합성 (DUT=Top 모듈명)"
	@echo "make bit   EX=examples/01.gates DUT=gates        # 배치/라우트/비트스트림"
	@echo ""
	@echo "옵션: PART=$(PART)  XDC=$(XDC)  OUT=$(OUT)"
	@echo "도구 경로: VIV=$(VIV)  VSIM=$(VSIM)"

# -------- ModelSim/Questa --------
msim:
	@echo "[MSIM] EX=$(EX)  TB=$(TB)  TOP=$(TOP)"
	$(VSIM) -c -do "set RTL {$(RTL)}; set TB $(TB); set TOP $(TOP); do flows/modelsim/run.do"

# -------- Vivado xsim (simulation) --------
xsim:
	@echo "[XSIM] EX=$(EX)  TB=$(TB)  TOP=$(TOP)"
	$(VIV) -mode tcl -source flows/vivado/xsim.tcl -tclargs "$(RTL)" "$(TB)" $(TOP)

# -------- Vivado synthesis --------
synth:
	@test -n "$(DUT)" || (echo "ERROR: set DUT=<top_module> (e.g., DUT=gates)"; exit 1)
	@echo "[SYNTH] EX=$(EX)  DUT=$(DUT)  PART=$(PART)"
	$(VIV) -mode batch -source flows/vivado/synth.tcl -tclargs $(DUT) $(PART) "$(RTL)" "$(XDC)" "$(OUT)"

# -------- Vivado implement + bitstream --------
bit:
	@test -n "$(DUT)" || (echo "ERROR: set DUT=<top_module> (e.g., DUT=gates)"; exit 1)
	@echo "[BIT] EX=$(EX)  DUT=$(DUT)  PART=$(PART)"
	$(VIV) -mode batch -source flows/vivado/bit.tcl -tclargs $(DUT) $(PART) "$(RTL)" "$(XDC)" "$(OUT)"

clean:
	-@rm -rf build *.log *.jou xsim.dir .Xil .xil work transcript vsim.wlf *.wdb *.wlf

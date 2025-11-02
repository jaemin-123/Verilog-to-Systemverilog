# ===== Config =====
TOP   ?= tb_gates  # top모듈 이름
SRCS  ?= gates.v tb_gates.v # TB 할 파일이름

# 툴(경로가 PATH에 잡혀 있지 않다면 절대경로로 바꿔도 됨)
VSIM  ?= vsim
VLOG  ?= vlog
VLIB  ?= vlib
VDEL  ?= vdel
XVLOG ?= xvlog
XELAB ?= xelab
XSIM  ?= xsim

.PHONY: help sim-msim gui-msim sim-xsim gui-xsim clean

help:
	@echo "make sim-msim  : ModelSim/Questa 콘솔 실행"
	@echo "make gui-msim  : ModelSim/Questa GUI 실행"
	@echo "make sim-xsim  : Vivado xsim 콘솔 실행"
	@echo "make gui-xsim  : Vivado xsim GUI 실행"
	@echo "make clean     : 생성물 삭제"

# ----- ModelSim/Questa -----
sim-msim: $(SRCS)
	-$(VDEL) -all
	$(VLIB) work
	$(VLOG) +acc $(SRCS)
	$(VSIM) -c $(TOP) -do "run -all; stop"

gui-msim: $(SRCS)
	-$(VDEL) -all
	$(VLIB) work
	$(VLOG) +acc $(SRCS)
	$(VSIM) $(TOP) -do "add wave -r /*; run -all"

# ----- Vivado xsim -----
XELAB_DBG ?= --debug typical

sim-xsim: $(SRCS)
	$(XVLOG) $(SRCS)
	$(XELAB) $(TOP) -s $(TOP)_sim $(XELAB_DBG)
	$(XSIM)  $(TOP)_sim -runall

gui-xsim: $(SRCS)
	$(XVLOG) $(SRCS)
	$(XELAB) $(TOP) -s $(TOP)_sim $(XELAB_DBG)
	$(XSIM)  $(TOP)_sim -gui -onfinish stop

clean:
	-$(VDEL) -all
	-rm -rf work transcript vsim.wlf *.wlf *.vcd *.fst
	-rm -rf xsim.dir *.pb *.jou *.log *.wdb *.str *.ucdb

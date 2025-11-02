# Clean & compile & run (ModelSim/Questa)
vdel -all
vlib work
# 예제 경로: examples/01.gates
vlog +acc examples/01.gates/gates.v examples/01.gates/tb_gates.v
vsim tb_gates
add wave -r /*
run -all
quit

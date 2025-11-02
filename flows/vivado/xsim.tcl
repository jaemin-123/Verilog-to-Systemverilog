# Vivado xsim (non-project)
set src_rtl [file normalize "examples/01.gates/gates.v"]
set src_tb  [file normalize "examples/01.gates/tb_gates.v"]
set top_tb  "tb_gates"

xvlog $src_rtl $src_tb
xelab $top_tb -s ${top_tb}_sim --debug typical
# GUI 원하면 -gui -onfinish stop
xsim  ${top_tb}_sim -runall

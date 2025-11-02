file mkdir build
read_verilog examples/01.gates/gates.v
if {[file exists "examples/01.gates/xdc/gates.xdc"]} {
  read_xdc examples/01.gates/xdc/gates.xdc
}
set_part xc7a35tcpg236-1
synth_design -top gates
write_checkpoint -force build/post_synth.dcp
report_utilization    -file build/util_synth.rpt
report_timing_summary -file build/timing_synth.rpt
exit

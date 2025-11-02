# ================================
# Vivado one-shot TCL for "gates"
# ================================

# ---- Settings (필요시 변경) ----
set project_name "gates"
set project_dir  "C:/Users/54/${project_name}"
set bd_name      "gates"
set part_name    "xc7a35tcpg236-1"
set board_part   "digilentinc.com:Basys3:part0:1.2"

# ---- Create folders ----
file mkdir $project_dir
file mkdir "$project_dir/src"
file mkdir "$project_dir/tb"
file mkdir "$project_dir/xdc"
file mkdir "$project_dir/scripts"
set gates_v     "$project_dir/src/gates.v"
set tb_v        "$project_dir/tb/tb_gates.v"
set xdc_file    "$project_dir/xdc/basys3_gates.xdc"

# ---- Write RTL: gates.v ----
set fh [open $gates_v "w"]
puts $fh {module gates (iA, iB, oAND, oOR, oNOT, oNAND, oNAND2);
  input iA, iB;
  output oAND, oOR, oNOT, oNAND, oNAND2;

  wire s0;
  and U0 (oAND, iA, iB);
  or  U1 (oOR,  iA, iB);
  not U2 (oNOT, iA);
  nand U3 (oNAND, iA, iB);
  and U4 (s0, iA, iB);
  not U5 (oNAND2, s0);
endmodule}
close $fh

# ---- Write TB: tb_gates.v ----
set fh [open $tb_v "w"]
puts $fh {`timescale 1ns/1ps

module tb_gates;
  reg iA, iB;
  wire oAND, oOR, oNOT, oNAND, oNAND2;

  // 이름에 의한 포트 맵핑 사용하여 gates를 인스턴스화
  gates U0 (
    .iA (iA),     // 입력신호 iA
    .iB (iB),     // 입력신호 iB
    .oAND (oAND), // 출력신호 oAND
    .oOR (oOR),   // 출력신호 oOR
    .oNOT (oNOT), // 출력신호 oNOT
    .oNAND (oNAND),   // 출력신호 oNAND
    .oNAND2 (oNAND2)  // 출력신호 oNAND2
  );

  // 입력신호 생성
  initial begin
    iA = 0; iB = 0; #100;
    iA = 0; iB = 1; #100;
    iA = 1; iB = 0; #100;
    iA = 1; iB = 1; #100;
    $stop;
  end
endmodule}
close $fh

# ---- Write XDC ----
set fh [open $xdc_file "w"]
puts $fh {## Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {iA}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {iB}]

## LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {oAND}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {oOR}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {oNOT}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports {oNAND}]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports {oNAND2}]}
close $fh

# ---- Create Project ----
# 보드 파일이 설치되어 있으면 -board_part로, 없으면 -part로 생성
set use_board 1
if {[catch {create_project $project_name $project_dir -force -part $part_name}]} {
  puts "ERROR: 프로젝트 생성 실패(Part)."
  exit 1
}

# 보드 파트 설정 시도 (보드 파일 미설치면 경고만 출력)
if {[catch {set_property board_part $board_part [current_project]} msg]} {
  puts "WARN: board_part 설정 실패(보드 파일 미설치 가능): $msg"
  set use_board 0
} else {
  puts "INFO: board_part 설정 완료: $board_part"
}

# 기본 설정
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

# ---- Add sources / constraints ----
add_files -fileset sources_1 $gates_v
read_xdc $xdc_file
update_compile_order -fileset sources_1

# ---- Set Top (synthesis) ----
set_property top gates [get_filesets sources_1]

# ---- Sim fileset 구성 ----
# Vivado 는 기본 sim_1 fileset을 가짐. TB를 sim_1에 추가하고 TB top을 지정.
add_files -fileset sim_1 $tb_v
set_property top tb_gates [get_filesets sim_1]
update_compile_order -fileset sim_1

# ---- Run Synthesis / Implementation / Bitstream ----
launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# ---- Reports ----
set rpt_dir "$project_dir/reports"
file mkdir $rpt_dir
report_timing_summary    -file "$rpt_dir/timing_summary.rpt"
report_utilization       -file "$rpt_dir/utilization.rpt"
report_drc               -file "$rpt_dir/drc.rpt" -ruledecks {default}

# ---- Finish ----
puts "=============================================="
puts "DONE: Project=$project_name"
puts "BITSTREAM: [get_property PROGRESS [current_run]]"
puts "Project Dir: $project_dir"
puts "Sources: $gates_v  /  $tb_v"
puts "XDC    : $xdc_file"
puts "=============================================="

# ================================
# Vivado one-shot TCL for "full_adder"
# ================================

# ---- Settings (필요시 변경) ----
set project_name "full_adder"
set project_dir  "C:/Users/54/${project_name}"
set bd_name      "full_adder"
set part_name    "xc7a35tcpg236-1"
set board_part   "digilentinc.com:Basys3:part0:1.2"

# ---- Create folders ----
file mkdir $project_dir
file mkdir "$project_dir/src"
file mkdir "$project_dir/tb"
file mkdir "$project_dir/xdc"
file mkdir "$project_dir/scripts"

set full_adder_v "$project_dir/src/full_adder.v"
set tb_v         "$project_dir/tb/tb_full_adder.v"
set xdc_file     "$project_dir/xdc/basys3_full_adder.xdc"

# ---- Write RTL: full_adder.v ----
set fh [open $full_adder_v "w"]
puts $fh {module full_adder (iX, iY, iCIN, oSUM, oCARRY);
    input  iX, iY, iCIN;
    output oSUM, oCARRY;

    reg s0, c0, c1;
    reg sum, carry;

    assign oSUM   = sum;
    assign oCARRY = carry;

    always @* begin
        s0   = iX ^ iY;
        c0   = iX & iY;
        c1   = s0 & iCIN;
        sum  = s0 ^ iCIN;
        carry= c0 | c1;
    end
endmodule}
close $fh

# ---- Write TB: tb_full_adder.v ----
set fh [open $tb_v "w"]
puts $fh {`timescale 1ns/1ps
module tb_full_adder;
    reg iX, iY, iCIN;
    wire oSUM, oCARRY;

    full_adder UFA(
        .iX(iX), .iY(iY), .iCIN(iCIN),
        .oSUM(oSUM), .oCARRY(oCARRY)
    );

    initial begin
        iX=0; iY=0; iCIN=0; #100;
        iX=1; iY=0; iCIN=0; #100;
        iX=0; iY=1; iCIN=0; #100;
        iX=1; iY=1; iCIN=0; #100;
        iX=0; iY=0; iCIN=1; #100;
        iX=1; iY=0; iCIN=1; #100;
        iX=0; iY=1; iCIN=1; #100;
        iX=1; iY=1; iCIN=1; #100;
        $stop;
    end
endmodule}
close $fh

# ---- Write XDC ----
set fh [open $xdc_file "w"]
puts $fh {## Switches
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {iX}]
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {iY}]
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports {iCIN}]

## LEDs
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {oSUM}]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {oCARRY}]}
close $fh

# ---- Create Project ----
if {[catch {create_project $project_name $project_dir -force -part $part_name}]} {
  puts "ERROR: 프로젝트 생성 실패(Part)."
  exit 1
}

# 보드 파트 설정 시도 (보드 파일 미설치면 경고만 출력)
if {[catch {set_property board_part $board_part [current_project]} msg]} {
  puts "WARN: board_part 설정 실패(보드 파일 미설치 가능): $msg"
} else {
  puts "INFO: board_part 설정 완료: $board_part"
}

# 기본 설정
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

# ---- Add sources / constraints ----
add_files -fileset sources_1 $full_adder_v
read_xdc $xdc_file
update_compile_order -fileset sources_1

# ---- Set Top (synthesis) ----
set_property top full_adder [get_filesets sources_1]

# ---- Sim fileset 구성 ----
add_files -fileset sim_1 $tb_v
set_property top tb_full_adder [get_filesets sim_1]
update_compile_order -fileset sim_1

# ---- Run Synthesis / Implementation / Bitstream ----
launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# ---- Reports ----
set rpt_dir "$project_dir/reports"
file mkdir $rpt_dir
report_timing_summary -file "$rpt_dir/timing_summary.rpt"
report_utilization    -file "$rpt_dir/utilization.rpt"
report_drc            -file "$rpt_dir/drc.rpt" -ruledecks {default}

# ---- Finish ----
puts "=============================================="
puts "DONE: Project=$project_name"
puts "BITSTREAM: [get_property PROGRESS [current_run]]"
puts "Project Dir: $project_dir"
puts "Sources: $full_adder_v  /  $tb_v"
puts "XDC    : $xdc_file"
puts "=============================================="

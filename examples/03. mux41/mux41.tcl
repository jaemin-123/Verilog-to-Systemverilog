# ================================
# Vivado one-shot TCL for "mux41"
# ================================

# ---- Settings (필요시 변경) ----
set project_name "mux41"
set project_dir  "C:/Users/54/${project_name}"
set bd_name      "mux41"
set part_name    "xc7a35tcpg236-1"
set board_part   "digilentinc.com:Basys3:part0:1.2"

# ---- Create folders ----
file mkdir $project_dir
file mkdir "$project_dir/src"
file mkdir "$project_dir/tb"
file mkdir "$project_dir/xdc"
file mkdir "$project_dir/scripts"

set mux41_v "$project_dir/src/mux41.v"
set tb_v         "$project_dir/tb/tb_mux41.v"
set xdc_file     "$project_dir/xdc/basys3_mux41.xdc"

# ---- Write RTL: mux41.v ----
set fh [open $mux41_v "w"]
puts $fh {module mux41a(iA, iB, iC, iD, iSEL, oOUT);
    input [7:0] iA, iB, iC, iD;
    input [1:0] iSEL;
    output [7:0] oOUT;
    
    assign oOUT = (iSEL == 0) ? iA:
                (iSEL == 1) ? iB:
                (iSEL == 2) ? iC : iD;
endmodule

module mux41(
  input  wire [1:0] iSEL_sw, // SW1:MSB, SW0:LSB
  input  wire BTN_A,         // -> iA[0]
  input  wire BTN_B,         // -> iB[0]
  input  wire BTN_C,         // -> iC[0]
  input  wire BTN_D,         // -> iD[0]
  output wire LED0           // oOUT[0]만 표시
);
  // 8비트 입력을 최소화: 상위 7비트는 0, LSB는 버튼
  wire [7:0] iA = {7'b0, BTN_A};
  wire [7:0] iB = {7'b0, BTN_B};
  wire [7:0] iC = {7'b0, BTN_C};
  wire [7:0] iD = {7'b0, BTN_D};

  wire [7:0] oOUT;

  mux41a U0(
    .iA(iA), 
    .iB(iB), 
    .iC(iC), 
    .iD(iD),
    .iSEL(iSEL_sw),
    .oOUT(oOUT)
  );

  assign LED0 = oOUT[0]; // LSB만 LED로 확인
endmodule}
close $fh

# ---- Write TB: tb_mux41.v ----
set fh [open $tb_v "w"]
puts $fh {`timescale 1ns/10ps

module tb_mux41;
    reg [7:0] iA, iB, iC, iD;
    reg [1:0] iSEL;
    wire [7:0] oOUT;

    mux41a U0(
        .iA (iA),
        .iB (iB),
        .iC (iC),
        .iD (iD),
        .iSEL (iSEL),
        .oOUT (oOUT));
        
    initial begin
        iA = 8'h00; iB = 8'h01; iC = 8'h02; iD = 8'h03; iSEL = 2'b00; #100;
        iA = 8'h00; iB = 8'h01; iC = 8'h02; iD = 8'h03; iSEL = 2'b01; #100;
        iA = 8'h00; iB = 8'h01; iC = 8'h02; iD = 8'h03; iSEL = 2'b10; #100;
        iA = 8'h00; iB = 8'h01; iC = 8'h02; iD = 8'h03; iSEL = 2'b11; #100;
    end
endmodule}
close $fh

# ---- Write XDC ----
set fh [open $xdc_file "w"]
puts $fh {##Buttons
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports {BTN_A}] 
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports {BTN_B}] 
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports {BTN_C}] 
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports {BTN_D}] 

## Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {iSEL_sw[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {iSEL_sw[1]}]

## LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {LED0}]}
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
add_files -fileset sources_1 $mux41_v
read_xdc $xdc_file
update_compile_order -fileset sources_1

# ---- Set Top (synthesis) ----
set_property top mux41 [get_filesets sources_1]

# ---- Sim fileset 구성 ----
add_files -fileset sim_1 $tb_v
set_property top tb_mux41 [get_filesets sim_1]
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
puts "Sources: $mux41_v  /  $tb_v"
puts "XDC    : $xdc_file"
puts "=============================================="

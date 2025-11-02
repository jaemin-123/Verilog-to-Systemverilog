# xsim.tcl  (Vivado Tcl에서 배치/인터랙티브 모두 동작)
# Usage (batch):
#   vivado -mode tcl -nolog -nojournal -notrace \
#     -source xsim.tcl -tclargs "<rtl_globs>" "<tb_file>" <top> [--gui]

# --- 인자 파싱 ---
set args $::argv
if {[llength $args] < 3} {
  puts "USAGE: -tclargs \"<rtl_globs>\" \"<tb_file>\" <top> [--gui]"
  exit 1
}
set RTL_GLOBS [lindex $args 0]
set TB_FILE   [lindex $args 1]
set TOP       [lindex $args 2]
set GUI       [expr {[lsearch -exact $args "--gui"] >= 0}]

# --- 글롭 확장 ---
set RTL_LIST {}
foreach g [split $RTL_GLOBS " "] {
  foreach f [glob -nocomplain $g] {
    lappend RTL_LIST [file normalize $f]
  }
}
if {[llength $RTL_LIST] == 0} {
  puts "No RTL matched: $RTL_GLOBS"
  exit 2
}
set TB_FILE [file normalize $TB_FILE]

# --- 컴파일/엘랩/시뮬 (exec로 외부 실행기 호출) ---
set snap "${TOP}_sim"

# xvlog
set cmd1 [list xvlog];  eval lappend cmd1 $RTL_LIST $TB_FILE
puts [join $cmd1 " "]
exec {*}$cmd1

# xelab
set cmd2 [list xelab $TOP -s $snap --debug typical]
puts [join $cmd2 " "]
exec {*}$cmd2

# xsim
if {$GUI} {
  set cmd3 [list xsim $snap -gui -onfinish stop]
} else {
  set cmd3 [list xsim $snap -runall]
}
puts [join $cmd3 " "]
exec {*}$cmd3

# =========================================
# Vivado xsim generic (non-project) runner
# Use:
#   vivado -mode tcl -source flows/vivado/xsim.tcl \
#          -tclargs "<rtl_globs>" "<tb_file>" <top_module> [--gui]
# Examples:
#   vivado -mode tcl -source flows/vivado/xsim.tcl \
#          -tclargs "src/*.v" "tb/tb_top.v" tb_top
#   vivado -mode tcl -source flows/vivado/xsim.tcl \
#          -tclargs "src/**/*.v" "tb/tb_top.v" tb_top --gui
# =========================================

set args $::argv
if {[llength $args] < 3} {
  puts "USAGE: -tclargs \"<rtl_globs>\" \"<tb_file>\" <top> [--gui]"
  exit 1
}
set RTL_GLOBS [lindex $args 0]
set TB_FILE   [lindex $args 1]
set TOP       [lindex $args 2]
set GUI       [expr {[lsearch -exact $args "--gui"] >= 0}]

# expand globs to file list
set RTL_LIST {}
foreach g [split $RTL_GLOBS " "] {
  foreach f [glob -nocomplain $g] { lappend RTL_LIST $f }
}

if {[llength $RTL_LIST] == 0} { puts "No RTL matched: $RTL_GLOBS"; exit 1 }

eval xvlog $RTL_LIST $TB_FILE
xelab $TOP -s ${TOP}_sim --debug typical

if {$GUI} {
  xsim ${TOP}_sim -gui -onfinish stop
} else {
  xsim ${TOP}_sim -runall
}

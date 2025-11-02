# =========================================
# Vivado synthesis (project-less) generic
# Use:
#   vivado -mode batch -source flows/vivado/synth.tcl \
#          -tclargs <top> <part> "<rtl_globs>" ["<xdc_globs>"] [outdir]
# Example:
#   vivado -mode batch -source flows/vivado/synth.tcl \
#          -tclargs gates xc7a35tcpg236-1 "src/*.v" "xdc/*.xdc" build
# =========================================

set args $::argv
if {[llength $args] < 3} {
  puts "USAGE: -tclargs <top> <part> \"<rtl_globs>\" [\"<xdc_globs>\"] [outdir]"
  exit 1
}

set TOP       [lindex $args 0]
set PART      [lindex $args 1]
set RTL_GLOBS [lindex $args 2]
set XDC_GLOBS [expr {[llength $args] >= 4 ? [lindex $args 3] : ""}]
set OUTDIR    [expr {[llength $args] >= 5 ? [lindex $args 4] : "build"}]

file mkdir $OUTDIR
set_part $PART

# read RTL
foreach g [split $RTL_GLOBS " "] {
  foreach f [glob -nocomplain $g] { read_verilog $f }
}

# read constraints (optional)
if {$XDC_GLOBS ne ""} {
  foreach g [split $XDC_GLOBS " "] {
    foreach f [glob -nocomplain $g] { read_xdc $f }
  }
}

synth_design -top $TOP
write_checkpoint -force $OUTDIR/post_synth.dcp
report_utilization    -file $OUTDIR/util_synth.rpt
report_timing_summary -file $OUTDIR/timing_synth.rpt
exit

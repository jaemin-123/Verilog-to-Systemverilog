# =========================================
# Vivado implement & bitstream generic
# Use:
#   vivado -mode batch -source flows/vivado/bit.tcl \
#          -tclargs <top> <part> "<rtl_globs>" ["<xdc_globs>"] [outdir]
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

foreach g [split $RTL_GLOBS " "] {
  foreach f [glob -nocomplain $g] { read_verilog $f }
}
if {$XDC_GLOBS ne ""} {
  foreach g [split $XDC_GLOBS " "] {
    foreach f [glob -nocomplain $g] { read_xdc $f }
  }
}

synth_design -top $TOP
opt_design
place_design
route_design

write_bitstream -force $OUTDIR/$TOP.bit
report_timing_summary -file $OUTDIR/timing_impl.rpt
exit

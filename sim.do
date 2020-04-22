if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

vcom -work work -93 -explicit hermes/Hermes_package.vhd
vcom -work work -93 -explicit hermes/router.vhd
vcom -work work -93 -explicit hermes/outbuffer.vhd
vcom -work work -93 -explicit hermes/node.vhd
vcom -work work -93 -explicit testbench.vhd

vsim -t 10ps work.testbench

set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1

if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

sccom -B/usr/bin -g modules/OutputModule.cpp -std=c++11
vcom -work work -93 -explicit hermes/Hermes_package.vhd
vcom -work work -93 -explicit hermes/router.vhd
vcom -work work -93 -explicit hermes/outbuffer.vhd
vcom -work work -93 -explicit hermes/arbiter.vhd
vcom -work work -93 -explicit hermes/node.vhd
vcom -work work -93 -explicit hermes/noc.vhd
vcom -work work -93 -explicit testbench.vhd
sccom -B/usr/bin -link -std=c++11

vsim -t 10ps work.testbench

set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1

if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

sccom -B/usr/bin -g modules/SC_InputModule.cpp
sccom -B/usr/bin -g modules/OutputModule.cpp -std=c++11
sccom -B/usr/bin -g modules/RouterOutputModule.cpp
sccom -B/usr/bin -link

vcom -work work -93 -explicit hermes/constants.vhd
vcom -work work -93 -explicit hermes/standards.vhd
vcom -work work -93 -explicit hermes/router.vhd
vcom -work work -93 -explicit hermes/ringbuffer.vhd
vcom -work work -93 -explicit hermes/arbiter.vhd
vcom -work work -93 -explicit hermes/node.vhd
vcom -work work -93 -explicit hermes/noc.vhd
vcom -work work -93 -explicit testbench.vhd

vsim -t 10ps work.testbench

set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1

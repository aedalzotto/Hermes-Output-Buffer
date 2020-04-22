onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DATA SOURCE}
add wave -noupdate /testbench/ce1
add wave -noupdate /testbench/data1
add wave -noupdate -divider {Router 00 - Local INPUT PORT}
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/tx
add wave -noupdate /testbench/data_out
add wave -noupdate /testbench/credit_i
add wave -noupdate -divider {Router 00 - Local OUTPUT BUFFER}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 256
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {860 ps}

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DATA SOURCE}
add wave -noupdate /testbench/clock
add wave -noupdate /testbench/reset
add wave -noupdate /testbench/ce1
add wave -noupdate /testbench/data1
add wave -noupdate -divider {Node 00 - LOCAL Router}
add wave -noupdate /testbench/node1/L_router/data_in
add wave -noupdate /testbench/node1/rx(4)
add wave -noupdate /testbench/node1/credit_o(4)
add wave -noupdate -divider {Node 00 - L_router LE_buffer}
add wave -noupdate /testbench/node1/data_in(4)
add wave -noupdate /testbench/node1/tx_buffers(4)(0)
add wave -noupdate /testbench/node1/credit_buffers(4)(0)
add wave -noupdate /testbench/node1/data_buffer(0)(4)
add wave -noupdate /testbench/node1/av_buffer(0)(4)
add wave -noupdate /testbench/node1/ack_buffer(0)(4)
add wave -noupdate -divider {Node 00 - E_arbiter}
add wave -noupdate /testbench/node1/data_out(0)
add wave -noupdate /testbench/node1/tx(0)
add wave -noupdate /testbench/node1/credit_i(0)
add wave -noupdate -divider {DATA SINK}
add wave -noupdate /testbench/data_in(0)
add wave -noupdate /testbench/data_ack(0)
add wave -noupdate /testbench/data_av(0)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {484990 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {95820 ps} {1054800 ps}

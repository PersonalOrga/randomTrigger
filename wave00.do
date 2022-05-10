onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /randomtrigger_tb/sCLK
add wave -noupdate /randomtrigger_tb/sRST
add wave -noupdate /randomtrigger_tb/sEN
add wave -noupdate -expand /randomtrigger_tb/sKEY
add wave -noupdate -expand /randomtrigger_tb/sSW
add wave -noupdate /randomtrigger_tb/sEXT_BUSY
add wave -noupdate -radix hexadecimal /randomtrigger_tb/sTHRESHOLD
add wave -noupdate -radix hexadecimal /randomtrigger_tb/sINT_BUSY
add wave -noupdate -radix hexadecimal /randomtrigger_tb/sSHAPER_T_ON
add wave -noupdate -radix hexadecimal /randomtrigger_tb/sFREQ_DIV
add wave -noupdate /randomtrigger_tb/sTRIG
add wave -noupdate /randomtrigger_tb/sLED
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {630 us}

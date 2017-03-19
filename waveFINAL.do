onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /processor_tb/clock
add wave -noupdate /processor_tb/read_file/line_str
add wave -noupdate -radix hexadecimal /processor_tb/read_file/data
add wave -noupdate /processor_tb/read_file/address
add wave -noupdate /processor_tb/start
add wave -noupdate -radix hexadecimal /processor_tb/input
add wave -noupdate -radix hexadecimal /processor_tb/processor1/instruction_decode_stage/instruction
add wave -noupdate -radix unsigned /processor_tb/processor1/instruction_decode_stage/rs_out
add wave -noupdate -radix unsigned /processor_tb/processor1/instruction_decode_stage/rt_out
add wave -noupdate -radix unsigned /processor_tb/processor1/instruction_decode_stage/immediate_out
add wave -noupdate -radix unsigned /processor_tb/processor1/instruction_decode_stage/immediate
add wave -noupdate /processor_tb/processor1/instruction_decode_stage/registers_in_use
add wave -noupdate -radix unsigned /processor_tb/processor1/instruction_decode_stage/rd
add wave -noupdate /processor_tb/processor1/instruction_decode_stage/write_en
add wave -noupdate /processor_tb/processor1/instruction_decode_stage/write_done
add wave -noupdate -radix hexadecimal /processor_tb/processor1/instruction_decode_stage/opcode_out
add wave -noupdate -radix unsigned /processor_tb/processor1/execute_stage/rs
add wave -noupdate -radix unsigned /processor_tb/processor1/execute_stage/rt
add wave -noupdate -radix unsigned /processor_tb/processor1/execute_stage/imm
add wave -noupdate -radix unsigned /processor_tb/processor1/execute_stage/result
add wave -noupdate -radix unsigned /processor_tb/processor1/memory_stage/alu_result
add wave -noupdate -radix unsigned /processor_tb/processor1/memory_data_out_mem
add wave -noupdate -radix unsigned /processor_tb/processor1/Write_back_stage/alu_result
add wave -noupdate -radix unsigned /processor_tb/processor1/Write_back_stage/read_data
add wave -noupdate -radix unsigned /processor_tb/processor1/Write_back_stage/Mux_res
add wave -noupdate /processor_tb/processor1/Write_back_stage/src
add wave -noupdate -radix unsigned /processor_tb/processor1/Write_back_stage/output
add wave -noupdate /processor_tb/processor1/instruction_decode_stage/write_en
add wave -noupdate -radix unsigned /processor_tb/processor1/instruction_decode_stage/rd_in
add wave -noupdate -radix unsigned /processor_tb/processor1/instruction_decode_stage/write_data
add wave -noupdate -radix unsigned -childformat {{/processor_tb/processor1/instruction_decode_stage/reg_block(31) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(30) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(29) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(28) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(27) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(26) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(25) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(24) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(23) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(22) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(21) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(20) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(19) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(18) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(17) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(16) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(15) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(14) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(13) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(12) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(11) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(10) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(9) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(8) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(7) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(6) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(5) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(4) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(3) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(2) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(1) -radix unsigned} {/processor_tb/processor1/instruction_decode_stage/reg_block(0) -radix unsigned}} -expand -subitemconfig {/processor_tb/processor1/instruction_decode_stage/reg_block(31) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(30) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(29) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(28) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(27) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(26) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(25) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(24) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(23) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(22) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(21) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(20) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(19) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(18) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(17) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(16) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(15) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(14) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(13) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(12) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(11) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(10) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(9) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(8) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(7) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(6) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(5) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(4) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(3) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(2) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(1) {-height 15 -radix unsigned} /processor_tb/processor1/instruction_decode_stage/reg_block(0) {-height 15 -radix unsigned}} /processor_tb/processor1/instruction_decode_stage/reg_block
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22519 ps} 0} {{Cursor 7} {23498 ps} 0} {{Cursor 8} {24499 ps} 0} {{Cursor 9} {192601 ps} 0} {{Cursor 10} {20491 ps} 0} {{Cursor 6} {21493 ps} 0} {{Cursor 7} {31355 ps} 0}
quietly wave cursor active 7
configure wave -namecolwidth 386
configure wave -valuecolwidth 40
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
configure wave -timelineunits ns
update
WaveRestoreZoom {30171 ps} {43419 ps}
bookmark add wave bookmark0 {{7298 ps} {20478 ps}} 0

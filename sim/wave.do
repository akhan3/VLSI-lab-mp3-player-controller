onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {playcontrol - DUT}
add wave -noupdate -format Logic /playcontrol_tb/uut/clk
add wave -noupdate -format Logic /playcontrol_tb/uut/reset
add wave -noupdate -divider {KBC INTF}
add wave -noupdate -format Logic /playcontrol_tb/uut/key_empty
add wave -noupdate -format Logic /playcontrol_tb/uut/key_rd
add wave -noupdate -format Logic /playcontrol_tb/uut/key_rd_ack
add wave -noupdate -format Literal /playcontrol_tb/uut/key_data
add wave -noupdate -format Logic /playcontrol_tb/uut/listnext
add wave -noupdate -format Logic /playcontrol_tb/uut/listprev
add wave -noupdate -divider {LIST CTRL FSM}
add wave -noupdate -format Logic /playcontrol_tb/uut/listcrtl_req
add wave -noupdate -format Logic /playcontrol_tb/uut/listcrtl_gnt
add wave -noupdate -format Logic /playcontrol_tb/uut/listcrtl_ctrl
add wave -noupdate -format Logic /playcontrol_tb/uut/listcrtl_busiv
add wave -noupdate -format Literal /playcontrol_tb/uut/listcrtl_busi
add wave -noupdate -format Logic /playcontrol_tb/uut/info_ready
add wave -noupdate -format Logic /playcontrol_tb/uut/info_start
add wave -noupdate -format Logic /playcontrol_tb/uut/list_ctrl_inst/listnext
add wave -noupdate -format Logic /playcontrol_tb/uut/list_ctrl_inst/listprev
add wave -noupdate -format Logic /playcontrol_tb/uut/list_ctrl_inst/gnt
add wave -noupdate -format Logic /playcontrol_tb/uut/list_ctrl_inst/busy
add wave -noupdate -format Logic /playcontrol_tb/uut/list_ctrl_inst/info_ready
add wave -noupdate -format Logic /playcontrol_tb/uut/list_ctrl_inst/req
add wave -noupdate -format Literal /playcontrol_tb/uut/list_ctrl_inst/busi
add wave -noupdate -format Logic /playcontrol_tb/uut/list_ctrl_inst/busiv
add wave -noupdate -format Logic /playcontrol_tb/uut/list_ctrl_inst/ctrl
add wave -noupdate -format Logic /playcontrol_tb/uut/list_ctrl_inst/info_start
add wave -noupdate -format Literal /playcontrol_tb/uut/list_ctrl_inst/state
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/list_ctrl_inst/next_state
add wave -noupdate -format Logic /playcontrol_tb/uut/list_ctrl_inst/busi_le
add wave -noupdate -divider {ARBITER MUX}
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_fio_req
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_fio_gnt
add wave -noupdate -format Literal /playcontrol_tb/uut/arbiter_fio_bus_in
add wave -noupdate -format Literal /playcontrol_tb/uut/arbiter_fio_bus_out
add wave -noupdate -format Logic /playcontrol_tb/uut/arbiter_mux_inst/clk
add wave -noupdate -format Logic /playcontrol_tb/uut/arbiter_mux_inst/reset
add wave -noupdate -format Literal /playcontrol_tb/uut/arbiter_mux_inst/bus_in
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_mux_inst/req
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_mux_inst/gnt
add wave -noupdate -format Literal /playcontrol_tb/uut/arbiter_mux_inst/fio_bus
add wave -noupdate -format Logic /playcontrol_tb/uut/arbiter_mux_inst/gnt_le
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_mux_inst/gnt_next
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_mux_inst/gnt_reg
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_mux_inst/req_mask
add wave -noupdate -divider {FIO CTRL}
add wave -noupdate -format Logic /playcontrol_tb/uut/ctrl
add wave -noupdate -format Literal /playcontrol_tb/uut/busi
add wave -noupdate -format Logic /playcontrol_tb/uut/busiv
add wave -noupdate -format Logic /playcontrol_tb/uut/busy
add wave -noupdate -format Logic /playcontrol_tb/uut/busov
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/buso
add wave -noupdate -divider {LCD CTRL}
add wave -noupdate -format Logic /playcontrol_tb/uut/file_info_processor_inst/clk
add wave -noupdate -format Literal -radix ascii /playcontrol_tb/uut/chrm_wdata
add wave -noupdate -format Logic /playcontrol_tb/uut/chrm_wr
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/chrm_addr
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/lcdc_cmd
add wave -noupdate -format Logic /playcontrol_tb/uut/lcdc_busy
add wave -noupdate -format Literal /playcontrol_tb/uut/ccrm_wdata
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/ccrm_addr
add wave -noupdate -format Logic /playcontrol_tb/uut/ccrm_wr
add wave -noupdate -divider {FILE INFO PROCESSOR}
add wave -noupdate -format Logic /playcontrol_tb/uut/file_info_processor_inst/clk
add wave -noupdate -format Logic /playcontrol_tb/uut/file_info_processor_inst/reset
add wave -noupdate -format Logic /playcontrol_tb/uut/file_info_processor_inst/info_start
add wave -noupdate -format Logic /playcontrol_tb/uut/file_info_processor_inst/info_ready
add wave -noupdate -format Literal /playcontrol_tb/uut/file_info_processor_inst/fio_buso
add wave -noupdate -format Logic /playcontrol_tb/uut/file_info_processor_inst/fio_busov
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/filesize
add wave -noupdate -format Logic /playcontrol_tb/uut/file_info_processor_inst/lcdc_busy
add wave -noupdate -format Literal /playcontrol_tb/uut/file_info_processor_inst/lcdc_cmd
add wave -noupdate -format Literal -radix ascii /playcontrol_tb/uut/file_info_processor_inst/lcdc_chrm_wdata
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/lcdc_chrm_waddr
add wave -noupdate -format Logic /playcontrol_tb/uut/file_info_processor_inst/lcdc_chrm_wen
add wave -noupdate -format Literal -radix ascii /playcontrol_tb/uut/file_info_processor_inst/fname
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/file_info_processor_inst/fname_lcd_counter
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/file_info_processor_inst/fname_lcd_counter_reg
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/file_info_processor_inst/fio_data_counter
add wave -noupdate -format Logic /playcontrol_tb/uut/file_info_processor_inst/fio_data_counter3_reg
add wave -noupdate -format Logic /playcontrol_tb/uut/file_info_processor_inst/info_ready_bit
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/file_info_processor_inst/lcdc_command
add wave -noupdate -format Logic /playcontrol_tb/uut/file_info_processor_inst/fname_wr_done
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider CODEC
add wave -noupdate -format Logic /playcontrol_tb/uut/hw_full
add wave -noupdate -format Logic /playcontrol_tb/uut/hw_wr
add wave -noupdate -format Literal /playcontrol_tb/uut/hw_din
add wave -noupdate -format Logic /playcontrol_tb/uut/dbuf_almost_full
add wave -noupdate -format Logic /playcontrol_tb/uut/dbuf_wr
add wave -noupdate -format Literal /playcontrol_tb/uut/dbuf_din
add wave -noupdate -format Logic /playcontrol_tb/uut/dbuf_rst
add wave -noupdate -format Logic /playcontrol_tb/uut/sbuf_full
add wave -noupdate -format Logic /playcontrol_tb/uut/sbuf_empty
add wave -noupdate -format Logic /playcontrol_tb/uut/sbuf_rst
add wave -noupdate -format Logic /playcontrol_tb/uut/dec_rst
add wave -noupdate -format Logic /playcontrol_tb/uut/dec_status
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {29711 ns} 0} {{Cursor 2} {32505 ns} 0}
configure wave -namecolwidth 188
configure wave -valuecolwidth 77
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 6
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {32183 ns} {33239 ns}

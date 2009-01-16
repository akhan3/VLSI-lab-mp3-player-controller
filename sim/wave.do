onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {playcontrol - DUT}
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/clk
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/reset
add wave -noupdate -divider {PLAY FSM}
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/clk
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/play
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/pause
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/stop
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/mute
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/volinc
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/voldec
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/file_finished
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/music_finished
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/stop_done
add wave -noupdate -format Literal /playcontrol_tb/uut/play_fsm_inst/state
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/play_fetch_en
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/fio_req
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/fio_gnt
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/fio_busy
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/play_fsm_inst/fio_busi
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/fio_busiv
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/fio_ctrl
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/open_done
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/dec_rst
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/dec_status
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/dbuf_rst
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/sbuf_rst
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/dec_rst_done
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/hw_full
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/hw_wr
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/play_fsm_inst/hw_din
add wave -noupdate -format Logic /playcontrol_tb/uut/play_fsm_inst/mute_state
add wave -noupdate -format Literal /playcontrol_tb/uut/play_fsm_inst/vol_state
add wave -noupdate -format Literal /playcontrol_tb/uut/play_fsm_inst/next_state
add wave -noupdate -divider {MONITOR FSM}
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/clk
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/play_fetch_en
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/dbuf_afull
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/fetch_en
add wave -noupdate -format Literal /playcontrol_tb/uut/monitor_fsm_inst/state
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/fio_req
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/fio_gnt
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/fio_busy
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/fio_busiv
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/monitor_fsm_inst/fio_busi
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/fio_ctrl
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/param_done
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/read_done
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/monitor_fsm_inst/fetch_param_dword
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/monitor_fsm_inst/fetch_num_dword
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/monitor_fsm_inst/this_dword_cnt
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/monitor_fsm_inst/total_dword_cnt
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/monitor_fsm_inst/file_size_dword
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/file_finished
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/music_finished
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/monitor_fsm_inst/fio_buso
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/fio_busov
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/sbuf_full
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/sbuf_empty
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/dec_status
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/monitor_fsm_inst/dbuf_wdata
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/dbuf_wr
add wave -noupdate -format Logic /playcontrol_tb/uut/monitor_fsm_inst/fio_req_s
add wave -noupdate -format Literal /playcontrol_tb/uut/monitor_fsm_inst/next_state
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/monitor_fsm_inst/file_size_byte
add wave -noupdate -divider {LIST CTRL FSM}
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/clk
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/listcrtl_req
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/listcrtl_gnt
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/listcrtl_ctrl
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/listcrtl_busiv
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/listcrtl_busi
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/file_info_start
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/file_info_ready
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/listnext
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/listprev
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/state
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/next_state
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/fio_busy
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/fio_gnt
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/fio_req
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/fio_busi
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/fio_busiv
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/fio_ctrl
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/list_ctrl_inst/fio_busi_le
add wave -noupdate -divider {ARBITER MUX}
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/clk
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_fio_req
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_fio_gnt
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/arbiter_fio_bus_in
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/arbiter_fio_bus_out
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/arbiter_mux_inst/clk
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/arbiter_mux_inst/reset
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/arbiter_mux_inst/bus_in
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_mux_inst/req
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_mux_inst/gnt
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/arbiter_mux_inst/bus_out
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/arbiter_mux_inst/gnt_le
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_mux_inst/gnt_next
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_mux_inst/gnt_reg
add wave -noupdate -format Literal -radix binary /playcontrol_tb/uut/arbiter_mux_inst/req_mask
add wave -noupdate -divider {FIO CTRL}
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/clk
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/ctrl
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/busi
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/busiv
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/busy
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/busov
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/buso
add wave -noupdate -divider {LCD CTRL}
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/clk
add wave -noupdate -format Literal -radix ascii /playcontrol_tb/uut/chrm_wdata
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/chrm_wr
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/chrm_addr
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/lcdc_cmd
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/lcdc_busy
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/ccrm_wdata
add wave -noupdate -format Literal -radix unsigned /playcontrol_tb/uut/ccrm_addr
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/ccrm_wr
add wave -noupdate -divider {FILE INFO PROCESSOR}
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/clk
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/file_info_start
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/file_info_ready
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/fio_buso
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/fio_busov
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/file_size_byte
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/lcdc_busy
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/lcdc_cmd
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/lcdc_chrm_wdata
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/lcdc_chrm_waddr
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/lcdc_chrm_wen
add wave -noupdate -format Literal -radix ascii /playcontrol_tb/uut/file_info_processor_inst/fname
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/fname_lcd_counter
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/fname_lcd_counter_reg
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/fio_data_counter
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/fio_data_counter3_reg
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/info_ready_bit
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/lcdc_command
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/file_info_processor_inst/fname_wr_done
add wave -noupdate -divider CODEC
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/hw_full
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/hw_wr
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/hw_din
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/dbuf_almost_full
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/dbuf_wr
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/dbuf_din
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/sbuf_empty
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/sbuf_full
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/dbuf_rst
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/sbuf_rst
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/dec_rst
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/dec_status
add wave -noupdate -divider {KBC INTF}
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/key_empty
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/key_rd_ack
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/key_data
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/key_rd
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/listprev
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/listnext
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/play
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/stop
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/pause
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/mute
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/volinc
add wave -noupdate -format Logic -radix hexadecimal /playcontrol_tb/uut/kbc_intf_inst/voldec
add wave -noupdate -divider <NULL>
add wave -noupdate -divider TESTBENCH
add wave -noupdate -format Logic /playcontrol_tb/clk
add wave -noupdate -format Logic /playcontrol_tb/reset
add wave -noupdate -format Logic /playcontrol_tb/key_empty
add wave -noupdate -format Logic /playcontrol_tb/key_rd
add wave -noupdate -format Logic /playcontrol_tb/key_rd_ack
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/key_data
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/fio_busi
add wave -noupdate -format Logic /playcontrol_tb/fio_busiv
add wave -noupdate -format Logic /playcontrol_tb/fio_ctrl
add wave -noupdate -format Logic /playcontrol_tb/fio_busy
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/fio_buso
add wave -noupdate -format Logic /playcontrol_tb/fio_busov
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/ccrm_wdata
add wave -noupdate -format Literal /playcontrol_tb/ccrm_addr
add wave -noupdate -format Logic /playcontrol_tb/ccrm_wr
add wave -noupdate -format Logic /playcontrol_tb/lcdc_busy
add wave -noupdate -format Literal /playcontrol_tb/lcdc_cmd
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/chrm_addr
add wave -noupdate -format Literal -radix ascii /playcontrol_tb/chrm_wdata
add wave -noupdate -format Logic /playcontrol_tb/chrm_wr
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/hw_din
add wave -noupdate -format Logic /playcontrol_tb/hw_wr
add wave -noupdate -format Logic /playcontrol_tb/hw_full
add wave -noupdate -format Logic /playcontrol_tb/dbuf_almost_full
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/dbuf_din
add wave -noupdate -format Logic /playcontrol_tb/dbuf_wr
add wave -noupdate -format Logic /playcontrol_tb/dbuf_rst
add wave -noupdate -format Logic /playcontrol_tb/sbuf_rst
add wave -noupdate -format Logic /playcontrol_tb/sbuf_empty
add wave -noupdate -format Logic /playcontrol_tb/sbuf_full
add wave -noupdate -format Logic /playcontrol_tb/dec_rst
add wave -noupdate -format Logic /playcontrol_tb/dec_status
add wave -noupdate -format Literal /playcontrol_tb/test_state
add wave -noupdate -format Literal /playcontrol_tb/file_cnt
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/file_data_cnt
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/dbuf_all_data_cnt
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/dbuf_curr_data_cnt
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/req_data_size
add wave -noupdate -format Logic /playcontrol_tb/dbuf_reset_status
add wave -noupdate -format Logic /playcontrol_tb/sbuf_reset_status
add wave -noupdate -format Logic /playcontrol_tb/dec_reset_status
add wave -noupdate -format Literal -radix hexadecimal /playcontrol_tb/curr_key
add wave -noupdate -format Logic /playcontrol_tb/first_list
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {322995 ns} 0} {{Cursor 2} {83205 ns} 0}
configure wave -namecolwidth 160
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
WaveRestoreZoom {321827 ns} {324163 ns}

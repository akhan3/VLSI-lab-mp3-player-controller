onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {LCDC MDL}
add wave -noupdate -format Logic /sim/lcdc_mdl_inst/clk
add wave -noupdate -format Logic /sim/lcdc_mdl_inst/reset
add wave -noupdate -format Logic /sim/lcdc_mdl_inst/chrm_wr
add wave -noupdate -format Literal -radix ascii /sim/lcdc_mdl_inst/chrm_wdata
add wave -noupdate -format Literal -radix unsigned /sim/lcdc_mdl_inst/chrm_addr
add wave -noupdate -format Logic /sim/lcdc_mdl_inst/ccrm_wr
add wave -noupdate -format Literal -radix hexadecimal /sim/lcdc_mdl_inst/ccrm_wdata
add wave -noupdate -format Literal -radix unsigned /sim/lcdc_mdl_inst/ccrm_addr
add wave -noupdate -format Literal /sim/lcdc_mdl_inst/lcdc_cmd
add wave -noupdate -format Logic /sim/lcdc_mdl_inst/lcdc_busy
add wave -noupdate -format Literal -radix ascii /sim/lcdc_mdl_inst/char_mem
add wave -noupdate -format Literal -radix hexadecimal /sim/lcdc_mdl_inst/cc_mem
add wave -noupdate -format Literal -radix ascii /sim/lcdc_mdl_inst/lcd_string
add wave -noupdate -format Literal -radix hexadecimal /sim/lcdc_mdl_inst/lcd_display_algo/cc_word
add wave -noupdate -format Logic /sim/lcdc_mdl_inst/lcd_display_algo/v
add wave -noupdate -format Logic /sim/lcdc_mdl_inst/lcd_display_algo/ctr
add wave -noupdate -format Literal /sim/lcdc_mdl_inst/lcd_display_algo/cpos
add wave -noupdate -format Literal /sim/lcdc_mdl_inst/lcd_display_algo/clth
add wave -noupdate -format Literal /sim/lcdc_mdl_inst/lcd_display_algo/cbad
add wave -noupdate -format Literal /sim/lcdc_mdl_inst/lcd_display_algo/csad
add wave -noupdate -format Literal /sim/lcdc_mdl_inst/lcd_display_algo/wlth
add wave -noupdate -format Literal /sim/lcdc_mdl_inst/lcd_display_algo/addr
add wave -noupdate -format Literal /sim/lcdc_mdl_inst/lcd_display_algo/lcdpos
add wave -noupdate -divider {DISPLAY CTRL}
add wave -noupdate -divider {FILE INFO PROCESSOR}
add wave -noupdate -format Logic /sim/uut/file_info_processor_inst/clk
add wave -noupdate -format Logic /sim/uut/file_info_processor_inst/lcd_filename_valid
add wave -noupdate -format Literal -radix ascii /sim/uut/file_info_processor_inst/lcd_filename
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/file_info_processor_inst/file_info_start
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/file_info_processor_inst/file_info_ready
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/file_info_processor_inst/fio_buso
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/file_info_processor_inst/fio_busov
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/file_info_processor_inst/file_size_byte
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/file_info_processor_inst/lcdc_busy
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/file_info_processor_inst/lcdc_cmd
add wave -noupdate -format Literal -radix ascii /sim/uut/file_info_processor_inst/lcdc_chrm_wdata
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/file_info_processor_inst/lcdc_chrm_waddr
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/file_info_processor_inst/lcdc_chrm_wen
add wave -noupdate -format Literal -radix ascii /sim/uut/file_info_processor_inst/fname
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/file_info_processor_inst/fname_lcd_counter
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/file_info_processor_inst/fname_lcd_counter_reg
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/file_info_processor_inst/fio_data_counter
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/file_info_processor_inst/fio_data_counter3_reg
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/file_info_processor_inst/info_ready_bit
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/file_info_processor_inst/lcdc_command
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/file_info_processor_inst/fname_wr_done
add wave -noupdate -divider {MONITOR FSM}
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/clk
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/seekfwd
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/seekbkw
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/seek_param_done
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/seek_cmd_done
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/decrst_onseek
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/seek_req
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/monitor_fsm_inst/seek_cmd_val
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/fetch_en
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/fetch_en_r
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/file_start_os
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/dbuf_afull
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/dbuf_wr_en
add wave -noupdate -format Literal /sim/uut/monitor_fsm_inst/state
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/fio_req
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/fio_gnt
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/fio_busy
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/fio_busiv
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/monitor_fsm_inst/fio_busi
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/fio_ctrl
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/read_param_done
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/read_done
add wave -noupdate -format Literal -radix unsigned /sim/uut/monitor_fsm_inst/fetch_param_dword
add wave -noupdate -format Literal -radix unsigned /sim/uut/monitor_fsm_inst/fetch_num_dword
add wave -noupdate -format Literal -radix unsigned /sim/uut/monitor_fsm_inst/remain_num_dword
add wave -noupdate -format Literal -radix unsigned /sim/uut/monitor_fsm_inst/this_dword_cnt
add wave -noupdate -format Literal -radix unsigned /sim/uut/monitor_fsm_inst/total_dword_cnt
add wave -noupdate -format Literal -radix unsigned /sim/uut/monitor_fsm_inst/file_size_dword
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/file_finished
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/music_finished
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/monitor_fsm_inst/fio_buso
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/fio_busov
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/sbuf_full
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/sbuf_empty
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/monitor_fsm_inst/dbuf_wdata
add wave -noupdate -format Logic /sim/uut/monitor_fsm_inst/dbuf_wr
add wave -noupdate -format Literal /sim/uut/monitor_fsm_inst/next_state
add wave -noupdate -format Literal -radix unsigned /sim/uut/monitor_fsm_inst/file_size_byte
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/monitor_fsm_inst/trig0
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/monitor_fsm_inst/control0
add wave -noupdate -divider {playcontrol - DUT}
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/clk
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/reset
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/to_chipscope
add wave -noupdate -divider {PLAY FSM}
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/clk
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/play
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/pause
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/stop
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/mute
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/volinc
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/voldec
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/file_finished
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/music_finished
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/decrst_onseek
add wave -noupdate -format Literal /sim/uut/play_fsm_inst/state
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/fetch_en
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/fio_req
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/fio_gnt
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/fio_busy
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/play_fsm_inst/fio_busi
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/fio_busiv
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/fio_ctrl
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/open_done
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/stopping
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/dec_rst
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/dec_status
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/dec_status_r
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/dec_status_fall
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/dbuf_rst
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/sbuf_rst
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/dec_rst_done
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/hw_full
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/hw_wr
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/play_fsm_inst/hw_din
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/mute_state
add wave -noupdate -format Literal /sim/uut/play_fsm_inst/vol_state
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/volinc_r
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/voldec_r
add wave -noupdate -format Logic /sim/uut/play_fsm_inst/mute_r
add wave -noupdate -format Literal /sim/uut/play_fsm_inst/next_state
add wave -noupdate -divider {LIST CTRL FSM}
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/list_ctrl_inst/clk
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/listcrtl_req
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/listcrtl_gnt
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/listcrtl_ctrl
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/listcrtl_busiv
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/listcrtl_busi
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/list_ctrl_inst/file_info_start
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/list_ctrl_inst/file_info_ready
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/list_ctrl_inst/listnext
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/list_ctrl_inst/listprev
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/list_ctrl_inst/state
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/list_ctrl_inst/next_state
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/list_ctrl_inst/fio_busy
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/list_ctrl_inst/fio_gnt
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/list_ctrl_inst/fio_req
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/list_ctrl_inst/fio_busi
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/list_ctrl_inst/fio_busiv
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/list_ctrl_inst/fio_ctrl
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/list_ctrl_inst/fio_busi_le
add wave -noupdate -divider {ARBITER MUX}
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/clk
add wave -noupdate -format Literal -radix binary /sim/uut/arbiter_fio_req
add wave -noupdate -format Literal -radix binary /sim/uut/arbiter_fio_gnt
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/arbiter_fio_bus_in
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/arbiter_fio_bus_out
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/arbiter_mux_inst/clk
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/arbiter_mux_inst/reset
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/arbiter_mux_inst/bus_in
add wave -noupdate -format Literal -radix binary /sim/uut/arbiter_mux_inst/req
add wave -noupdate -format Literal -radix binary /sim/uut/arbiter_mux_inst/gnt
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/arbiter_mux_inst/bus_out
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/arbiter_mux_inst/gnt_le
add wave -noupdate -format Literal -radix binary /sim/uut/arbiter_mux_inst/gnt_next
add wave -noupdate -format Literal -radix binary /sim/uut/arbiter_mux_inst/gnt_reg
add wave -noupdate -format Literal -radix binary /sim/uut/arbiter_mux_inst/req_mask
add wave -noupdate -divider {FIO CTRL}
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/clk
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/ctrl
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/busi
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/busiv
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/busy
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/busov
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/buso
add wave -noupdate -divider CODEC
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/hw_full
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/hw_wr
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/hw_din
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/dbuf_almost_full
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/dbuf_wr
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/dbuf_din
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/sbuf_empty
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/sbuf_full
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/dbuf_rst
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/sbuf_rst
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/dec_rst
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/dec_status
add wave -noupdate -divider {KBC INTF}
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/kbc_intf_inst/key_empty
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/kbc_intf_inst/key_rd_ack
add wave -noupdate -format Literal -radix hexadecimal /sim/uut/kbc_intf_inst/key_data
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/kbc_intf_inst/key_rd
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/kbc_intf_inst/listprev
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/kbc_intf_inst/listnext
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/kbc_intf_inst/play
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/kbc_intf_inst/stop
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/kbc_intf_inst/pause
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/kbc_intf_inst/mute
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/kbc_intf_inst/volinc
add wave -noupdate -format Logic -radix hexadecimal /sim/uut/kbc_intf_inst/voldec
add wave -noupdate -divider <NULL>
add wave -noupdate -divider TESTBENCH
add wave -noupdate -format Logic /sim/clk
add wave -noupdate -format Logic /sim/reset
add wave -noupdate -format Logic /sim/key_empty
add wave -noupdate -format Logic /sim/key_rd
add wave -noupdate -format Logic /sim/key_rd_ack
add wave -noupdate -format Literal -radix hexadecimal /sim/key_data
add wave -noupdate -format Literal -radix hexadecimal /sim/fio_busi
add wave -noupdate -format Logic /sim/fio_busiv
add wave -noupdate -format Logic /sim/fio_ctrl
add wave -noupdate -format Logic /sim/fio_busy
add wave -noupdate -format Literal -radix hexadecimal /sim/fio_buso
add wave -noupdate -format Logic /sim/fio_busov
add wave -noupdate -format Literal -radix hexadecimal /sim/ccrm_wdata
add wave -noupdate -format Literal /sim/ccrm_addr
add wave -noupdate -format Logic /sim/ccrm_wr
add wave -noupdate -format Logic /sim/lcdc_busy
add wave -noupdate -format Literal /sim/lcdc_cmd
add wave -noupdate -format Literal -radix hexadecimal /sim/chrm_addr
add wave -noupdate -format Literal -radix ascii /sim/chrm_wdata
add wave -noupdate -format Logic /sim/chrm_wr
add wave -noupdate -format Literal -radix hexadecimal /sim/hw_din
add wave -noupdate -format Logic /sim/hw_wr
add wave -noupdate -format Logic /sim/hw_full
add wave -noupdate -format Logic /sim/dbuf_almost_full
add wave -noupdate -format Literal -radix hexadecimal /sim/dbuf_din
add wave -noupdate -format Logic /sim/dbuf_wr
add wave -noupdate -format Logic /sim/dbuf_rst
add wave -noupdate -format Logic /sim/sbuf_rst
add wave -noupdate -format Logic /sim/sbuf_empty
add wave -noupdate -format Logic /sim/sbuf_full
add wave -noupdate -format Logic /sim/dec_rst
add wave -noupdate -format Logic /sim/dec_status
add wave -noupdate -format Literal /sim/test_state
add wave -noupdate -format Literal /sim/file_cnt
add wave -noupdate -format Literal -radix hexadecimal /sim/file_data_cnt
add wave -noupdate -format Literal -radix hexadecimal /sim/dbuf_all_data_cnt
add wave -noupdate -format Literal -radix hexadecimal /sim/dbuf_curr_data_cnt
add wave -noupdate -format Literal -radix hexadecimal /sim/req_data_size
add wave -noupdate -format Logic /sim/dbuf_reset_status
add wave -noupdate -format Logic /sim/sbuf_reset_status
add wave -noupdate -format Logic /sim/dec_reset_status
add wave -noupdate -format Literal -radix hexadecimal /sim/curr_key
add wave -noupdate -format Logic /sim/first_list
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {32287 ns} 0} {{Cursor 2} {88230 ns} 0}
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
WaveRestoreZoom {30459 ns} {51124 ns}

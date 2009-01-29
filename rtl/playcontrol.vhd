-------------------------------------------------------------------------------
-- Project                    : MP3 Player Controller
-- Entity                     : playcontrol
-- Entity description         : Top level wrapper for the project
--
-- Author                     : AAK
-- Created on                 : 04 Jan, 2009
-- Last revision on           : 26 Jan, 2009
-- Last revision description  : Added fio_buy signal to chipscope
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.system_constants_pkg.all;

entity playcontrol is
  port (
    clk               : in std_logic;               --clock signal
    reset             : in std_logic;               --asynchronous reset

    key_empty         : in  std_logic;
    key_rd            : out std_logic;
    key_rd_ack        : in  std_logic;
    key_data          : in  std_logic_vector(7 downto 0);

    ctrl              : out std_logic;
    busi              : out std_logic_vector(7 downto 0);
    busiv             : out std_logic;
    busy              : in  std_logic;
    busov             : in  std_logic;
    buso              : in  std_logic_vector(31 downto 0);

    chrm_wdata        : out std_logic_vector(7 downto 0);
    chrm_wr           : out std_logic;
    chrm_addr         : out std_logic_vector(7 downto 0);
    lcdc_cmd          : out std_logic_vector(1 downto 0);
    lcdc_busy         : in  std_logic;
    ccrm_wdata        : out std_logic_vector(35 downto 0);
    ccrm_addr         : out std_logic_vector(4 downto 0);
    ccrm_wr           : out std_logic;

    hw_full           : in  std_logic;
    hw_wr             : out std_logic;
    hw_din            : out std_logic_vector(31 downto 0);

    dbuf_almost_full  : in  std_logic;
    dbuf_wr           : out std_logic;
    dbuf_din          : out std_logic_vector(31 downto 0);
    dbuf_rst          : out std_logic;

    sbuf_full         : in  std_logic;
    sbuf_empty        : in  std_logic;
    sbuf_rst          : out std_logic;

    dec_rst           : out std_logic;
    dec_status        : in  std_logic
  );
end playcontrol;

architecture playcontrol_arch of playcontrol is

  component kbc_intf is
    port(
      key_empty   : in  std_logic;
      key_rd_ack  : in  std_logic;
      key_data    : in  std_logic_vector(7 downto 0);
      key_rd      : out std_logic;
      startup_key : out std_logic;
      scroll_sw   : out std_logic;
      scroll_fast : out std_logic;
      scroll_slow : out std_logic;
      listprev    : out std_logic;
      listnext    : out std_logic;
      play        : out std_logic;
      stop        : out std_logic;
      pause       : out std_logic;
      mute        : out std_logic;
      volinc      : out std_logic;
      voldec      : out std_logic;
      seekfwd     : out std_logic;
      seekbkw     : out std_logic
    );
  end component;

  component arbiter_mux is
    port(
      clk     : in  std_logic;
      reset   : in  std_logic;
      bus_in  : in  std_logic_vector(3*10-1 downto 0);  -- 10-bit bus input from 3 Masters
      req     : in  std_logic_vector(2 downto 0);       -- request signal from 3 Masters
      gnt     : out std_logic_vector(2 downto 0);       -- grant signal to 3 Masters
      bus_out : out std_logic_vector(9 downto 0)        -- 10-bit bus output to FIO
    );
  end component;

  component list_ctrl is
    port(
      clk               : in  std_logic;
      reset             : in  std_logic;
      listnext          : in  std_logic;
      listprev          : in  std_logic;
      file_info_ready   : in  std_logic;
      fio_busy          : in  std_logic;
      fio_gnt           : in  std_logic;
      fio_req           : out std_logic;
      fio_busi          : out std_logic_vector(7 downto 0);
      fio_busiv         : out std_logic;
      fio_ctrl          : out std_logic;
      file_info_start   : out std_logic
    );
  end component;

  component display_ctrl is
    port(
      clk                 : in  std_logic;
      reset               : in  std_logic;
      lcd_playing_status  : in  std_logic_vector(2 downto 0);
      lcd_vol_status      : in  std_logic_vector(4 downto 0);
      lcd_mute_status     : in  std_logic;
      lcd_seek_status     : in  std_logic_vector(1 downto 0);
      lcd_prog_value      : in  std_logic_vector(6 downto 0);
      lcd_filename_valid  : in  std_logic;
      lcd_filename        : in  std_logic_vector(8*12-1 downto 0);
      startup_key         : in  std_logic;
      scroll_sw           : in  std_logic;
      scroll_fast         : in  std_logic;
      scroll_slow         : in  std_logic;
      lcdc_busy           : in  std_logic;
      lcdc_cmd            : out std_logic_vector(1 downto 0);
      chrm_wr             : out std_logic;
      chrm_wdata          : out std_logic_vector(7 downto 0);
      chrm_addr           : out std_logic_vector(7 downto 0);
      ccrm_wdata          : out std_logic_vector(35 downto 0);
      ccrm_addr           : out std_logic_vector(4 downto 0);
      ccrm_wr             : out std_logic
    );
  end component;

  component play_fsm is
    port(
      clk             : in  std_logic;
      reset           : in  std_logic;
      play            : in  std_logic;
      pause           : in  std_logic;
      stop            : in  std_logic;
      mute            : in  std_logic;
      volinc          : in  std_logic;
      voldec          : in  std_logic;
      hw_full         : in  std_logic;
      hw_wr           : out std_logic;
      hw_din          : out std_logic_vector(31 downto 0);
      dec_status      : in  std_logic;
      decrst_onseek   : in  std_logic;
      file_finished   : in  std_logic;
      music_finished  : in  std_logic;
      fio_busy        : in  std_logic;
      fio_gnt         : in  std_logic;
      fio_req         : out std_logic;
      fio_busi        : out std_logic_vector(7 downto 0);
      fio_busiv       : out std_logic;
      fio_ctrl        : out std_logic;
      fetch_en        : out std_logic;
      dec_rst         : out  std_logic;
      dbuf_rst        : out  std_logic;
      sbuf_rst        : out  std_logic;
      lcd_playing_status  : out std_logic_vector(2 downto 0);
      lcd_vol_status      : out std_logic_vector(4 downto 0);
      lcd_mute_status     : out std_logic
    );
  end component;

  component monitor_fsm is
    port(
      clk             : in  std_logic;
      reset           : in  std_logic;
      seekfwd         : in  std_logic;
      seekbkw         : in  std_logic;
      fetch_en        : in  std_logic;
      dbuf_afull      : in  std_logic;
      sbuf_full       : in  std_logic;
      sbuf_empty      : in  std_logic;
      dec_status      : in  std_logic;
      dbuf_wdata      : out std_logic_vector(31 downto 0);
      dbuf_wr         : out std_logic;
      fio_buso        : in  std_logic_vector(31 downto 0);
      fio_busov       : in  std_logic;
      fio_busy        : in  std_logic;
      fio_gnt         : in  std_logic;
      fio_req         : out std_logic;
      fio_busi        : out std_logic_vector(7 downto 0);
      fio_busiv       : out std_logic;
      fio_ctrl        : out std_logic;
      file_size_byte  : in  std_logic_vector(31 downto 0);
      file_finished   : out std_logic;
      music_finished  : out std_logic;
      decrst_onseek   : out std_logic;
      lcd_seek_status : out std_logic_vector(1 downto 0);
      lcd_prog_value  : out std_logic_vector(6 downto 0);
      to_chipscope    : in  std_logic_vector(255 downto 0)
    );
  end component;

  component file_info_processor is
    port(
      clk               : in  std_logic;
      reset             : in  std_logic;
      file_info_start   : in  std_logic;
      file_info_ready   : out std_logic;
      file_size_byte    : out std_logic_vector(31 downto 0);
      fio_buso          : in  std_logic_vector(31 downto 0);
      fio_busov         : in  std_logic;
      lcd_filename_valid: out std_logic;
      lcd_filename      : out std_logic_vector(8*12-1 downto 0)
    );
  end component;

  signal startup_key          : std_logic;
  signal scroll_sw            : std_logic;
  signal scroll_fast          : std_logic;
  signal scroll_slow          : std_logic;
  signal listnext             : std_logic;
  signal listprev             : std_logic;
  signal play                 : std_logic;
  signal stop                 : std_logic;
  signal pause                : std_logic;
  signal mute                 : std_logic;
  signal volinc               : std_logic;
  signal voldec               : std_logic;
  signal seekfwd              : std_logic;
  signal seekbkw              : std_logic;
  signal listcrtl_req         : std_logic;
  signal listcrtl_gnt         : std_logic;
  signal listcrtl_ctrl        : std_logic;
  signal listcrtl_busiv       : std_logic;
  signal listcrtl_busi        : std_logic_vector(7 downto 0);
  signal playfsm_gnt          : std_logic;
  signal playfsm_req          : std_logic;
  signal playfsm_busi         : std_logic_vector(7 downto 0);
  signal playfsm_busiv        : std_logic;
  signal playfsm_ctrl         : std_logic;
  signal monfsm_gnt           : std_logic;
  signal monfsm_req           : std_logic;
  signal monfsm_busi          : std_logic_vector(7 downto 0);
  signal monfsm_busiv         : std_logic;
  signal monfsm_ctrl          : std_logic;
  signal fetch_en             : std_logic;
  signal file_finished        : std_logic;
  signal music_finished       : std_logic;
  signal decrst_onseek        : std_logic;
  signal file_info_ready      : std_logic;
  signal file_info_start      : std_logic;
  signal arbiter_fio_req      : std_logic_vector(2 downto 0);
  signal arbiter_fio_gnt      : std_logic_vector(2 downto 0);
  signal arbiter_fio_bus_in   : std_logic_vector(29 downto 0);
  signal arbiter_fio_bus_out  : std_logic_vector(9 downto 0);
  signal file_size_byte       : std_logic_vector(31 downto 0);
  signal to_chipscope         : std_logic_vector(255 downto 0);
  signal lcd_playing_status   : std_logic_vector(2 downto 0);
  signal lcd_vol_status       : std_logic_vector(4 downto 0);
  signal lcd_mute_status      : std_logic;
  signal lcd_seek_status      : std_logic_vector(1 downto 0);
  signal lcd_prog_value       : std_logic_vector(6 downto 0);

  signal lcd_filename_valid   : std_logic;
  signal lcd_filename         : std_logic_vector(8*12-1 downto 0);

-- output signals to be read
  signal ctrl_s       : std_logic;
  signal busiv_s      : std_logic;
  signal busi_s       : std_logic_vector(7 downto 0);
  signal hw_din_s     : std_logic_vector(31 downto 0);
  signal hw_wr_s      : std_logic;
  signal dbuf_wr_s    : std_logic;
  signal dbuf_rst_s   : std_logic;
  signal sbuf_rst_s   : std_logic;
  signal dec_rst_s    : std_logic;
  signal chrm_wr_s    : std_logic;
  signal ccrm_wr_s    : std_logic;
  signal lcdc_cmd_s   : std_logic_vector(1 downto 0);
  signal ccrm_addr_s  : std_logic_vector(4 downto 0);
  signal chrm_wdata_s : std_logic_vector(7 downto 0);
  signal chrm_addr_s  : std_logic_vector(7 downto 0);
  signal ccrm_wdata_s : std_logic_vector(35 downto 0);

begin

-- Output signals
  ctrl        <= ctrl_s      ;
  busiv       <= busiv_s     ;
  busi        <= busi_s      ;
  hw_din      <= hw_din_s    ;
  hw_wr       <= hw_wr_s     ;
  dbuf_wr     <= dbuf_wr_s   ;
  dbuf_rst    <= dbuf_rst_s  ;
  sbuf_rst    <= sbuf_rst_s  ;
  dec_rst     <= dec_rst_s   ;
  chrm_wr     <= chrm_wr_s   ;
  ccrm_wr     <= ccrm_wr_s   ;
  lcdc_cmd    <= lcdc_cmd_s  ;
  ccrm_addr   <= ccrm_addr_s ;
  chrm_wdata  <= chrm_wdata_s;
  chrm_addr   <= chrm_addr_s ;
  ccrm_wdata  <= ccrm_wdata_s;

-- Arbiter connections
  ctrl_s  <= arbiter_fio_bus_out(9);
  busiv_s   <= arbiter_fio_bus_out(8);
  busi_s    <= arbiter_fio_bus_out(7 downto 0);

  listcrtl_gnt  <= arbiter_fio_gnt(2);
  monfsm_gnt    <= arbiter_fio_gnt(1);
  playfsm_gnt   <= arbiter_fio_gnt(0);

  arbiter_fio_req  <= listcrtl_req & monfsm_req & playfsm_req;
  arbiter_fio_bus_in <= listcrtl_ctrl & listcrtl_busiv  & listcrtl_busi &
                        monfsm_ctrl   & monfsm_busiv    & monfsm_busi   &
                        playfsm_ctrl  & playfsm_busiv   & playfsm_busi  ;

-- Module instantiations
  kbc_intf_inst: kbc_intf
    port map(
      startup_key =>  startup_key,
      scroll_sw   =>  scroll_sw,
      scroll_fast =>  scroll_fast,
      scroll_slow =>  scroll_slow,
      key_empty   =>  key_empty,
      key_rd_ack  =>  key_rd_ack,
      key_data    =>  key_data,
      key_rd      =>  key_rd,
      listprev    =>  listprev,
      listnext    =>  listnext,
      play        =>  play,
      stop        =>  stop,
      pause       =>  pause,
      mute        =>  mute,
      volinc      =>  volinc,
      voldec      =>  voldec,
      seekfwd     =>  seekfwd,
      seekbkw     =>  seekbkw
    );

  arbiter_mux_inst: arbiter_mux
    port map(
      clk     =>  clk,
      reset   =>  reset,
      bus_in  =>  arbiter_fio_bus_in, -- 10-bit bus input from 3 Masters
      req     =>  arbiter_fio_req,    -- request signal from 3 Masters
      gnt     =>  arbiter_fio_gnt,    -- grant signal to 3 Masters
      bus_out =>  arbiter_fio_bus_out -- 10-bit bus output to FIO
    );

  list_ctrl_inst: list_ctrl
    port map(
      clk             =>  clk,
      reset           =>  reset,
      listnext        =>  listnext,
      listprev        =>  listprev,
      fio_gnt         =>  listcrtl_gnt,
      fio_busy        =>  busy,
      file_info_ready =>  file_info_ready,
      fio_req         =>  listcrtl_req,
      fio_busi        =>  listcrtl_busi,
      fio_busiv       =>  listcrtl_busiv,
      fio_ctrl        =>  listcrtl_ctrl,
      file_info_start =>  file_info_start
    );

  display_ctrl_inst: display_ctrl
    port map(
      clk                 =>  clk,
      reset               =>  reset,

      lcd_playing_status  =>  lcd_playing_status,
      lcd_vol_status      =>  lcd_vol_status,
      lcd_mute_status     =>  lcd_mute_status,

      lcd_seek_status     =>  lcd_seek_status,

      lcd_prog_value      =>  lcd_prog_value,

      lcd_filename_valid  =>  lcd_filename_valid,
      lcd_filename        =>  lcd_filename,

      startup_key         =>  startup_key,
      scroll_sw           =>  scroll_sw,
      scroll_fast         =>  scroll_fast,
      scroll_slow         =>  scroll_slow,

      lcdc_busy           =>  lcdc_busy,
      lcdc_cmd            =>  lcdc_cmd_s,
      chrm_wr             =>  chrm_wr_s,
      chrm_wdata          =>  chrm_wdata_s,
      chrm_addr           =>  chrm_addr_s,
      ccrm_wdata          =>  ccrm_wdata_s,
      ccrm_addr           =>  ccrm_addr_s,
      ccrm_wr             =>  ccrm_wr_s
    );

  play_fsm_inst: play_fsm
    port map(
      clk             =>  clk,
      reset           =>  reset,
      mute            =>  mute,
      volinc          =>  volinc,
      voldec          =>  voldec,
      play            =>  play,
      stop            =>  stop,
      pause           =>  pause,
      hw_full         =>  hw_full,
      hw_wr           =>  hw_wr_s,
      hw_din          =>  hw_din_s,
      dec_status      =>  dec_status,
      fio_busy        =>  busy,
      file_finished   =>  file_finished,
      music_finished  =>  music_finished,
      decrst_onseek   =>  decrst_onseek,
      fio_gnt         =>  playfsm_gnt,
      fio_req         =>  playfsm_req,
      fio_busi        =>  playfsm_busi,
      fio_busiv       =>  playfsm_busiv,
      fio_ctrl        =>  playfsm_ctrl,
      fetch_en        =>  fetch_en,
      dec_rst         =>  dec_rst_s,
      dbuf_rst        =>  dbuf_rst_s,
      sbuf_rst        =>  sbuf_rst_s,
      lcd_playing_status  =>  lcd_playing_status,
      lcd_vol_status      =>  lcd_vol_status,
      lcd_mute_status     =>  lcd_mute_status
    );

  monitor_fsm_inst: monitor_fsm
    port map(
      clk             =>  clk             ,
      reset           =>  reset           ,
      seekfwd         =>  seekfwd,
      seekbkw         =>  seekbkw,
      fetch_en        =>  fetch_en,
      dbuf_afull      =>  dbuf_almost_full,
      sbuf_full       =>  sbuf_full    ,
      sbuf_empty      =>  sbuf_empty   ,
      dec_status      =>  dec_status,
      dbuf_wr         =>  dbuf_wr_s      ,
      dbuf_wdata      =>  dbuf_din     ,
      fio_buso        =>  buso         ,
      fio_busov       =>  busov        ,
      fio_busy        =>  busy         ,
      fio_gnt         =>  monfsm_gnt      ,
      fio_req         =>  monfsm_req      ,
      fio_busi        =>  monfsm_busi         ,
      fio_busiv       =>  monfsm_busiv        ,
      fio_ctrl        =>  monfsm_ctrl         ,
      file_size_byte  =>  file_size_byte     ,
      file_finished   =>  file_finished,
      music_finished  =>  music_finished,
      decrst_onseek   =>  decrst_onseek,
      lcd_seek_status =>  lcd_seek_status,
      lcd_prog_value  =>  lcd_prog_value,
      to_chipscope    =>  to_chipscope
    );

  file_info_processor_inst: file_info_processor
    port map(
      clk             =>  clk,
      reset           =>  reset,
      file_info_start =>  file_info_start,
      file_info_ready =>  file_info_ready,
      fio_buso        =>  buso,
      fio_busov       =>  busov,
      file_size_byte  =>  file_size_byte,
      lcd_filename_valid  =>  lcd_filename_valid,
      lcd_filename        =>  lcd_filename
    );


-------------------------------------------------------------------------------
-- Signals to be monitored with Chipscope
-------------------------------------------------------------------------------
  to_chipscope(8 downto 0)      <= key_rd_ack & key_data;
  to_chipscope(18 downto 9)     <= listnext & listprev & play & stop & pause & mute & volinc & voldec & seekfwd & seekbkw;
  to_chipscope(29 downto 20)    <= ctrl_s & busiv_s & busi_s;
  to_chipscope(31 downto 30)    <= clk & reset;
  to_chipscope(64 downto 32)    <= busov & buso;
  to_chipscope(68)              <= busy;
  to_chipscope(73 downto 72)    <= file_info_start & file_info_ready;
  to_chipscope(109 downto 76)   <= hw_full & hw_wr_s & hw_din_s;
  to_chipscope(114 downto 112)  <= file_finished & music_finished & fetch_en;
  to_chipscope(119 downto 116)  <= dbuf_almost_full & sbuf_full & sbuf_empty & dbuf_wr_s;
  to_chipscope(124 downto 120)  <= dbuf_rst_s & sbuf_rst_s & dec_rst_s & decrst_onseek & dec_status;
  to_chipscope(159 downto 128)  <= file_size_byte;
  to_chipscope(65)              <= chrm_wr_s;
  to_chipscope(66)              <= ccrm_wr_s;
  to_chipscope(67)              <= lcdc_busy;
  to_chipscope(75 downto 74)    <= lcdc_cmd_s;
  to_chipscope(164 downto 160)  <= ccrm_addr_s;
  to_chipscope(175 downto 168)  <= chrm_wdata_s;
  to_chipscope(183 downto 176)  <= chrm_addr_s;
  to_chipscope(219 downto 184)  <= ccrm_wdata_s;


end architecture;

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
      key_empty     : in  std_logic;
      key_rd_ack    : in  std_logic;
      key_data      : in  std_logic_vector(7 downto 0);
      key_rd        : out std_logic;
      listprev  : out std_logic;
      listnext  : out std_logic;
      play  : out std_logic;
      stop  : out std_logic;
      pause : out std_logic;
      mute  : out std_logic;
      volinc: out std_logic;
      voldec: out std_logic
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
      clk         : in  std_logic;
      reset       : in  std_logic;
      listnext    : in  std_logic;
      listprev    : in  std_logic;
      file_info_ready  : in  std_logic;
      fio_busy        : in  std_logic;
      fio_gnt         : in  std_logic;
      fio_req         : out std_logic;
      fio_busi        : out std_logic_vector(7 downto 0);
      fio_busiv       : out std_logic;
      fio_ctrl        : out std_logic;
      file_info_start  : out std_logic
    );
  end component;

  component play_fsm is
    port(
      clk         : in  std_logic;
      reset       : in  std_logic;
      play    : in  std_logic;
      stop    : in  std_logic;
      pause   : in  std_logic;
      dec_status  : in  std_logic;
      file_finished:in  std_logic;
      fio_busy    : in  std_logic;
      fio_gnt         : in  std_logic;
      fio_req         : out std_logic;
      fio_busi    : out std_logic_vector(7 downto 0);
      fio_busiv   : out std_logic;
      fio_ctrl    : out std_logic;
      play_en    : out std_logic;
      dec_rst   : out  std_logic;
      dbuf_rst  : out  std_logic;
      sbuf_rst  : out  std_logic
    );
  end component;

  component monitor_fsm is
    port(
      clk         : in  std_logic;
      reset       : in  std_logic;
      play_en     : in  std_logic;
      dbuf_afull  : in  std_logic;
      sbuf_full   : in  std_logic;
      sbuf_empty  : in  std_logic;
      dec_status  : in  std_logic;
      dbuf_wdata  : out std_logic_vector(31 downto 0);
      dbuf_wr     : out std_logic;
      fio_buso        : in  std_logic_vector(31 downto 0);
      fio_busov       : in  std_logic;
      fio_busy        : in  std_logic;
      fio_gnt         : in  std_logic;
      fio_req         : out std_logic;
      fio_busi        : out std_logic_vector(7 downto 0);
      fio_busiv       : out std_logic;
      fio_ctrl        : out std_logic;
      file_size_byte        : in  std_logic_vector(31 downto 0);
      file_finished   : out std_logic
    );
  end component;

  component file_info_processor is
    port(
      clk             : in  std_logic;
      reset           : in  std_logic;
      file_info_start      : in  std_logic;
      file_info_ready      : out std_logic;
      fio_buso        : in  std_logic_vector(31 downto 0);
      fio_busov       : in  std_logic;
      file_size_byte         : out std_logic_vector(31 downto 0);

      lcdc_busy       : in  std_logic;
  --     lcdc_gnt        : in  std_logic;
  --     lcdc_req        : out std_logic;
      lcdc_cmd        : out std_logic_vector(1 downto 0);
  --     lcdc_ccrm_wdata : out std_logic_vector(35 downto 0);
  --     lcdc_ccrm_waddr : out std_logic_vector(4 downto 0);
  --     lcdc_ccrm_wen   : out std_logic;
      lcdc_chrm_wdata : out std_logic_vector(7 downto 0);
      lcdc_chrm_waddr : out std_logic_vector(7 downto 0);
      lcdc_chrm_wen   : out std_logic
    );
  end component;

  signal listnext       : std_logic;
  signal listprev       : std_logic;
  signal play       : std_logic;
  signal stop       : std_logic;
  signal pause      : std_logic;
  signal mute       : std_logic;
  signal volinc     : std_logic;
  signal voldec     : std_logic;
  signal listcrtl_req   : std_logic;
  signal listcrtl_gnt   : std_logic;
  signal listcrtl_ctrl  : std_logic;
  signal listcrtl_busiv : std_logic;
  signal listcrtl_busi  : std_logic_vector(7 downto 0);
  signal playfsm_gnt    : std_logic;
  signal playfsm_req    : std_logic;
  signal playfsm_busi   : std_logic_vector(7 downto 0);
  signal playfsm_busiv  : std_logic;
  signal playfsm_ctrl   : std_logic;
  signal monfsm_gnt    : std_logic;
  signal monfsm_req    : std_logic;
  signal monfsm_busi   : std_logic_vector(7 downto 0);
  signal monfsm_busiv  : std_logic;
  signal monfsm_ctrl   : std_logic;
  signal play_en  : std_logic;
  signal file_finished  : std_logic;
  signal file_info_ready     : std_logic;
  signal file_info_start     : std_logic;
  signal arbiter_fio_req: std_logic_vector(2 downto 0);
  signal arbiter_fio_gnt: std_logic_vector(2 downto 0);
  signal arbiter_fio_bus_in : std_logic_vector(29 downto 0);
  signal arbiter_fio_bus_out : std_logic_vector(9 downto 0);
  signal file_size_byte  : std_logic_vector(31 downto 0);

begin
  ctrl <= arbiter_fio_bus_out(9);
  busiv <= arbiter_fio_bus_out(8);
  busi <= arbiter_fio_bus_out(7 downto 0);

  listcrtl_gnt <= arbiter_fio_gnt(2);
  monfsm_gnt <= arbiter_fio_gnt(1);
  playfsm_gnt <= arbiter_fio_gnt(0);

  arbiter_fio_req <= listcrtl_req & monfsm_req & playfsm_req;

  arbiter_fio_bus_in <= listcrtl_ctrl & listcrtl_busiv & listcrtl_busi &
                        monfsm_ctrl & monfsm_busiv & monfsm_busi &
                        playfsm_ctrl & playfsm_busiv & playfsm_busi;

  kbc_intf_inst: kbc_intf
    port map(
      key_empty     =>  key_empty,
      key_rd_ack    =>  key_rd_ack,
      key_data      =>  key_data,
      key_rd        =>  key_rd,
      listprev  =>  listprev,
      listnext  =>  listnext,
      play  =>  play,
      stop  =>  stop,
      pause =>  pause,
      mute  =>  mute,
      volinc=>  volinc,
      voldec=>  voldec
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
      clk         =>  clk,
      reset       =>  reset,
      listnext    =>  listnext,
      listprev    =>  listprev,
      fio_gnt         =>  listcrtl_gnt,
      fio_busy        =>  busy,
      file_info_ready  =>  file_info_ready,
      fio_req         =>  listcrtl_req,
      fio_busi        =>  listcrtl_busi,
      fio_busiv       =>  listcrtl_busiv,
      fio_ctrl        =>  listcrtl_ctrl,
      file_info_start  =>  file_info_start
    );

  play_fsm_inst: play_fsm
    port map(
      clk           =>  clk,
      reset         =>  reset,
      play      =>  play,
      stop      =>  stop,
      pause     =>  pause,
      dec_status   =>  dec_status,
      fio_busy      =>  busy,
      file_finished =>  file_finished,
      fio_gnt           =>  playfsm_gnt,
      fio_req           =>  playfsm_req,
      fio_busi      =>  playfsm_busi,
      fio_busiv     =>  playfsm_busiv,
      fio_ctrl      =>  playfsm_ctrl,
      play_en         =>  play_en,
      dec_rst   =>  dec_rst,
      dbuf_rst  =>  dbuf_rst,
      sbuf_rst  =>  sbuf_rst
    );

  monitor_fsm_inst: monitor_fsm
    port map(
      clk             =>  clk             ,
      reset           =>  reset           ,
      play_en         =>  play_en         ,
      dbuf_afull      =>  dbuf_almost_full,
      sbuf_full       =>  sbuf_full    ,
      sbuf_empty      =>  sbuf_empty   ,
      dec_status      =>  dec_status   ,
      dbuf_wr         =>  dbuf_wr      ,
      dbuf_wdata      =>  dbuf_din     ,
      fio_buso        =>  buso         ,
      fio_busov       =>  busov        ,
      fio_busy        =>  busy         ,
      fio_gnt         =>  monfsm_gnt      ,
      fio_req         =>  monfsm_req      ,
      fio_busi        =>  monfsm_busi         ,
      fio_busiv       =>  monfsm_busiv        ,
      fio_ctrl        =>  monfsm_ctrl         ,
      file_size_byte        =>  file_size_byte     ,
      file_finished   =>  file_finished
    );

  file_info_processor_inst: file_info_processor
    port map(
      clk             =>  clk,
      reset           =>  reset,
      file_info_start      =>  file_info_start,
      file_info_ready      =>  file_info_ready,
      fio_buso        =>  buso,
      fio_busov       =>  busov,
      file_size_byte         =>  file_size_byte ,     -- NC
      lcdc_busy       =>  lcdc_busy,
      lcdc_cmd        =>  lcdc_cmd,
      lcdc_chrm_wdata =>  chrm_wdata,
      lcdc_chrm_waddr =>  chrm_addr,
      lcdc_chrm_wen   =>  chrm_wr
    );

-- Unassigned outputs are tied to zero
  ccrm_wdata  <= x"000000000";
  ccrm_addr   <= "00000";
  ccrm_wr     <= '0';
  hw_wr       <= '0';
  hw_din      <= x"00000000";
  dbuf_rst    <= '0';
  sbuf_rst    <= '0';
  dec_rst     <= '0';

end architecture playcontrol_arch;

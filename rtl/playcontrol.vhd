library ieee;
use ieee.std_logic_1164.all;
use work.system_constants_pkg.all;

entity playcontrol is
  port (
    clk         : in std_logic;               --clock signal
    reset       : in std_logic;               --asynchronous reset

    key_empty   : in  std_logic;
    key_rd      : out std_logic;
    key_rd_ack  : in  std_logic;
    key_data    : in  std_logic_vector(7 downto 0);

    ctrl    : out std_logic;
    busi    : out std_logic_vector(7 downto 0);
    busiv   : out std_logic;
    busy    : in  std_logic;
    busov   : in  std_logic;
    buso    : in  std_logic_vector(31 downto 0);

    chrm_wdata  : out std_logic_vector(7 downto 0);
    chrm_wr     : out std_logic;
    chrm_addr   : out std_logic_vector(7 downto 0);
    lcdc_cmd    : out std_logic_vector(1 downto 0);
    lcdc_busy   : in  std_logic;
    ccrm_wdata  : out std_logic_vector(35 downto 0);
    ccrm_addr   : out std_logic_vector(4 downto 0);
    ccrm_wr     : out std_logic;

    hw_full     : in  std_logic;
    hw_wr       : out std_logic;
    hw_din      : out std_logic_vector(31 downto 0);

    dbuf_almost_full : in  std_logic;
    dbuf_wr          : out std_logic;
    dbuf_din         : out std_logic_vector(31 downto 0);
    dbuf_rst         : out std_logic;

    sbuf_full   : in  std_logic;
    sbuf_empty  : in  std_logic;
    sbuf_rst    : out std_logic;

    dec_rst     : out std_logic;
    dec_status  : in  std_logic

    );
end playcontrol;

architecture playcontrol_arch of playcontrol is

  component kbc_intf is
    port(
      empty     : in  std_logic;
      rd_ack    : in  std_logic;
      data      : in  std_logic_vector(7 downto 0);
      rd        : out std_logic;
      listnext  : out std_logic;
      listprev  : out std_logic
    );
  end component;

  component arbiter_mux is
    port(
      clk     : in  std_logic;
      reset   : in  std_logic;
      bus_in  : in  std_logic_vector(3*10-1 downto 0);  -- 10-bit bus input from 3 Masters
      req     : in  std_logic_vector(2 downto 0);       -- request signal from 3 Masters
      gnt     : out std_logic_vector(2 downto 0);       -- grant signal to 3 Masters
      fio_bus : out std_logic_vector(9 downto 0)        -- 10-bit bus output to FIO
    );
  end component;

  component list_ctrl is
    port(
      clk         : in  std_logic;
      reset       : in  std_logic;
      listnext    : in  std_logic;
      listprev    : in  std_logic;
      gnt         : in  std_logic;
      busy        : in  std_logic;
      info_ready  : in  std_logic;
      req         : out std_logic;
      busi        : out std_logic_vector(7 downto 0);
      busiv       : out std_logic;
      ctrl        : out std_logic;
      info_start  : out std_logic
    );
  end component;

  component file_info_processor is
    port(
      clk             : in  std_logic;
      reset           : in  std_logic;
      info_start      : in  std_logic;
      info_ready      : out std_logic;
      fio_buso        : in  std_logic_vector(31 downto 0);
      fio_busov       : in  std_logic;
  --     file_size       : out file_size_reg;
      filesize        : out std_logic_vector(31 downto 0);

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
  signal listcrtl_req   : std_logic;
  signal listcrtl_gnt   : std_logic;
  signal listcrtl_ctrl  : std_logic;
  signal listcrtl_busiv : std_logic;
  signal listcrtl_busi  : std_logic_vector(7 downto 0);
--   signal nc             : std_logic_vector(7 downto 0);
  signal info_ready     : std_logic;
  signal info_start     : std_logic;
  signal arbiter_fio_req: std_logic_vector(2 downto 0);
  signal arbiter_fio_gnt: std_logic_vector(2 downto 0);
  signal arbiter_fio_bus_in : std_logic_vector(29 downto 0);
  signal arbiter_fio_bus_out : std_logic_vector(9 downto 0);

begin
  listcrtl_gnt <= arbiter_fio_gnt(2);
  ctrl <= arbiter_fio_bus_out(9);
  busiv <= arbiter_fio_bus_out(8);
  busi <= arbiter_fio_bus_out(7 downto 0);
  arbiter_fio_req <= listcrtl_req & '0' & '0';
  arbiter_fio_bus_in <= listcrtl_ctrl & listcrtl_busiv & listcrtl_busi &
                        "0000000000" &
                        "0000000000";

  kbc_intf_inst: kbc_intf
    port map(
      empty     =>  key_empty,
      rd_ack    =>  key_rd_ack,
      data      =>  key_data,
      rd        =>  key_rd,
      listnext  =>  listnext,
      listprev  =>  listprev
    );

  arbiter_mux_inst: arbiter_mux
    port map(
      clk     =>  clk,
      reset   =>  reset,
      bus_in  =>  arbiter_fio_bus_in, -- 10-bit bus input from 3 Masters
      req     =>  arbiter_fio_req,    -- request signal from 3 Masters
      gnt     =>  arbiter_fio_gnt,    -- grant signal to 3 Masters
      fio_bus =>  arbiter_fio_bus_out -- 10-bit bus output to FIO
    );

  list_ctrl_inst: list_ctrl
    port map(
      clk         =>  clk,
      reset       =>  reset,
      listnext    =>  listnext,
      listprev    =>  listprev,
      gnt         =>  listcrtl_gnt,
      busy        =>  busy,
      info_ready  =>  info_ready,
      req         =>  listcrtl_req,
      busi        =>  listcrtl_busi,
      busiv       =>  listcrtl_busiv,
      ctrl        =>  listcrtl_ctrl,
      info_start  =>  info_start
    );

  file_info_processor_inst: file_info_processor
    port map(
      clk             =>  clk,
      reset           =>  reset,
      info_start      =>  info_start,
      info_ready      =>  info_ready,
      fio_buso        =>  buso,
      fio_busov       =>  busov,
--       filesize        =>  (),     -- NC
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
  dbuf_wr     <= '0';
  dbuf_din    <= x"00000000";
  dbuf_rst    <= '0';
  sbuf_rst    <= '0';
  dec_rst     <= '0';

end architecture playcontrol_arch;

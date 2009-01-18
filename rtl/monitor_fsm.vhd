-------------------------------------------------------------------------------
-- Project                    : MP3 Player Controller
-- Entity                     : monitor_fsm
-- Entity description         : Fetches the MP3 data from the FIO to the
--                              decoder and monitors the condition of buffers
--
-- Author                     : AAK
-- Created on                 : 12 Jan, 2009
-- Last revision on           : 18 Jan, 2009
-- Last revision description  :
-- To do                      : Improve FSM to better handle PAUSE and STOP
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.system_constants_pkg.all;

entity monitor_fsm is
  port(
    clk             : in  std_logic;
    reset           : in  std_logic;

    play_fetch_en   : in  std_logic;
    file_size_byte  : in  std_logic_vector(31 downto 0);
    file_finished   : out std_logic;
    music_finished  : out std_logic;

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
    fio_ctrl        : out std_logic
  );
end entity;

architecture arch of monitor_fsm is
  type    state_type is (IDLE, PARAM, READ, FINISH);
  signal  state, next_state : state_type;
  signal  fetch_en          : std_logic;
  signal  param_done        : std_logic;
  signal  read_done         : std_logic;
  signal  fio_req_s         : std_logic;
  signal  file_finished_s   : std_logic;
  signal  music_finished_s  : std_logic;
  signal  file_size_dword   : std_logic_vector(31 downto 0);
  signal  total_dword_cnt   : std_logic_vector(31 downto 0);
  signal  fetch_num_dword   : std_logic_vector(31 downto 0);
  signal  this_dword_cnt    : std_logic_vector(8 downto 0);
  signal  fetch_param_dword : std_logic_vector(8 downto 0);
  constant FETCH_DWORD_MAX  : std_logic_vector(31 downto 0) := x"000000C8"; -- 256 in decimal

begin

-- Writing fetched MP3 data to DBUF
  dbuf_wdata <= fio_buso;
  dbuf_wr <= fio_busov when (state = READ) else '0';

-- FIO Bus signals
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_ctrl <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = PARAM) then
        fio_ctrl <= '0';
      else
        fio_ctrl <= '1';
      end if;
    end if;
  end process;
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_busi <= x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (state = PARAM) then
        fio_busi <= fetch_param_dword(7 downto 0);
      else
        fio_busi <= FIO_READ;
      end if;
    end if;
  end process;
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_busiv <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if ((state = PARAM or state = READ) and fio_req_s = '1' and fio_gnt = '1' and fio_busy = '0') then
--       if ((state = PARAM or state = READ) and (fio_gnt = '1')) then
        fio_busiv <= '1';
      else
        fio_busiv <= '0';
      end if;
    end if;
  end process;
  -- request generation
  fio_req <= fio_req_s;
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_req_s <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if ((state = IDLE and fetch_en = '1') or (state = PARAM and param_done = '1') or (state = READ and read_done = '1' and file_finished_s = '0' and fetch_en = '1')) then -- recent edit
        fio_req_s <= '1';
      elsif ((state = PARAM or state = READ) and fio_gnt = '1' and fio_busy = '0') then
        fio_req_s <= '0';
      end if;
    end if;
  end process;

-- param_done signal -- why FF
  process (clk, reset)
  begin
    if (reset = reset_state) then
      param_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = PARAM and fio_req_s = '0' and fio_gnt = '0' and fio_busy = '0') then
--       if (state = PARAM and fio_req_s = '0') then
        param_done <= '1';
      else
        param_done <= '0';
      end if;
    end if;
  end process;

-- read_done signal
  process (clk, reset)
  begin
    if (reset = reset_state) then
      read_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = READ and this_dword_cnt = fetch_num_dword and fio_req_s = '0' and fio_gnt = '0' and fio_busy = '0') then
--       if (state = READ and this_dword_cnt = fetch_num_dword) then
        read_done <= '1';
      else
        read_done <= '0';
      end if;
    end if;
  end process;

-- file_finished signal
  file_finished <= file_finished_s;
  process (clk, reset)
  begin
    if (reset = reset_state) then
      file_finished_s <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = READ and (total_dword_cnt+this_dword_cnt) = file_size_dword and fio_req_s = '0' and fio_gnt = '0' and fio_busy = '0') then
        file_finished_s <= '1';
      else
        file_finished_s <= '0';
      end if;
    end if;
  end process;

  music_finished_s <= sbuf_empty;
  music_finished <= music_finished_s;

  file_size_dword <= "00" & file_size_byte(31 downto 2);
  fetch_num_dword <= file_size_dword - total_dword_cnt when ((file_size_dword - total_dword_cnt) < FETCH_DWORD_MAX) else FETCH_DWORD_MAX;
  fetch_param_dword <= fetch_num_dword(8 downto 0) - 1;

-- File DWords counters
  process (clk, reset)
  begin
    if (reset = reset_state) then
      this_dword_cnt <= '0' & x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (state = READ and read_done = '1') then
        this_dword_cnt <= '0' & x"00";
      elsif (state = READ and fio_busov = '1') then
        this_dword_cnt <= this_dword_cnt + 1;
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      total_dword_cnt <= x"00000000";
    elsif (clk'event and clk = clk_polarity) then
      if (STATE = READ and file_finished_s = '1') then
        total_dword_cnt <= x"00000000";
      elsif (state = READ and read_done = '1') then
        total_dword_cnt <= total_dword_cnt + fetch_num_dword;
      end if;
    end if;
  end process;

-- FSM
  state_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      state <= IDLE;
    elsif (clk'event and clk = clk_polarity) then
      state <= next_state;
    end if;
  end process;

  fetch_en <= '1' when (play_fetch_en = '1' and dbuf_afull = '0') else '0';

  next_state_comb_logic: process (state, fetch_en, play_fetch_en, param_done, read_done, file_finished_s)
  begin
    case state is
      when IDLE =>
        if (fetch_en = '1') then
          next_state <= PARAM;
        else
          next_state <= IDLE;
        end if;
      when PARAM =>
        if (play_fetch_en = '0') then   -- If stop is asked
          next_state <= IDLE;
        elsif (param_done = '1') then
          next_state <= READ;
        else
          next_state <= PARAM;
        end if;
      when READ =>
        if (play_fetch_en = '0') then   -- If stop is asked
          next_state <= IDLE;
        elsif (file_finished_s = '1') then
          next_state <= FINISH;
        elsif (read_done = '1' and fetch_en = '0') then
          next_state <= IDLE;
        elsif (read_done = '1') then
          next_state <= PARAM;
        else
          next_state <= READ;
        end if;
      when FINISH =>
          next_state <= IDLE;
      when others =>
          next_state <= IDLE;
    end case;
  end process;

end architecture;

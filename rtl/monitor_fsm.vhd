-------------------------------------------------------------------------------
-- Project                    : MP3 Player Controller
-- Entity                     : monitor_fsm
-- Entity description         : Fetches the MP3 data from the FIO to the
--                              decoder and monitors the condition of buffers
--
-- Author                     : AAK
-- Created on                 : 12 Jan, 2009
-- Last revision on           : 18 Jan, 2009
-- Last revision description  : Improved handling of PAUSE and STOP
--                              Changes in few signal names also.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.system_constants_pkg.all;

entity monitor_fsm is
  port(
    clk             : in  std_logic;
    reset           : in  std_logic;

    seekfwd         : in std_logic;
    seekbkw         : in std_logic;

    fetch_en        : in  std_logic;
    file_size_byte  : in  std_logic_vector(31 downto 0);
    file_finished   : out std_logic;
    music_finished  : out std_logic;

    dbuf_afull      : in  std_logic;
    sbuf_full       : in  std_logic;
    sbuf_empty      : in  std_logic;
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
  type    state_type is (IDLE, READ_PARAM, READ_CMD, SEEK_CHECK, SEEK_PARAM, SEEK_CMD);
  signal  state, next_state : state_type;
  signal  dbuf_rd_en        : std_logic;
  signal  read_param_done   : std_logic;
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
  constant SEEK_KDWORD_MAX  : std_logic_vector(7 downto 0) := x"40";        -- 40k dwords
  signal  seek_num_kdword   : std_logic_vector(31 downto 0);
  signal  seek_param_kdword : std_logic_vector(7 downto 0);
  signal  seek_cmd_val      : std_logic_vector(7 downto 0);
  signal  seek_param_done   : std_logic;
  signal  seek_cmd_done     : std_logic;
  signal  seek_req          : std_logic;

begin

-------------------------------------------------------------------------------
-- Writing fetched MP3 data to DBUF
-------------------------------------------------------------------------------
  dbuf_wdata <= fio_buso;
  dbuf_wr <= fio_busov when (state = READ_CMD) else '0';


-------------------------------------------------------------------------------
-- FIO Bus signals
-------------------------------------------------------------------------------
  fio_req <= fio_req_s;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_ctrl <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = READ_PARAM or state = SEEK_PARAM) then
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
      if (state = READ_PARAM) then
        fio_busi <= fetch_param_dword(7 downto 0);
      elsif (state = SEEK_PARAM) then
        fio_busi <= seek_param_kdword(7 downto 0);
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
      if (  (state = READ_PARAM or state = READ_CMD or state = SEEK_PARAM or state = SEEK_CMD) and
            (fio_req_s = '1' and fio_gnt = '1' and fio_busy = '0') ) then
        fio_busiv <= '1';
      else
        fio_busiv <= '0';
      end if;
    end if;
  end process;

-- request generation
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_req_s <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (  (state = SEEK_CHECK) or
            (state = SEEK_PARAM and seek_param_done = '1') or
            (state = SEEK_CMD and seek_cmd_done = '1') or
            (state = READ_PARAM and read_param_done = '1')  ) then
        fio_req_s <= '1';
      elsif ( (state = READ_PARAM or state = READ_CMD or state = SEEK_PARAM or state = SEEK_CMD) and
              (fio_gnt = '1' and fio_busy = '0')  ) then
        fio_req_s <= '0';
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- State machine transition signals
-------------------------------------------------------------------------------
  dbuf_rd_en <= '1' when (fetch_en = '1' and dbuf_afull = '0') else '0';
  music_finished_s <= sbuf_empty;
  music_finished <= music_finished_s;
  file_finished <= file_finished_s;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      read_param_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = READ_PARAM and fio_req_s = '0' and fio_gnt = '0' and fio_busy = '0') then
        read_param_done <= '1';
      else
        read_param_done <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      seek_param_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = SEEK_PARAM and fio_req_s = '0' and fio_gnt = '0' and fio_busy = '0') then
        seek_param_done <= '1';
      else
        seek_param_done <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      seek_cmd_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = SEEK_CMD and fio_req_s = '0' and fio_gnt = '0' and fio_busy = '0') then
        seek_cmd_done <= '1';
      else
        seek_cmd_done <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      read_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = READ_CMD and this_dword_cnt = fetch_num_dword and fio_req_s = '0' and fio_gnt = '0' and fio_busy = '0') then
        read_done <= '1';
      else
        read_done <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      file_finished_s <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = READ_CMD and (total_dword_cnt+this_dword_cnt) = file_size_dword and fio_req_s = '0' and fio_gnt = '0' and fio_busy = '0') then
        file_finished_s <= '1';
      else
        file_finished_s <= '0';
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- File DWords counters
-------------------------------------------------------------------------------
  file_size_dword <= "00" & file_size_byte(31 downto 2);
  fetch_num_dword <= file_size_dword - total_dword_cnt when ((file_size_dword - total_dword_cnt) < FETCH_DWORD_MAX) else FETCH_DWORD_MAX;
  fetch_param_dword <= fetch_num_dword(8 downto 0) - 1;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      this_dword_cnt <= '0' & x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (fetch_en = '0') then -- if stop command
        this_dword_cnt <= '0' & x"00";
      elsif (state = READ_CMD and read_done = '1') then
        this_dword_cnt <= '0' & x"00";
      elsif (state = READ_CMD and fio_busov = '1') then
        this_dword_cnt <= this_dword_cnt + 1;
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      total_dword_cnt <= x"00000000";
    elsif (clk'event and clk = clk_polarity) then
      if (fetch_en = '0') then -- if stop command
        total_dword_cnt <= x"00000000";
      elsif (STATE = READ_CMD and file_finished_s = '1') then
        total_dword_cnt <= x"00000000";
      elsif (state = READ_CMD and read_done = '1') then
        total_dword_cnt <= total_dword_cnt + fetch_num_dword;
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- Seek implementation
-------------------------------------------------------------------------------
  seek_param_kdword <= SEEK_KDWORD_MAX - 1;  --seek_num_kdword(8 downto 0) - 1;

-- seek_req generation and latched seek command
  process (clk, reset)
  begin
    if (reset = reset_state) then
      seek_req <= '0';
      seek_cmd_val <= FIO_FFSEEK;
    elsif (clk'event and clk = clk_polarity) then
      if (seekfwd = '1') then
        seek_req <= '1';
        seek_cmd_val <= FIO_FFSEEK;
      elsif (seekbkw = '1') then
        seek_req <= '1';
        seek_cmd_val <= FIO_BFSEEK;
      elsif (STATE = READ_PARAM) then
        seek_req <= '0';
        seek_cmd_val <= FIO_FFSEEK;
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- FSM
-------------------------------------------------------------------------------
  state_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      state <= IDLE;
    elsif (clk'event and clk = clk_polarity) then
      state <= next_state;
    end if;
  end process;


  next_state_comb_logic: process (state, dbuf_rd_en, fetch_en, read_param_done, read_done, file_finished_s)
  begin
    case state is
      when IDLE =>
        if (file_finished_s = '1') then
          next_state <= IDLE;
        elsif (dbuf_rd_en = '1') then
          next_state <= SEEK_CHECK;
        else
          next_state <= IDLE;
        end if;
      when SEEK_CHECK =>
        if (seek_req = '1') then
          next_state <= SEEK_PARAM;
        else
          next_state <= READ_PARAM;
        end if;
      when READ_PARAM =>
        if (fetch_en = '0') then   -- If stop command
          next_state <= IDLE;
        elsif (read_param_done = '1') then
          next_state <= READ_CMD;
        else
          next_state <= READ_PARAM;
        end if;
      when READ_CMD =>
        if (fetch_en = '0') then   -- If stop command
          next_state <= IDLE;
        elsif (file_finished_s = '1') then
          next_state <= IDLE;
        elsif (read_done = '1' and dbuf_rd_en = '0') then
          next_state <= IDLE;
        elsif (read_done = '1' and dbuf_rd_en = '1') then
          next_state <= SEEK_CHECK;
        else
          next_state <= READ_CMD;
        end if;
      when SEEK_PARAM =>
        if (seek_param_done = '1') then
          next_state <= SEEK_CMD;
        else
          next_state <= SEEK_PARAM;
        end if;
      when SEEK_CMD =>
        if (seek_cmd_done = '1') then
          next_state <= READ_PARAM;
        else
          next_state <= READ_CMD;
        end if;
      when others =>
          next_state <= IDLE;
    end case;
  end process;

end architecture;

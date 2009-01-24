-------------------------------------------------------------------------------
-- Project                    : MP3 Player Controller
-- Entity                     : monitor_fsm
-- Entity description         : Fetches the MP3 data from the FIO to the
--                              decoder and monitors the condition of buffers
--
-- Author                     : AAK
-- Created on                 : 12 Jan, 2009
-- Last revision on           : 24 Jan, 2009
-- Last revision description  : Undid the last change in Monitor FSM design.
--                              Seek is now back to normal operation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.system_constants_pkg.all;
use work.test_modules_component_pkg.all;  -- contains chipsope core declarations

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
    decrst_onseek   : out std_logic;

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

    lcd_seek_status : out std_logic_vector(1 downto 0);

    to_chipscope    : in  std_logic_vector(255 downto 0)
  );
end entity;

architecture arch of monitor_fsm is
  type    state_type is (IDLE, READ_PARAM, READ_CMD, SEEK_CHECK, SEEK_PARAM, SEEK_CMD);
  signal  state, next_state : state_type;
  signal  dbuf_wdata_s      : std_logic_vector(31 downto 0);
  signal  dbuf_wr_s         : std_logic;
  signal  dbuf_wr_en        : std_logic;
  signal  read_param_done   : std_logic;
  signal  read_done         : std_logic;
  signal  fio_req_s         : std_logic;
  signal  fetch_en_r        : std_logic;
  signal  file_start_os     : std_logic;
  signal  file_finished_s   : std_logic;
  signal  music_finished_s  : std_logic;
  signal  file_size_dword   : std_logic_vector(31 downto 0);
  signal  total_dword_cnt   : std_logic_vector(31 downto 0);
  signal  remain_num_dword  : std_logic_vector(31 downto 0);
  signal  fetch_num_dword   : std_logic_vector(31 downto 0);
  signal  this_dword_cnt    : std_logic_vector(8 downto 0);
  signal  fetch_param_dword : std_logic_vector(8 downto 0);
  constant FETCH_DWORD_MAX  : std_logic_vector(31 downto 0) := x"00000100";   -- 256 words (0x100)
  constant SEEK_KDWORD_MAX  : std_logic_vector(7 downto 0)  := x"40";         -- 64 kilo-dwords (0x40)
  constant SEEK_DWORD_MAX   : std_logic_vector(31 downto 0) := "00"&x"000" & SEEK_KDWORD_MAX & "00"&x"00";
  signal  seek_cmd_val      : std_logic_vector(7 downto 0);
  signal  seek_param_done   : std_logic;
  signal  seek_cmd_done     : std_logic;
  signal  seek_req          : std_logic;
  signal  decrst_onseek_s   : std_logic;
  signal  fio_busiv_s       : std_logic;
  signal  fio_busi_s        : std_logic_vector(7 downto 0);
  signal  fio_ctrl_s        : std_logic;

-- Chipscope signals
  signal  trig0             : std_logic_vector(255 downto 0);
  signal  control0          : std_logic_vector(35 downto 0);

begin

-------------------------------------------------------------------------------
-- Writing fetched MP3 data to DBUF
-------------------------------------------------------------------------------
  dbuf_wdata_s <= fio_buso;
  dbuf_wdata <= dbuf_wdata_s;
  dbuf_wr_s <= fio_busov when (state = READ_CMD) else '0';
  dbuf_wr <= dbuf_wr_s;


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
        fio_busi <= SEEK_KDWORD_MAX - 1;
      elsif (state = SEEK_CMD) then
        fio_busi <= seek_cmd_val;
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
      if (  (state = SEEK_CHECK and next_state = READ_PARAM) or
            (state = READ_PARAM and next_state = READ_CMD) or
            (state = SEEK_CHECK and next_state = SEEK_PARAM) or
            (state = SEEK_PARAM and next_state = SEEK_CMD) or
            (state = SEEK_CMD and next_state = READ_PARAM)  ) then
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
  dbuf_wr_en <= '1' when (fetch_en = '1' and dbuf_afull = '0') else '0';
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
      if (state = READ_CMD and (total_dword_cnt+this_dword_cnt) >= file_size_dword and fio_req_s = '0' and fio_gnt = '0' and fio_busy = '0') then
        file_finished_s <= '1';
      else
        file_finished_s <= '0';
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- File DWords counters
-------------------------------------------------------------------------------
  remain_num_dword <= (file_size_dword - total_dword_cnt) when (file_size_dword > total_dword_cnt) else x"00000000"; -- saturation subtractor
  fetch_num_dword <= remain_num_dword when (remain_num_dword < FETCH_DWORD_MAX) else FETCH_DWORD_MAX;
  fetch_param_dword <= fetch_num_dword(8 downto 0) - 1 when (fetch_num_dword(8 downto 0) /= ('0'&x"00")) else ('0'&x"00");

-- Rising edge detector for fetch_en to latch current file size
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fetch_en_r <= '0';
      file_start_os <= '0';
    elsif (clk'event and clk = clk_polarity) then
      fetch_en_r <= fetch_en;
      file_start_os <= fetch_en and not fetch_en_r;
    end if;
  end process;

-- Latching current file size
  process (clk, reset)
  begin
    if (reset = reset_state) then
      file_size_dword <= x"00000000";
    elsif (clk'event and clk = clk_polarity) then
      if (file_start_os = '1') then
        file_size_dword <= "00" & file_size_byte(31 downto 2);
      end if;
    end if;
  end process;

-- Current fetch counter
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

-- Total fetch counter
  process (clk, reset)
  begin
    if (reset = reset_state) then
      total_dword_cnt <= x"00000000";
    elsif (clk'event and clk = clk_polarity) then
      if (fetch_en = '0') then -- if stop command
        total_dword_cnt <= x"00000000";
      elsif (state = READ_CMD and file_finished_s = '1') then
        total_dword_cnt <= x"00000000";
      elsif (state = SEEK_CMD  and seek_cmd_val = FIO_FFSEEK and seek_cmd_done = '1') then  -- if seekfwd operation was performed
        total_dword_cnt <= total_dword_cnt + SEEK_DWORD_MAX;                                  -- add the seek amount
      elsif (state = SEEK_CMD  and seek_cmd_val = FIO_BFSEEK and seek_cmd_done = '1') then  -- if seekbkw operation was performed
        total_dword_cnt <= total_dword_cnt - SEEK_DWORD_MAX;                                  -- subtract the seek amount
      elsif (state = READ_CMD and read_done = '1') then
        total_dword_cnt <= total_dword_cnt + fetch_num_dword;
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- Seek implementation
-------------------------------------------------------------------------------
  lcd_seek_status <= "01" when (seek_req = '1' and (seek_cmd_val = FIO_FFSEEK and remain_num_dword > SEEK_DWORD_MAX) ) else   -- if enough leg room to seek-fwd
                     "10" when (seek_req = '1' and (seek_cmd_val = FIO_BFSEEK and total_dword_cnt > SEEK_DWORD_MAX) ) else    -- if enough head room to seek-bkw
                     "00"; -- IDLE state

-- seek_req generation and latched seek command
  process (clk, reset)
  begin
    if (reset = reset_state) then
      seek_req <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (fetch_en = '0') then  -- if stop command
        seek_req <= '0';
      elsif (seekfwd = '1' or seekbkw = '1') then
        seek_req <= '1';
      elsif ( (state = SEEK_CHECK and next_state = READ_PARAM) or
              (state = SEEK_CMD and next_state = READ_PARAM)  ) then
        seek_req <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      seek_cmd_val <= FIO_FFSEEK;
    elsif (clk'event and clk = clk_polarity) then
      if (seekfwd = '1') then
        seek_cmd_val <= FIO_FFSEEK;
      elsif (seekbkw = '1') then
        seek_cmd_val <= FIO_BFSEEK;
      end if;
    end if;
  end process;

  decrst_onseek <= decrst_onseek_s;
  process (clk, reset)
  begin
    if (reset = reset_state) then
      decrst_onseek_s <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = SEEK_CMD and seek_cmd_done = '1') then
        decrst_onseek_s <= '1';
      else
        decrst_onseek_s <= '0';
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

  next_state_comb_logic: process (state, dbuf_wr_en, fetch_en, read_param_done, read_done,
                                  file_finished_s, remain_num_dword, total_dword_cnt,
                                  seek_req, seek_param_done, seek_cmd_done, seek_cmd_val)
  begin
    case state is
      when IDLE =>
        if (file_finished_s = '1') then
          next_state <= IDLE;
        elsif (dbuf_wr_en = '1') then
          next_state <= SEEK_CHECK;
        else
          next_state <= IDLE;
        end if;
      when SEEK_CHECK =>
        if (fetch_en = '0') then   -- if stop command
          next_state <= IDLE;
        elsif ( seek_req = '1' and
                ( (seek_cmd_val = FIO_FFSEEK and remain_num_dword > SEEK_DWORD_MAX) or        -- if enough leg room to seek-fwd
                  (seek_cmd_val = FIO_BFSEEK and total_dword_cnt > SEEK_DWORD_MAX)  ) ) then  -- if enough head room to seek-bkw
          next_state <= SEEK_PARAM;
        elsif (dbuf_wr_en = '1') then
          next_state <= READ_PARAM;
        else
          next_state <= SEEK_CHECK;
        end if;
      when READ_PARAM =>
        if (fetch_en = '0') then   -- if stop command
          next_state <= IDLE;
        elsif (read_param_done = '1') then
          next_state <= READ_CMD;
        else
          next_state <= READ_PARAM;
        end if;
      when READ_CMD =>
        if (fetch_en = '0') then   -- if stop command
          next_state <= IDLE;
        elsif (file_finished_s = '1') then
          next_state <= IDLE;
        elsif (read_done = '1') then
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
          next_state <= SEEK_CMD;
        end if;
      when others =>
          next_state <= IDLE;
    end case;
  end process;


-------------------------------------------------------------------------------
-- Chipscope cores
-------------------------------------------------------------------------------
  chipsope_cores: if USECHIPSCOPE generate
    chipsope_icon: icon
      port map(
        control0 => control0
      );

    chipsope_ila: ila
      port map(
        control => control0,
        clk     => clk,
        trig0   => trig0
      );
  end generate;

    trig0(219 downto 0)   <= to_chipscope(219 downto 0);
    trig0(255 downto 252) <= seek_param_done & seek_cmd_done & dbuf_wr_en & file_start_os;
    trig0(249 downto 248) <= read_param_done & read_done;

--     trig0(151 downto 120) <= file_size_dword;
--     trig0(183 downto 152) <= total_dword_cnt;
--     trig0(236 downto 228) <= this_dword_cnt;
--     trig0(247 downto 240) <= fetch_param_dword(7 downto 0);


end architecture;

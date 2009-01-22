-------------------------------------------------------------------------------
-- Project                    : MP3 Player Controller
-- Entity                     : play_fsm
-- Entity description         : Takes commands from keypad and supervises the
--                              play process. Also controls monitor_fsm
--
-- Author                     : AAK
-- Created on                 : 12 Jan, 2009
-- Last revision on           : 18 Jan, 2009
-- Last revision description  : Play-Pause-Stop logic imporved and tested in
--                              hardware. Better interaction with monitor_fsm.
--                              Changes in few signal names also.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.system_constants_pkg.all;

entity play_fsm is
  port(
    clk             : in  std_logic;
    reset           : in  std_logic;

    play            : in  std_logic;
    pause           : in  std_logic;
    stop            : in  std_logic;
    mute            : in  std_logic;
    volinc          : in  std_logic;
    voldec          : in  std_logic;

    dec_status      : in  std_logic;
    dec_rst         : out std_logic;
    dbuf_rst        : out std_logic;
    sbuf_rst        : out std_logic;

    hw_full         : in  std_logic;
    hw_wr           : out std_logic;
    hw_din          : out std_logic_vector(31 downto 0);

    fio_busy        : in  std_logic;
    fio_gnt         : in  std_logic;
    fio_req         : out std_logic;
    fio_busi        : out std_logic_vector(7 downto 0);
    fio_busiv       : out std_logic;
    fio_ctrl        : out std_logic;

    decrst_onseek   : in  std_logic;
    file_finished   : in  std_logic;
    music_finished  : in  std_logic;
    fetch_en        : out std_logic
  );
end entity;

architecture arch of play_fsm is
  type    state_type is (IDLE, OPEN_ST, DEC_RESET, PLAY_ST, PAUSE_ST, STOP_ST);
  signal  state, next_state: state_type;
  signal  open_done     : std_logic;
  signal  dec_status_r  : std_logic;
  signal  dec_status_fall  : std_logic;
  signal  dec_rst_done  : std_logic;
  signal  stopping      : std_logic;
  signal  fio_req_s     : std_logic;
  signal  mute_state    : std_logic;
  signal  vol_state     : std_logic_vector(4 downto 0);
  signal  volinc_r      : std_logic;
  signal  voldec_r      : std_logic;
  signal  mute_r        : std_logic;

begin

-- FIO Bus signals
  fio_ctrl <= '1';
  fio_busi <= FIO_OPEN;
  -- Bus valid signal
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_busiv <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = OPEN_ST and fio_req_s = '1' and fio_gnt = '1' and fio_busy = '0') then
        fio_busiv <= '1';
      else
        fio_busiv <= '0';
      end if;
    end if;
  end process;
  -- Bus request generation
  fio_req <= fio_req_s;
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_req_s <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = IDLE and play = '1') then
        fio_req_s <= '1';
      elsif (state = OPEN_ST and fio_gnt = '1' and fio_busy = '0') then
        fio_req_s <= '0';
      end if;
    end if;
  end process;

-- open_done signal
  process (clk, reset)
  begin
    if (reset = reset_state) then
      open_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = OPEN_ST and fio_req_s = '0' and fio_gnt = '0' and fio_busy = '0') then
        open_done <= '1';
      else
        open_done <= '0';
      end if;
    end if;
  end process;

-- Resetting logic for Decoder and Buffers
  -- Falling edge detector for dec_status
  process (clk, reset)
  begin
    if (reset = reset_state) then
      dec_status_r <= '0';
    elsif (clk'event and clk = clk_polarity) then
      dec_status_r <= dec_status;
    end if;
  end process;
  process (clk, reset)
  begin
    if (reset = reset_state) then
      dec_status_fall <= '0';
    elsif (clk'event and clk = clk_polarity) then
      dec_status_fall <= not dec_status and dec_status_r;
    end if;
  end process;
  -- Resetting the decoder
  process (clk, reset)
  begin
    if (reset = reset_state) then
      dec_rst   <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = OPEN_ST and open_done = '1') then
        dec_rst <= '1';
      elsif (state = STOP_ST) then
        dec_rst <= '1';
      elsif (decrst_onseek = '1') then  -- recent edit
        dec_rst <= '1';
      else
        dec_rst <= '0';
      end if;
    end if;
  end process;
  -- Resetting the buffers
  process (clk, reset)
  begin
    if (reset = reset_state) then
      dbuf_rst <= '0';
      sbuf_rst <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = OPEN_ST and open_done = '1') then
        dbuf_rst <= '1';
        sbuf_rst <= '1';
      elsif (state = STOP_ST) then
        dbuf_rst <= '1';
        sbuf_rst <= '1';
      elsif (decrst_onseek = '1') then                          -- recent edit
        dbuf_rst <= decrst_onseek;
        sbuf_rst <= decrst_onseek;
      elsif (state = DEC_RESET and dec_status_fall = '1') then  -- recent edit
        dbuf_rst <= '1';
        sbuf_rst <= '1';
      else                                                      -- recent edit
        dbuf_rst <= '0';
        sbuf_rst <= '0';
      end if;
    end if;
  end process;

-- dec_rst_done signal
  process (clk, reset)
  begin
    if (reset = reset_state) then
      dec_rst_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      dec_rst_done <= dec_status_fall;
--       if (state = DEC_RESET and dec_status_fall = '1') then
--         dec_rst_done <= '1';
--       else
--         dec_rst_done <= '0';
--       end if;
    end if;
  end process;

-- Data Fetch enable when in play or pause state
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fetch_en <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = PLAY_ST or state = PAUSE_ST) then
        fetch_en <= '1';
      else
        fetch_en <= '0';
      end if;
    end if;
  end process;

-- stopping signal
  process (clk, reset)
  begin
    if (reset = reset_state) then
      stopping <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = STOP_ST) then
        stopping <= '1';
      elsif (state = DEC_RESET and stopping = '1' and dec_rst_done = '0') then
        stopping <= '1';
      else
        stopping <= '0';
      end if;
    end if;
  end process;

-- Play/Pause and Change Volume command to AC97
  hw_din(27 downto 0) <= x"000" & mute_state & "00" & vol_state & "000" & vol_state;
  process (clk, reset)
  begin
    if (reset = reset_state) then
      hw_din(31 downto 28) <= x"0";
      hw_wr <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (  ( (state = PLAY_ST and pause = '1') or
              (state = PAUSE_ST and play = '1') or
              (state = PAUSE_ST and stop = '1')   ) and hw_full = '0' ) then  -- play/pause toggle
        hw_din(31 downto 28) <= AC97_PAUSE;
        hw_wr <= '1';
      elsif ((volinc_r = '1' or voldec_r = '1' or mute_r = '1') and hw_full = '0') then   -- Volume change command
        hw_din(31 downto 28) <= AC97_CHANGE_VOL;
        hw_wr <= '1';
      else
        hw_din(31 downto 28) <= x"0";
        hw_wr <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      volinc_r <= '0';
      voldec_r <= '0';
      mute_r <= '0';
    elsif (clk'event and clk = clk_polarity) then
      volinc_r <= volinc;
      voldec_r <= voldec;
      mute_r <= mute;
    end if;
  end process;

-- Toggle mute state
  process (clk, reset)
  begin
    if (reset = reset_state) then
      mute_state <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (mute = '1') then
        mute_state <= not mute_state;
      end if;
    end if;
  end process;

-- Change volume state with max/min saturation
  process (clk, reset)
  begin
    if (reset = reset_state) then
      vol_state <= AC97_VOL_MAX;
    elsif (clk'event and clk = clk_polarity) then
      if (volinc = '1' and vol_state /= AC97_VOL_MAX) then
        vol_state <= vol_state - 1;
      elsif (voldec = '1' and vol_state /= AC97_VOL_MIN) then
        vol_state <= vol_state + 1;
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

  next_state_comb_logic: process (state, play, pause, stop, open_done, dec_rst_done, file_finished, stopping)
  begin
    case state is
      when IDLE =>
        if (play = '1') then
          next_state <= OPEN_ST;
        else
          next_state <= IDLE;
        end if;
      when OPEN_ST =>
        if (open_done = '1') then
          next_state <= DEC_RESET;
        else
          next_state <= OPEN_ST;
        end if;
      when DEC_RESET =>
        if (dec_rst_done = '1' and stopping = '1') then
          next_state <= IDLE;
        elsif (dec_rst_done = '1') then
          next_state <= PLAY_ST;
        else
          next_state <= DEC_RESET;
        end if;
      when PLAY_ST =>
        if (file_finished = '1') then
          next_state <= IDLE;
        elsif (pause = '1') then
          next_state <= PAUSE_ST;
        elsif (stop = '1') then
          next_state <= STOP_ST;
        else
          next_state <= PLAY_ST;
        end if;
      when PAUSE_ST =>
        if (play = '1') then
          next_state <= PLAY_ST;
        elsif (stop = '1') then
          next_state <= STOP_ST;
        else
          next_state <= PAUSE_ST;
        end if;
      when STOP_ST =>
          next_state <= DEC_RESET;
      when others =>
          next_state <= IDLE;
    end case;
  end process;

end architecture;

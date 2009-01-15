library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.system_constants_pkg.all;

entity play_fsm is
  port(
    clk           : in  std_logic;
    reset         : in  std_logic;

    play          : in  std_logic;
    pause         : in  std_logic;
    stop          : in  std_logic;
    mute          : in  std_logic;
    volinc        : in  std_logic;
    voldec        : in  std_logic;

    dec_status    : in  std_logic;
    dec_rst       : out std_logic;
    dbuf_rst      : out std_logic;
    sbuf_rst      : out std_logic;

    hw_full       : in  std_logic;
    hw_wr         : out std_logic;
    hw_din        : out std_logic_vector(31 downto 0);

    fio_busy      : in  std_logic;
    fio_gnt       : in  std_logic;
    fio_req       : out std_logic;
    fio_busi      : out std_logic_vector(7 downto 0);
    fio_busiv     : out std_logic;
    fio_ctrl      : out std_logic;

    play_en       : out std_logic;
    file_finished : in  std_logic
  );
end entity;

architecture arch of play_fsm is
  type    state_type is (STOP_ST, OPEN_ST, PLAY_ST, PAUSE_ST);
  signal  state, next_state: state_type;
  signal  open_done   : std_logic;
  signal  fio_req_s   : std_logic;
  signal  mute_state  : std_logic;
  signal  vol_state   : std_logic_vector(4 downto 0);

begin
  fio_ctrl <= '1';
  fio_busi <= FIO_OPEN;
  fio_busiv <= fio_gnt and (not fio_busy);
  fio_req <= fio_req_s;

-- request generation
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_req_s <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = STOP_ST and play = '1') then
        fio_req_s <= '1';
      elsif (state = OPEN_ST and fio_gnt = '1' and fio_busy = '0') then
        fio_req_s <= '0';
      end if;
    end if;
  end process;

-- Resetting the decoder
  process (clk, reset)
  begin
    if (reset = reset_state) then
      dec_rst   <= '0';
      dbuf_rst  <= '0';
      sbuf_rst  <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = STOP_ST and play = '1') then
        dec_rst   <= '1';
        dbuf_rst  <= '1';
        sbuf_rst  <= '1';
      elsif (state = OPEN_ST and dec_status = '0') then
        dec_rst   <= '0';
        dbuf_rst  <= '0';
        sbuf_rst  <= '0';
      end if;
    end if;
  end process;

-- open_done signal
  process (clk, reset)
  begin
    if (reset = reset_state) then
      open_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = OPEN_ST and dec_status = '0' and fio_req_s = '0') then
        open_done <= '1';
--       elsif (next_state = PLAY_ST and dec_status = '0' and fio_req_s = '0') then
--         open_done <= '0';
      else
        open_done <= '0';
      end if;
    end if;
  end process;

-- Data Fetch enable when in play/pause state
  play_en <= '1' when ((state = PLAY_ST) or (state = PAUSE_ST)) else '0';

-- Play/Pause and Change Volume command to AC97
  process (clk, reset)
  begin
    if (reset = reset_state) then
      hw_din <= x"00000000";
      hw_wr <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if ( ((state = PLAY_ST and pause = '1') or      -- play/pause toggle
            (state = PAUSE_ST and play = '1'))
           and hw_full = '0') then
        hw_din <= AC97_PAUSE & x"0000000";
        hw_wr <= '1';
      elsif (mute = '1' and hw_full = '0') then     -- mute/unmute toggle
        hw_din <= AC97_CHANGE_VOL & x"000" & (not mute_state) & "000" & x"000";
        hw_wr <= '1';
      elsif (volinc = '1' and hw_full = '0') then   -- Increase Volume
        hw_din <= AC97_CHANGE_VOL & x"000" & mute_state & "00" & (vol_state+1) & "000" & (vol_state+1);
        hw_wr <= '1';
      elsif (voldec = '1' and hw_full = '0') then   -- Decrease Volume
        hw_din <= AC97_CHANGE_VOL & x"000" & mute_state & "00" & (vol_state-1) & "000" & (vol_state-1);
        hw_wr <= '1';
      else
        hw_din <= x"00000000";
        hw_wr <= '0';
      end if;
    end if;
  end process;

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

  process (clk, reset)
  begin
    if (reset = reset_state) then
      vol_state <= AC97_VOL_MAX;
    elsif (clk'event and clk = clk_polarity) then
      if (volinc = '1') then
        vol_state <= vol_state - '1';
      elsif (voldec = '1') then
        vol_state <= vol_state + '1';
      end if;
    end if;
  end process;



  state_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      state <= STOP_ST;
    elsif (clk'event and clk = clk_polarity) then
      state <= next_state;
    end if;
  end process;

  next_state_comb_logic: process (state, stop, play, pause, open_done, file_finished)
  begin
    case state is
      when STOP_ST =>
        if (play = '1') then
          next_state <= OPEN_ST;
        else
          next_state <= STOP_ST;
        end if;
      when OPEN_ST =>
        if (open_done = '1') then
          next_state <= PLAY_ST;
        else
          next_state <= OPEN_ST;
        end if;
      when PLAY_ST =>
        if (stop = '1' or file_finished = '1') then
          next_state <= STOP_ST;
        elsif (pause = '1') then
          next_state <= PAUSE_ST;
        else
          next_state <= PLAY_ST;
        end if;
      when PAUSE_ST =>
        if (stop = '1') then
          next_state <= STOP_ST;
        elsif (play = '1') then
          next_state <= PLAY_ST;
        else
          next_state <= PAUSE_ST;
        end if;
      when others =>
          next_state <= STOP_ST;
    end case;
  end process;




end architecture;

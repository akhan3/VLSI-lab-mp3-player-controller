library ieee;
use ieee.std_logic_1164.all;
use work.system_constants_pkg.all;

entity play_ctrl is
  port(
    clk         : in  std_logic;
    reset       : in  std_logic;
    key_play    : in  std_logic;
    key_stop    : in  std_logic;
    key_pause   : in  std_logic;
    gnt         : in  std_logic;
    fio_busy    : in  std_logic;
    file_finished:in  std_logic;
    req         : out std_logic;
    fio_busi    : out std_logic_vector(7 downto 0);
    fio_busiv   : out std_logic;
    fio_ctrl    : out std_logic
  );
end entity;

architecture arch of play_ctrl is
  type state_type is (STOP, PLAY, PAUSE);
  signal state, next_state: state_type;
  signal busi_le : std_logic;
begin

  state_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      state <= STOP;
    elsif (clk'event and clk = clk_polarity) then
      state <= next_state;
    end if;
  end process;

  next_state_comb_logic: process (state, key_stop, key_play, key_pause, gnt, fio_busy)
  begin
    case state is
      when STOP =>
        if (key_play = '1') then
          next_state <= PLAY;
        else
          next_state <= STOP;
        end if;
      when PLAY =>
        if (key_stop = '1' or file_finished = '1') then
          next_state <= STOP;
        elsif (key_pause = '1') then
          next_state <= PAUSE;
        else
          next_state <= PLAY;
        end if;
      when PAUSE =>
        if (key_stop = '1') then
          next_state <= STOP;
        elsif (key_play = '1') then
          next_state <= PLAY;
        else
          next_state <= PAUSE;
        end if;
      when others =>
          next_state <= STOP;
    end case;
  end process;

  output_comb_logic: process (state, key_stop, key_play, key_pause, gnt, fio_busy)
  begin
    req <= '0';
    busi_le <= '0';
    fio_busiv <= '0';
    fio_ctrl <= '0';
    case state is
      when STOP =>
        if (listnext = '1' or listprev = '1') then
          busi_le <= '1';
          req <= '1';
        end if;
      when PLAY =>
        req <= '1';
        if (gnt = '1' and busy = '0') then
          fio_busiv <= '1';
          fio_ctrl <= '1';
        end if;
      when PAUSE =>
        if (info_ready = '1') then
        else
          req <= '1';
        end if;
    end case;
  end process;

  busi_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_busi <= x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (busi_le = '1') then
        if (listnext = '1') then
          fio_busi <= FIO_FILENEXT;
        elsif (listprev = '1') then
          fio_busi <= FIO_FILEPREV;
        end if;
      end if;
    end if;
  end process;

end architecture;

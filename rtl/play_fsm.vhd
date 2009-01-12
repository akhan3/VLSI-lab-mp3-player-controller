library ieee;
use ieee.std_logic_1164.all;
use work.system_constants_pkg.all;

entity play_fsm is
  port(
    clk         : in  std_logic;
    reset       : in  std_logic;
    play    : in  std_logic;
    pause   : in  std_logic;
    stop    : in  std_logic;
    file_finished:in  std_logic;
    fio_busy    : in  std_logic;
    fio_gnt         : in  std_logic;
    fio_req         : out std_logic;
    fio_busi    : out std_logic_vector(7 downto 0);
    fio_busiv   : out std_logic;
    fio_ctrl    : out std_logic;
    play_en     : out std_logic
  );
end entity;

architecture arch of play_fsm is
  type state_type is (STOPS, PLAYS, PAUSES);
  signal state, next_state: state_type;
  signal open_start: std_logic;
  signal play_start: std_logic;
  signal stop_start: std_logic;
  signal pause_start: std_logic;
  signal open_done: std_logic;
  signal play_done: std_logic;
  signal stop_done: std_logic;
  signal pause_done: std_logic;
begin

  fio_ctrl <= '1';
  fio_busi <= FIO_OPEN;

  state_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      state <= STOPS;
    elsif (clk'event and clk = clk_polarity) then
      state <= next_state;
    end if;
  end process;

  next_state_comb_logic: process (state, stop, play, pause, fio_gnt, fio_busy, file_finished)
  begin
    case state is
      when STOPS =>
        if (play = '1') then
          next_state <= PLAYS;
        else
          next_state <= STOPS;
        end if;
      when PLAYS =>
        if (stop = '1' or file_finished = '1') then
          next_state <= STOPS;
        elsif (pause = '1') then
          next_state <= PAUSES;
        else
          next_state <= PLAYS;
        end if;
      when PAUSES =>
        if (stop = '1') then
          next_state <= STOPS;
        elsif (play = '1') then
          next_state <= PLAYS;
        else
          next_state <= PAUSES;
        end if;
      when others =>
          next_state <= STOPS;
    end case;
  end process;

  output_comb_logic: process (state, stop, play, pause, fio_gnt, fio_busy, file_finished)
  begin
    open_start <= '0';
    stop_start <= '0';
    pause_start <= '0';
    play_en <= '0';
    case state is
      when STOPS =>
        if (play = '1') then
          open_start <= '1';
        end if;
      when PLAYS =>
        play_en <= '1';
        if (stop = '1' or file_finished = '1') then
          stop_start <= '1';
        elsif (pause = '1') then
          pause_start <= '1';
        else
          play_start <= '1';
        end if;
      when PAUSES =>
        if (stop = '1') then
          stop_start <= '1';
        elsif (play = '1') then
          play_start <= '1';
        else
          pause_start <= '1';
        end if;
    end case;
  end process;

-- request generation
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_req <= '0';
    elsif (clk'event and clk = clk_polarity) then
--       if (state = STOPS and open_start = '1') then
      if (state = STOPS and next_state = PLAYS) then
        fio_req <= '1';
      elsif (state = PLAYS and fio_gnt = '1' and fio_busy = '0') then
        fio_req <= '0';
      end if;
    end if;
  end process;

-- open_done signal
  process (clk, reset)
  begin
    if (reset = reset_state) then
      open_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (state = PLAYS and fio_gnt = '1' and fio_busy = '0') then
        open_done <= '1';
      elsif (state /= PLAYS) then
        open_done <= '0';
      end if;
    end if;
  end process;

  fio_busiv <= fio_gnt and (not fio_busy);

end architecture;

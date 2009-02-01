-------------------------------------------------------------------------------
-- PLAY FSM
-------------------------------------------------------------------------------
  state_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      state <= IDLE;
    elsif (clk'event and clk = clk_polarity) then
      state <= next_state;
    end if;
  end process;

  next_state_comb_logic: process (state, play, pause, stop, open_done, dec_rst_done,
                                  file_finished, music_finished, stopping)
  begin
    case state is

      when IDLE =>
        if (play = '1' and music_finished = '1') then   -- ensure previous file is still not playing
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

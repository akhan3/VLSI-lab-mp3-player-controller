-------------------------------------------------------------------------------
-- MONITOR FSM
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

-------------------------------------------------------------------------------
-- Project                    : MP3 Player Controller
-- Entity                     : lcd_ctrl
-- Entity description         : Display controller. Writes to LCD and updates
--                              the display on certain events and for scrolling
--
-- Author                     : AAK
-- Created on                 : 23 Jan, 2009
-- Last revision on           : 23 Jan, 2009
-- Last revision description  :
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- use std.textio.all;
use work.system_constants_pkg.all;

entity display_ctrl is
  port(
    clk                 : in  std_logic;
    reset               : in  std_logic;

    lcd_playing_status  : in  std_logic_vector(2 downto 0);
    lcd_vol_status      : in  std_logic_vector(4 downto 0);
    lcd_mute_status     : in  std_logic;

    lcd_seek_status     : in  std_logic_vector(1 downto 0);

    lcd_filename_valid  : in  std_logic;
    lcd_filename        : in  std_logic_vector(8*12-1 downto 0);

    startup             : in  std_logic;

    lcdc_busy           : in  std_logic;
    lcdc_cmd            : out std_logic_vector(1 downto 0);
    chrm_wr             : out std_logic;
    chrm_wdata          : out std_logic_vector(7 downto 0);
    chrm_addr           : out std_logic_vector(7 downto 0);
    ccrm_wdata          : out std_logic_vector(35 downto 0);
    ccrm_addr           : out std_logic_vector(4 downto 0);
    ccrm_wr             : out std_logic
  );
end entity;

architecture arch of display_ctrl is
  constant SPACE_CHAR           : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(character'pos(' '), 8));
  signal  lcd_playing_status_r  : std_logic_vector(2 downto 0);
  signal  lcd_vol_status_r      : std_logic_vector(4 downto 0);
  signal  lcd_mute_status_r     : std_logic;
  signal  lcd_seek_status_r     : std_logic_vector(1 downto 0);
  signal  lcd_filename_valid_r  : std_logic;
  signal  lcd_playing_event     : std_logic;
  signal  lcd_vol_event         : std_logic;
  signal  lcd_mute_event        : std_logic;
  signal  lcd_seek_event        : std_logic;
  signal  lcd_filename_event    : std_logic;
  signal  update_event          : std_logic;

-- signals for startup writing
  signal  startup_fill_chmem : std_logic;
  signal  st_chram_addr      : std_logic_vector(8 downto 0);
  signal  st_chram_data      : std_logic_vector(7 downto 0);
  signal  st_chram_wr        : std_logic;

-- signals for file name display
  signal  fn_chram_addr      : std_logic_vector(7 downto 0);
  signal  fn_chram_data      : std_logic_vector(7 downto 0);
  signal  fn_chram_wr        : std_logic;
  signal  fn_lcd_counter     : std_logic_vector(3 downto 0);
  signal  fn_lcd_counter_reg : std_logic_vector(3 downto 0);
  signal  fn_lcdc_command    : std_logic_vector(1 downto 0);
  signal  fn_wr_done         : std_logic;

begin

-------------------------------------------------------------------------------
-- Detecting events to update LCD
-------------------------------------------------------------------------------
-- registered versions of status signals
  process (clk, reset)
  begin
    if (reset = reset_state) then
      lcd_playing_status_r  <= "000";
      lcd_vol_status_r      <= "00000";
      lcd_mute_status_r     <= '0';
      lcd_seek_status_r     <= "00";
      lcd_filename_valid_r  <= '0';
    elsif (clk'event and clk = clk_polarity) then
      lcd_playing_status_r  <= lcd_playing_status_r;
      lcd_vol_status_r      <= lcd_vol_status_r;
      lcd_mute_status_r     <= lcd_mute_status_r;
      lcd_seek_status_r     <= lcd_seek_status_r;
      lcd_filename_valid_r  <= lcd_filename_valid_r;
    end if;
  end process;

-- creating separate events when signals change
  process (clk, reset)
  begin
    if (reset = reset_state) then
      lcd_playing_event   <= '0';
      lcd_vol_event       <= '0';
      lcd_mute_event      <= '0';
      lcd_seek_event      <= '0';
      lcd_filename_event  <= '0';
      update_event        <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (lcd_playing_status /= lcd_playing_status_r) then lcd_playing_event   <= '1'; else  lcd_playing_event   <= '0'; end if;
      if (lcd_vol_status     /= lcd_vol_status_r    ) then lcd_vol_event       <= '1'; else  lcd_vol_event       <= '0'; end if;
      if (lcd_mute_status    /= lcd_mute_status_r   ) then lcd_mute_event      <= '1'; else  lcd_mute_event      <= '0'; end if;
      if (lcd_seek_status    /= lcd_seek_status_r   ) then lcd_seek_event      <= '1'; else  lcd_seek_event      <= '0'; end if;
      if (lcd_filename_valid /= lcd_filename_valid_r) then lcd_filename_event  <= '1'; else  lcd_filename_event  <= '0'; end if;
    end if;
  end process;

-- ORed of all event signals
  process (clk, reset)
  begin
    if (reset = reset_state) then
      update_event <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (  (lcd_playing_status /= lcd_playing_status_r) or
            (lcd_vol_status     /= lcd_vol_status_r    ) or
            (lcd_mute_status    /= lcd_mute_status_r   ) or
            (lcd_seek_status    /= lcd_seek_status_r   ) or
            (lcd_filename_valid /= lcd_filename_valid_r)  ) then
        update_event <= '1';
      else
        update_event <= '0';
      end if;
    end if;
  end process;


  chrm_addr   <=  st_chram_addr(7 downto 0) when (startup_fill_chmem = '1') else
                  fn_chram_addr;
  chrm_wdata  <=  st_chram_data when (startup_fill_chmem = '1') else
                  fn_chram_data;
  chrm_wr     <=  st_chram_wr when (startup_fill_chmem = '1') else
                  fn_chram_wr;





-------------------------------------------------------------------------------
-- File name display on LCD
-------------------------------------------------------------------------------
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fn_lcd_counter <= x"C";
      fn_lcd_counter_reg <= x"C";
    elsif (clk'event and clk = clk_polarity) then
      fn_lcd_counter_reg <= fn_lcd_counter;
      if (lcd_filename_valid = '1') then
        fn_lcd_counter <= x"0";
      elsif (fn_lcd_counter /= x"C") then  -- 12
        fn_lcd_counter <= fn_lcd_counter + x"1";
      end if;
    end if;
  end process;

  fn_chram_wr <= '1' when (fn_lcd_counter < x"C") else '0';
  fn_chram_addr <= x"0" & fn_lcd_counter;

  with fn_lcd_counter select
    fn_chram_data <= lcd_filename(0*8+7 downto 0*8) when x"0",
                        lcd_filename(1*8+7 downto 1*8) when x"1",
                        lcd_filename(2*8+7 downto 2*8) when x"2",
                        lcd_filename(3*8+7 downto 3*8) when x"3",
                        lcd_filename(4*8+7 downto 4*8) when x"4",
                        lcd_filename(5*8+7 downto 5*8) when x"5",
                        lcd_filename(6*8+7 downto 6*8) when x"6",
                        lcd_filename(7*8+7 downto 7*8) when x"7",
                        lcd_filename(8*8+7 downto 8*8) when x"8",
                        lcd_filename(9*8+7 downto 9*8) when x"9",
                        lcd_filename(10*8+7 downto 10*8) when x"A",
                        lcd_filename(11*8+7 downto 11*8) when x"B",
                        x"00" when others;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      fn_wr_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (fn_lcd_counter_reg = x"B" and fn_lcd_counter = x"C") then
        fn_wr_done <= '1';
      elsif(lcdc_busy = '0') then
        fn_wr_done <= '0';
      end if;
    end if;
  end process;

  lcdc_cmd <= fn_lcdc_command;
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fn_lcdc_command <= LCD_NOP;
    elsif (clk'event and clk = clk_polarity) then
      if (fn_wr_done = '1' and lcdc_busy = '0') then
        fn_lcdc_command <= LCD_REFRESH;
      else
        fn_lcdc_command <= LCD_NOP;
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- Filling character memory with constant strings at startup
-------------------------------------------------------------------------------
-- startup signal. High on reset but goes down after one iteration of
-- char_mem_addr and never rises again
  process (clk, reset)
  begin
    if (reset = reset_state) then
      startup_fill_chmem <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (startup = '1') then
        startup_fill_chmem <= '1';
      elsif (startup_fill_chmem = '0' and st_chram_addr = '1' & x"00") then
        startup_fill_chmem <= '1';
      elsif (startup_fill_chmem = '1' and st_chram_addr = x"FF") then
        startup_fill_chmem <= '0';
      end if;
    end if;
  end process;

-- address counter
  process (clk, reset)
  begin
    if (reset = reset_state) then
      st_chram_addr <= '1' & x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (startup = '1') then
        st_chram_addr <= '0' & x"00";
      elsif (startup_fill_chmem = '1' and st_chram_addr = '1' & x"00") then
        st_chram_addr <= '0' & x"00";
      elsif (startup_fill_chmem = '1' and st_chram_addr /= x"FF") then
        st_chram_addr <= st_chram_addr + 1;
      end if;
    end if;
  end process;

-- data MUX
  process (clk, reset)
    variable check_expr : std_logic_vector(7 downto 0);
  begin
    if (reset = reset_state) then
      st_chram_data <= x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (startup_fill_chmem = '1') then
        check_expr := st_chram_addr(7 downto 0) + 1;
        case check_expr is
          when std_logic_vector(to_unsigned(16, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('V'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(17, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('O'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(18, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('L'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(19, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('U'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(20, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('M'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(21, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('E'), 8));   st_chram_wr <= '1';

          when std_logic_vector(to_unsigned(24, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('M'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(25, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('U'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(26, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('T'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(27, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('E'), 8));   st_chram_wr <= '1';

          when std_logic_vector(to_unsigned(32, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('P'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(33, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('L'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(34, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('A'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(35, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('Y'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(36, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('I'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(37, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('N'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(38, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('G'), 8));   st_chram_wr <= '1';

          when std_logic_vector(to_unsigned(40, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('P'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(41, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('A'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(42, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('U'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(43, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('S'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(44, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('E'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(45, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('D'), 8));   st_chram_wr <= '1';

          when std_logic_vector(to_unsigned(48, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('S'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(49, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('T'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(50, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('O'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(51, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('P'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(52, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('P'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(53, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('E'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(54, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('D'), 8));   st_chram_wr <= '1';

          when std_logic_vector(to_unsigned(56, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('>'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(57, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('>'), 8));   st_chram_wr <= '1';

          when std_logic_vector(to_unsigned(64, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('<'), 8));   st_chram_wr <= '1';
          when std_logic_vector(to_unsigned(65, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('<'), 8));   st_chram_wr <= '1';

          when std_logic_vector(to_unsigned(72, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('X'), 8));   st_chram_wr <= '1';

          when std_logic_vector(to_unsigned(80, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('%'), 8));   st_chram_wr <= '1';

          when std_logic_vector(to_unsigned(88, 8)) =>
            st_chram_data <= std_logic_vector(to_unsigned(character'pos('.'), 8));   st_chram_wr <= '1';

          when others =>
            st_chram_data <= x"00";
            st_chram_wr <= '0';
        end case;
      else
        st_chram_wr <= '0';
      end if;
    end if;
  end process;

end architecture;

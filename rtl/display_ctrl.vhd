-------------------------------------------------------------------------------
-- Project                    : MP3 Player Controller
-- Entity                     : lcd_ctrl
-- Entity description         : Display controller. Writes to LCD and updates
--                              the display on certain events and for scrolling
--
-- Author                     : AAK
-- Created on                 : 23 Jan, 2009
-- Last revision on           : 26 Jan, 2009
-- Last revision description  : Slight issue with contant strings in CHRAM
-- To do                      : Scoll implementation.
--                            : Decouple CHRAM and CCRAM updates.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.system_constants_pkg.all;

entity display_ctrl is
  port(
    clk                 : in  std_logic;
    reset               : in  std_logic;

    lcd_playing_status  : in  std_logic_vector(2 downto 0);
    lcd_vol_status      : in  std_logic_vector(4 downto 0);
    lcd_mute_status     : in  std_logic;

    lcd_seek_status     : in  std_logic_vector(1 downto 0);

    lcd_prog_value      : in  std_logic_vector(6 downto 0);

    lcd_filename_valid  : in  std_logic;
    lcd_filename        : in  std_logic_vector(8*12-1 downto 0);

    startup_key         : in  std_logic;

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

  function int2slv8(my_int : natural) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(my_int, 8));
  end function;

  function int2slv(my_int, size : natural) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(my_int, size));
  end function;

  function int2slv5(my_int : natural) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(my_int, 5));
  end function;

  function char2slv(char : character) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(character'pos(char), 8));
  end function;

  function str2slv(str : string) return std_logic_vector is
    variable len    : natural := str'length;
    variable ascii  : std_logic_vector(8*len-1 downto 0);
  begin
    for i in 1 to len loop
      ascii(8*i-1 downto 8*(i-1)) := char2slv(str(len-i+1));
    end loop;
    return ascii;
  end function;

  function lcd_charcmd (
      v     : natural;
      cpos  : std_logic_vector(4 downto 0);
      clth  : std_logic_vector(4 downto 0);
      csad  : std_logic_vector(7 downto 0)
    ) return std_logic_vector is
    variable v1     : std_logic_vector(7 downto 0) := int2slv8(v);
  begin
    return (v1(0) & "000" & '1' & cpos & clth-1 & csad & csad & clth-1);
  end function;

  constant SPACE_CHAR           : std_logic_vector(7 downto 0) := char2slv(' ');
  constant PERCENT_CHAR         : std_logic_vector(7 downto 0) := char2slv('%');
  constant DOT_CHAR             : std_logic_vector(7 downto 0) := char2slv('.');
  constant MUTEMARK_CHAR        : std_logic_vector(7 downto 0) := char2slv('x');

  constant FNAME_ADDR           : std_logic_vector(7 downto 0) := int2slv8(0);
  constant VOLUME_ADDR          : std_logic_vector(7 downto 0) := int2slv8(16);
  constant VOLUME_LEVEL_ADDR    : std_logic_vector(7 downto 0) := int2slv8(22);
  constant PLAYING_ADDR         : std_logic_vector(7 downto 0) := int2slv8(56);
  constant PAUSED_ADDR          : std_logic_vector(7 downto 0) := int2slv8(32);
  constant STOPPED_ADDR         : std_logic_vector(7 downto 0) := int2slv8(40);
  constant SPACE_ADDR           : std_logic_vector(7 downto 0) := int2slv8(47); -- previously was 112 where I don't write
  constant FSEEK_ADDR           : std_logic_vector(7 downto 0) := int2slv8(72);
  constant BSEEK_ADDR           : std_logic_vector(7 downto 0) := int2slv8(50);
  constant PROGRESS_ADDR        : std_logic_vector(7 downto 0) := int2slv8(52);
  constant MUTEMARK_ADDR        : std_logic_vector(7 downto 0) := int2slv8(55);

  constant FNAME_LEN            : std_logic_vector(4 downto 0) := int2slv5(12);
  constant VOLUME_LEN           : std_logic_vector(4 downto 0) := int2slv5(3);  -- may be increased to 6
  constant PLAYING_LEN          : std_logic_vector(4 downto 0) := int2slv5(7);
  constant PAUSED_LEN           : std_logic_vector(4 downto 0) := int2slv5(6);
  constant STOPPED_LEN          : std_logic_vector(4 downto 0) := int2slv5(7);
  constant FSEEK_LEN            : std_logic_vector(4 downto 0) := int2slv5(2);  -- may be increased to 2
  constant BSEEK_LEN            : std_logic_vector(4 downto 0) := int2slv5(2);  -- may be increased to 2
  constant PROGRESS_LEN         : std_logic_vector(4 downto 0) := int2slv5(3); -- (2+1) including the % mark ("99%")
  constant MUTEMARK_LEN         : std_logic_vector(4 downto 0) := int2slv5(1);
  constant VOLUME_LEVEL_LEN     : std_logic_vector(4 downto 0) := int2slv5(2);

  constant FNAME_LCDPOS         : std_logic_vector(4 downto 0) := int2slv5(0);
  constant VOLUME_LCDPOS        : std_logic_vector(4 downto 0) := int2slv5(13);
  constant PLAYING_LCDPOS       : std_logic_vector(4 downto 0) := int2slv5(16);
  constant PAUSED_LCDPOS        : std_logic_vector(4 downto 0) := int2slv5(16);
  constant STOPPED_LCDPOS       : std_logic_vector(4 downto 0) := int2slv5(16);
  constant FSEEK_LCDPOS         : std_logic_vector(4 downto 0) := int2slv5(23);
  constant BSEEK_LCDPOS         : std_logic_vector(4 downto 0) := int2slv5(23);
  constant PROGRESS_LCDPOS      : std_logic_vector(4 downto 0) := int2slv5(25);
  constant MUTEMARK_LCDPOS      : std_logic_vector(4 downto 0) := int2slv5(29);
  constant VOLUME_LEVEL_LCDPOS  : std_logic_vector(4 downto 0) := int2slv5(30);

  signal  init_flag             : std_logic;
  signal  init_flag_r           : std_logic;
  signal  trigger_init_seq      : std_logic;
  signal  init_seq_flag         : std_logic;
  signal  init_seq_flag_r       : std_logic;
  signal  init_seq_done         : std_logic;
  signal  startup_key_r         : std_logic;
  signal  init_counter          : std_logic_vector(31 downto 0);
  constant INIT_WAIT_SECONDS    : natural := 5;
  constant INIT_CNT_PEAK        : std_logic_vector(31 downto 0) := int2slv(CLK_PERIOD * INIT_WAIT_SECONDS, 32);
--   constant INIT_CNT_PEAK        : std_logic_vector(31 downto 0) := int2slv(625-1, 32); -- 20us for simulation only

  signal  lcd_playing_status_r  : std_logic_vector(2 downto 0);
  signal  lcd_prog_value_r      : std_logic_vector(6 downto 0);
  signal  lcd_vol_status_r      : std_logic_vector(4 downto 0);
  signal  lcd_mute_status_r     : std_logic;
  signal  lcd_seek_status_r     : std_logic_vector(1 downto 0);
  signal  lcd_filename_valid_r  : std_logic;
  signal  any_event          : std_logic;

-- signals for startup writing
--   signal  startup_fill          : std_logic;
--   signal  startup_fill_r        : std_logic;
  signal  st_ccram_addr       : std_logic_vector(4 downto 0);
  signal  st_ccram_addr_r     : std_logic_vector(4 downto 0);
  signal  st_ccram_data       : std_logic_vector(35 downto 0);
  signal  st_ccram_wr         : std_logic;
  signal  st_chram_addr       : std_logic_vector(7 downto 0);
  signal  st_chram_addr_r     : std_logic_vector(7 downto 0);
  signal  st_chram_data       : std_logic_vector(7 downto 0);
  signal  st_chram_wr         : std_logic;

-- signals for volume writing
  signal  vol_event           : std_logic;
  signal  vol_writing         : std_logic;
  signal  vol_update_lcd      : std_logic;
  signal  vol_chram_addr      : std_logic_vector(7 downto 0);
  signal  vol_chram_data      : std_logic_vector(7 downto 0);
  signal  vol_chram_wr        : std_logic;
  signal  vol_acd             : std_logic_vector(8*2-1 downto 0);

-- signals for progress writing
  signal  prog_event           : std_logic;
  signal  prog_writing         : std_logic;
  signal  prog_update_lcd      : std_logic;
  signal  prog_chram_addr      : std_logic_vector(7 downto 0);
  signal  prog_chram_data      : std_logic_vector(7 downto 0);
  signal  prog_chram_wr        : std_logic;
  signal  prog_acd             : std_logic_vector(8*2-1 downto 0);

-- signals for mute update
  signal  mute_event           : std_logic;
  signal  mute_update_lcd      : std_logic;
  signal  mute_chram_addr      : std_logic_vector(7 downto 0);
  signal  mute_chram_data      : std_logic_vector(7 downto 0);
  signal  mute_chram_wr        : std_logic;

-- signals for playing update
  signal  playing_event           : std_logic;
  signal  playing_update_lcd      : std_logic;
  signal  playing_ccram_addr      : std_logic_vector(4 downto 0);
  signal  playing_ccram_data      : std_logic_vector(35 downto 0);
  signal  playing_ccram_wr        : std_logic;

-- signals for seek update
  signal  seek_event           : std_logic;
  signal  seek_update_lcd      : std_logic;
  signal  seek_ccram_addr      : std_logic_vector(4 downto 0);
  signal  seek_ccram_data      : std_logic_vector(35 downto 0);
  signal  seek_ccram_wr        : std_logic;

-- signals for file name display
  signal  fn_writing          : std_logic;
  signal  fn_update_lcd       : std_logic;
  signal  fn_chram_addr       : std_logic_vector(7 downto 0);
  signal  fn_chram_data       : std_logic_vector(7 downto 0);
  signal  fn_chram_wr         : std_logic;
  signal  fn_lcd_counter      : std_logic_vector(3 downto 0);
  signal  fn_lcd_counter_reg  : std_logic_vector(3 downto 0);

begin

-------------------------------------------------------------------------------
-- Detecting events to update LCD
-------------------------------------------------------------------------------
-- ORed of all event signals
  any_event <= playing_event or vol_event or mute_event or seek_event or lcd_filename_valid;

-- registered versions of status signals
  process (clk, reset)
  begin
    if (reset = reset_state) then
      lcd_playing_status_r  <= "000";
      lcd_vol_status_r      <= "00000";
      lcd_prog_value_r      <= "0000000";
      lcd_mute_status_r     <= '0';
      lcd_seek_status_r     <= "00";
      lcd_filename_valid_r  <= '0';
    elsif (clk'event and clk = clk_polarity) then
      lcd_playing_status_r  <= lcd_playing_status;
      lcd_vol_status_r      <= lcd_vol_status;
      lcd_prog_value_r      <= lcd_prog_value;
      lcd_mute_status_r     <= lcd_mute_status;
      lcd_seek_status_r     <= lcd_seek_status;
      lcd_filename_valid_r  <= lcd_filename_valid;
    end if;
  end process;

-- creating separate events when signals change
  process (clk, reset)
  begin
    if (reset = reset_state) then
      playing_event   <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (lcd_playing_status /= lcd_playing_status_r) then
        playing_event <= '1';
      else
        playing_event <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      vol_event <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (lcd_vol_status /= lcd_vol_status_r) then
        vol_event <= '1';
      else
        vol_event <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      prog_event <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (lcd_prog_value /= lcd_prog_value_r) then
        prog_event <= '1';
      else
        prog_event <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      mute_event      <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (lcd_mute_status /= lcd_mute_status_r) then
        mute_event <= '1';
      else
        mute_event <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      seek_event      <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (lcd_seek_status /= lcd_seek_status_r) then
        seek_event <= '1';
      else
        seek_event <= '0';
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- LCD control signals
-------------------------------------------------------------------------------
  process (clk, reset)
  begin
    if (reset = reset_state) then
      lcdc_cmd <= LCD_NOP;
    elsif (clk'event and clk = clk_polarity) then
      if (  lcdc_busy = '0' and
            ( init_seq_done = '1' or
              vol_update_lcd = '1' or prog_update_lcd = '1' or mute_update_lcd = '1' or
              fn_update_lcd = '1' or playing_update_lcd = '1' or seek_update_lcd = '1' )
         ) then
        lcdc_cmd <= LCD_REFRESH;
      else
        lcdc_cmd <= LCD_NOP;
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      chrm_addr   <= x"00";
      chrm_wdata  <= x"00";
      chrm_wr     <= '0';
      ccrm_addr   <= "00000";
      ccrm_wdata  <= x"000000000";
      ccrm_wr     <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (fn_writing = '1') then            -- highest priority
        chrm_addr   <=  fn_chram_addr;
        chrm_wdata  <=  fn_chram_data;
        chrm_wr     <=  fn_chram_wr;
      elsif (vol_writing = '1') then
        chrm_addr   <=  vol_chram_addr;
        chrm_wdata  <=  vol_chram_data;
        chrm_wr     <=  vol_chram_wr;
      elsif (init_seq_flag_r = '1') then
        chrm_addr   <=  st_chram_addr_r;
        chrm_wdata  <=  st_chram_data;
        chrm_wr     <=  st_chram_wr;
        ccrm_addr   <=  st_ccram_addr_r;
        ccrm_wdata  <=  st_ccram_data;
        ccrm_wr     <=  st_ccram_wr;
      elsif (mute_event = '1') then
        chrm_addr   <=  mute_chram_addr;
        chrm_wdata  <=  mute_chram_data;
        chrm_wr     <=  mute_chram_wr;
      elsif (playing_event = '1') then
        ccrm_addr   <=  playing_ccram_addr;
        ccrm_wdata  <=  playing_ccram_data;
        ccrm_wr     <=  playing_ccram_wr;
      elsif (seek_event = '1') then
        ccrm_addr   <=  seek_ccram_addr;
        ccrm_wdata  <=  seek_ccram_data;
        ccrm_wr     <=  seek_ccram_wr;
      elsif (prog_writing = '1') then         -- least priority
        chrm_addr   <=  prog_chram_addr;
        chrm_wdata  <=  prog_chram_data;
        chrm_wr     <=  prog_chram_wr;
      else
        chrm_addr   <= x"00";
        chrm_wdata  <= x"00";
        chrm_wr     <= '0';
        ccrm_addr   <= "00000";
        ccrm_wdata  <= x"000000000";
        ccrm_wr     <= '0';
      end if;
    end if;
  end process;

-------------------------------------------------------------------------------
-- Filling character memory with volume level
-------------------------------------------------------------------------------
-- address counter
  process (clk, reset)
  begin
    if (reset = reset_state) then
      vol_chram_addr <= x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (vol_event = '1') then
        vol_chram_addr <= VOLUME_LEVEL_ADDR;
      elsif (vol_chram_addr = VOLUME_LEVEL_ADDR + VOLUME_LEVEL_LEN - 1) then
        vol_chram_addr <= x"00";
      elsif (vol_chram_addr /= x"00") then
        vol_chram_addr <= vol_chram_addr + 1;
      end if;
    end if;
  end process;

-- data MUX
  process (vol_chram_addr, vol_acd)
  begin
    case vol_chram_addr is
      when VOLUME_LEVEL_ADDR =>
        vol_chram_data <= vol_acd(15 downto 8);
        vol_chram_wr <= '1';
      when VOLUME_LEVEL_ADDR + 1 =>
        vol_chram_data <= vol_acd(7 downto 0);
        vol_chram_wr <= '1';
      when others =>
        vol_chram_data <= SPACE_CHAR;
        vol_chram_wr <= '0';
    end case;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      vol_writing <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (vol_event = '1') then
        vol_writing <= '1';
      elsif(vol_update_lcd = '1') then
        vol_writing <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      vol_update_lcd <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (vol_chram_addr = VOLUME_LEVEL_ADDR + VOLUME_LEVEL_LEN - 1) then
        vol_update_lcd <= '1';
      elsif(lcdc_busy = '0') then
        vol_update_lcd <= '0';
      end if;
    end if;
  end process;

-------------------------------------------------------------------------------
-- Filling character memory with Progress bar level
-------------------------------------------------------------------------------
-- address counter
  process (clk, reset)
  begin
    if (reset = reset_state) then
      prog_chram_addr <= x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (prog_event = '1') then
        prog_chram_addr <= PROGRESS_ADDR;
      elsif (prog_chram_addr = PROGRESS_ADDR + PROGRESS_LEN - 1) then -- (2+1) including the % mark ("99%")
        prog_chram_addr <= x"00";
      elsif (prog_chram_addr /= x"00") then
        prog_chram_addr <= prog_chram_addr + 1;
      end if;
    end if;
  end process;

-- data MUX
  process (prog_chram_addr, prog_acd)
  begin
    case prog_chram_addr is
      when PROGRESS_ADDR =>
        prog_chram_data <= prog_acd(15 downto 8);
        prog_chram_wr <= '1';
      when PROGRESS_ADDR + 1 =>
        prog_chram_data <= prog_acd(7 downto 0);
        prog_chram_wr <= '1';
      when PROGRESS_ADDR + 2 =>
        if (lcd_prog_value = "1111111") then  -- don't write % mark for invalid progress
          prog_chram_data <= SPACE_CHAR;
          prog_chram_wr <= '1';
        else
          prog_chram_data <= PERCENT_CHAR;
          prog_chram_wr <= '1';
        end if;
      when others =>
        prog_chram_data <= SPACE_CHAR;
        prog_chram_wr <= '0';
    end case;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      prog_writing <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (prog_event = '1') then
        prog_writing <= '1';
      elsif(prog_update_lcd = '1') then
        prog_writing <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      prog_update_lcd <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (prog_chram_addr = PROGRESS_ADDR + PROGRESS_LEN - 1) then -- (2+1) including the % mark ("99%")
        prog_update_lcd <= '1';
      elsif(lcdc_busy = '0') then
        prog_update_lcd <= '0';
      end if;
    end if;
  end process;

-------------------------------------------------------------------------------
-- Updating the mute status
-------------------------------------------------------------------------------
  mute_chram_addr <= MUTEMARK_ADDR;
  mute_chram_data <= MUTEMARK_CHAR when lcd_mute_status = '1' else
                     SPACE_CHAR;
  mute_chram_wr <= mute_event;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      mute_update_lcd <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (mute_event = '1') then
        mute_update_lcd <= '1';
      elsif(lcdc_busy = '0') then
        mute_update_lcd <= '0';
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- Updating the playing status
-------------------------------------------------------------------------------
  playing_ccram_addr <= PLAYING_LCDPOS;
  playing_ccram_data <= lcd_charcmd(1, PLAYING_LCDPOS, PLAYING_LEN, PLAYING_ADDR) when lcd_playing_status = "001" else
                        lcd_charcmd(1, PLAYING_LCDPOS, PLAYING_LEN, PAUSED_ADDR) when lcd_playing_status = "010" else
                        lcd_charcmd(1, PLAYING_LCDPOS, PLAYING_LEN, STOPPED_ADDR) when lcd_playing_status = "100" else
                        lcd_charcmd(1, PLAYING_LCDPOS, PLAYING_LEN, STOPPED_ADDR);
  playing_ccram_wr <= playing_event;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      playing_update_lcd <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (playing_event = '1') then
        playing_update_lcd <= '1';
      elsif(lcdc_busy = '0') then
        playing_update_lcd <= '0';
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- Updating the seek status
-------------------------------------------------------------------------------
  seek_ccram_addr <= FSEEK_LCDPOS;
  seek_ccram_data <= lcd_charcmd(1, FSEEK_LCDPOS, FSEEK_LEN, FSEEK_ADDR) when lcd_seek_status = "01" else
                     lcd_charcmd(1, BSEEK_LCDPOS, BSEEK_LEN, BSEEK_ADDR) when lcd_seek_status = "10" else
                     lcd_charcmd(1, BSEEK_LCDPOS, BSEEK_LEN, SPACE_ADDR);
  seek_ccram_wr <= seek_event;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      seek_update_lcd <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (seek_event = '1') then
        seek_update_lcd <= '1';
      elsif(lcdc_busy = '0') then
        seek_update_lcd <= '0';
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- File name display on LCD
-------------------------------------------------------------------------------
  process (clk, reset)
  begin
    if (reset = reset_state) then
      fn_lcd_counter <= x"C";
    elsif (clk'event and clk = clk_polarity) then
      if (lcd_filename_valid = '1') then
        fn_lcd_counter <= x"0";
      elsif (fn_lcd_counter /= x"C") then
        fn_lcd_counter <= fn_lcd_counter + x"1";
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      fn_lcd_counter_reg <= x"C";
    elsif (clk'event and clk = clk_polarity) then
      fn_lcd_counter_reg <= fn_lcd_counter;
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
      fn_writing <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (lcd_filename_valid = '1') then
        fn_writing <= '1';
      elsif(fn_update_lcd = '1') then
        fn_writing <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      fn_update_lcd <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (fn_lcd_counter_reg = x"B" and fn_lcd_counter = x"C") then
        fn_update_lcd <= '1';
      elsif(lcdc_busy = '0') then
        fn_update_lcd <= '0';
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- init flag and trigger to fill the LCD memories with constant strings
-------------------------------------------------------------------------------
  process (clk, reset)
  begin
    if (reset = reset_state) then
      startup_key_r <= '0';
    elsif (clk'event and clk = clk_polarity) then
      startup_key_r <= startup_key;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      init_counter <= INIT_CNT_PEAK;
    elsif (clk'event and clk = clk_polarity) then
      if (init_counter /= 0) then
        init_counter <= init_counter - 1;
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      init_flag <= '1';
    elsif (clk'event and clk = clk_polarity) then
      if (init_flag = '1' and init_counter = 0) then    -- if init counter expires
        init_flag <= '0';                                 -- go down and never rise again
      elsif (startup_key = '1') then    -- if forced to initialize again
        init_flag <= '1';
      elsif (startup_key = '0' and startup_key_r = '1') then  -- go down again in the next cycle
        init_flag <= '0';                                     -- and never rise again
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      init_flag_r <= '1';
    elsif (clk'event and clk = clk_polarity) then
      init_flag_r <= init_flag;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      trigger_init_seq <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (init_flag = '0' and init_flag_r = '1') then  -- at the falling edge
        trigger_init_seq <= '1';
      else
        trigger_init_seq <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      init_seq_flag <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (trigger_init_seq = '1') then
        init_seq_flag <= '1';
      elsif (st_chram_addr = int2slv(111, 8)) then
        init_seq_flag <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      init_seq_flag_r <= '0';
    elsif (clk'event and clk = clk_polarity) then
      init_seq_flag_r <= init_seq_flag;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      init_seq_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (init_seq_flag = '0' and init_seq_flag_r = '1') then  -- at the falling edge
        init_seq_done <= '1';
      elsif (lcdc_busy = '0') then
        init_seq_done <= '0';
      end if;
    end if;
  end process;

-- startup chram address counter
  process (clk, reset)
  begin
    if (reset = reset_state) then
      st_chram_addr <= x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (init_seq_flag = '1' and st_chram_addr /= int2slv(111, 8)) then
        st_chram_addr <= st_chram_addr + 1;
      elsif (trigger_init_seq = '1') then
        st_chram_addr <= x"00";
      end if;
    end if;
  end process;

-- startup ccram address counter
  process (clk, reset)
  begin
    if (reset = reset_state) then
      st_ccram_addr <= "00000";
    elsif (clk'event and clk = clk_polarity) then
      if (init_seq_flag = '1' and st_ccram_addr /= "11111") then
        st_ccram_addr <= st_ccram_addr + 1;
      elsif (trigger_init_seq = '1') then
        st_ccram_addr <= "00000";
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      st_chram_addr_r <= x"00";
      st_ccram_addr_r <= "00000";
    elsif (clk'event and clk = clk_polarity) then
      st_chram_addr_r <= st_chram_addr;
      st_ccram_addr_r <= st_ccram_addr;
    end if;
  end process;

-- startup ccram data MUX
  process (clk, reset)
  begin
    if (reset = reset_state) then
      st_ccram_data <= x"000000000";
    elsif (clk'event and clk = clk_polarity) then
      if (init_seq_flag = '1') then
        case st_ccram_addr(4 downto 0) is
          when FNAME_LCDPOS =>
            st_ccram_data <= lcd_charcmd(1, FNAME_LCDPOS, FNAME_LEN, FNAME_ADDR);
            st_ccram_wr <= '1';
          when VOLUME_LCDPOS =>
            st_ccram_data <= lcd_charcmd(1, VOLUME_LCDPOS, VOLUME_LEN, VOLUME_ADDR);
            st_ccram_wr <= '1';
          when PLAYING_LCDPOS =>
            st_ccram_data <= playing_ccram_data;
            st_ccram_wr <= '1';
          when FSEEK_LCDPOS =>
            st_ccram_data <= lcd_charcmd(1, FSEEK_LCDPOS, FSEEK_LEN, SPACE_ADDR);
            st_ccram_wr <= '1';
          when PROGRESS_LCDPOS =>
            st_ccram_data <= lcd_charcmd(1, PROGRESS_LCDPOS, PROGRESS_LEN, PROGRESS_ADDR);
            st_ccram_wr <= '1';
          when MUTEMARK_LCDPOS =>
            st_ccram_data <= lcd_charcmd(1, MUTEMARK_LCDPOS, MUTEMARK_LEN, MUTEMARK_ADDR);
            st_ccram_wr <= '1';
          when VOLUME_LEVEL_LCDPOS =>
            st_ccram_data <= lcd_charcmd(1, VOLUME_LEVEL_LCDPOS, VOLUME_LEVEL_LEN, VOLUME_LEVEL_ADDR);
            st_ccram_wr <= '1';
--           when int2slv5(12) =>
--             st_ccram_data <= lcd_charcmd(1, int2slv5(12), int2slv5(1), SPACE_ADDR);  st_ccram_wr <= '1';
--           when int2slv5(28) =>
--             st_ccram_data <= lcd_charcmd(1, int2slv5(28), int2slv5(1), SPACE_ADDR);  st_ccram_wr <= '1';
          when others =>
            st_ccram_data <= x"000000000";
            st_ccram_wr <= '0';
        end case;
      else
        st_ccram_data <= x"000000000";
        st_ccram_wr <= '0';
      end if;
    end if;
  end process;


-- startup chram data MUX
  process (clk, reset)
  begin
    if (reset = reset_state) then
      st_chram_data <= SPACE_CHAR;
    elsif (clk'event and clk = clk_polarity) then
      if (init_seq_flag = '1') then
        case st_chram_addr is
          when VOLUME_ADDR =>
            st_chram_data <= char2slv('V');   st_chram_wr <= '1';
          when VOLUME_ADDR + 1 =>
            st_chram_data <= char2slv('O');   st_chram_wr <= '1';
          when VOLUME_ADDR + 2 =>
            st_chram_data <= char2slv('L');   st_chram_wr <= '1';

          when PLAYING_ADDR =>
            st_chram_data <= char2slv('P');   st_chram_wr <= '1';
          when PLAYING_ADDR + 1 =>
            st_chram_data <= char2slv('L');   st_chram_wr <= '1';
          when PLAYING_ADDR + 2 =>
            st_chram_data <= char2slv('A');   st_chram_wr <= '1';
          when PLAYING_ADDR + 3 =>
            st_chram_data <= char2slv('Y');   st_chram_wr <= '1';
          when PLAYING_ADDR + 4 =>
            st_chram_data <= char2slv('I');   st_chram_wr <= '1';
          when PLAYING_ADDR + 5 =>
            st_chram_data <= char2slv('N');   st_chram_wr <= '1';
          when PLAYING_ADDR + 6 =>
            st_chram_data <= char2slv('G');   st_chram_wr <= '1';

          when PAUSED_ADDR =>
            st_chram_data <= char2slv('P');   st_chram_wr <= '1';
          when PAUSED_ADDR + 1 =>
            st_chram_data <= char2slv('A');   st_chram_wr <= '1';
          when PAUSED_ADDR + 2 =>
            st_chram_data <= char2slv('U');   st_chram_wr <= '1';
          when PAUSED_ADDR + 3 =>
            st_chram_data <= char2slv('S');   st_chram_wr <= '1';
          when PAUSED_ADDR + 4 =>
            st_chram_data <= char2slv('E');   st_chram_wr <= '1';
          when PAUSED_ADDR + 5 =>
            st_chram_data <= char2slv('D');   st_chram_wr <= '1';

          when STOPPED_ADDR =>
            st_chram_data <= char2slv('S');   st_chram_wr <= '1';
          when STOPPED_ADDR + 1 =>
            st_chram_data <= char2slv('T');   st_chram_wr <= '1';
          when STOPPED_ADDR + 2 =>
            st_chram_data <= char2slv('O');   st_chram_wr <= '1';
          when STOPPED_ADDR + 3 =>
            st_chram_data <= char2slv('P');   st_chram_wr <= '1';
          when STOPPED_ADDR + 4 =>
            st_chram_data <= char2slv('P');   st_chram_wr <= '1';
          when STOPPED_ADDR + 5 =>
            st_chram_data <= char2slv('E');   st_chram_wr <= '1';
          when STOPPED_ADDR + 6 =>
            st_chram_data <= char2slv('D');   st_chram_wr <= '1';

          when FSEEK_ADDR =>
            st_chram_data <= char2slv('>');   st_chram_wr <= '1';
          when FSEEK_ADDR + 1 =>
            st_chram_data <= char2slv('>');   st_chram_wr <= '1';

          when BSEEK_ADDR =>
            st_chram_data <= char2slv('<');   st_chram_wr <= '1';
          when BSEEK_ADDR + 1 =>
            st_chram_data <= char2slv('<');   st_chram_wr <= '1';

          when MUTEMARK_ADDR =>
            st_chram_data <= mute_chram_data; st_chram_wr <= '1';

          when SPACE_ADDR =>
            st_chram_data <= SPACE_CHAR;      st_chram_wr <= '1';

          when VOLUME_LEVEL_ADDR =>
            st_chram_data <= vol_acd(15 downto 8);  st_chram_wr <= '1';
          when VOLUME_LEVEL_ADDR + 1 =>
            st_chram_data <= vol_acd(7 downto 0);   st_chram_wr <= '1';

          when PROGRESS_ADDR =>
            st_chram_data <= prog_acd(15 downto 8); st_chram_wr <= '1';
          when PROGRESS_ADDR + 1 =>
            st_chram_data <= prog_acd(7 downto 0);  st_chram_wr <= '1';
          when PROGRESS_ADDR + 2 =>
            st_chram_data <= SPACE_CHAR;            st_chram_wr <= '1';

          when others =>
            st_chram_data <= SPACE_CHAR;
            st_chram_wr <= '0';
        end case;
      else
        st_chram_data <= SPACE_CHAR;
        st_chram_wr <= '0';
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- ASCII coded decimal conversions
-------------------------------------------------------------------------------
  vol_acd <=  char2slv('3') & char2slv('1') when lcd_vol_status = 0 else
              char2slv('3') & char2slv('0') when lcd_vol_status = 1 else
              char2slv('2') & char2slv('9') when lcd_vol_status = 2 else
              char2slv('2') & char2slv('8') when lcd_vol_status = 3 else
              char2slv('2') & char2slv('7') when lcd_vol_status = 4 else
              char2slv('2') & char2slv('6') when lcd_vol_status = 5 else
              char2slv('2') & char2slv('5') when lcd_vol_status = 6 else
              char2slv('2') & char2slv('4') when lcd_vol_status = 7 else
              char2slv('2') & char2slv('3') when lcd_vol_status = 8 else
              char2slv('2') & char2slv('2') when lcd_vol_status = 9 else
              char2slv('2') & char2slv('1') when lcd_vol_status = 10 else
              char2slv('2') & char2slv('0') when lcd_vol_status = 11 else
              char2slv('1') & char2slv('9') when lcd_vol_status = 12 else
              char2slv('1') & char2slv('8') when lcd_vol_status = 13 else
              char2slv('1') & char2slv('7') when lcd_vol_status = 14 else
              char2slv('1') & char2slv('6') when lcd_vol_status = 15 else
              char2slv('1') & char2slv('5') when lcd_vol_status = 16 else
              char2slv('1') & char2slv('4') when lcd_vol_status = 17 else
              char2slv('1') & char2slv('3') when lcd_vol_status = 18 else
              char2slv('1') & char2slv('2') when lcd_vol_status = 19 else
              char2slv('1') & char2slv('1') when lcd_vol_status = 20 else
              char2slv('1') & char2slv('0') when lcd_vol_status = 21 else
              char2slv(' ') & char2slv('9') when lcd_vol_status = 22 else
              char2slv(' ') & char2slv('8') when lcd_vol_status = 23 else
              char2slv(' ') & char2slv('7') when lcd_vol_status = 24 else
              char2slv(' ') & char2slv('6') when lcd_vol_status = 25 else
              char2slv(' ') & char2slv('5') when lcd_vol_status = 26 else
              char2slv(' ') & char2slv('4') when lcd_vol_status = 27 else
              char2slv(' ') & char2slv('3') when lcd_vol_status = 28 else
              char2slv(' ') & char2slv('2') when lcd_vol_status = 29 else
              char2slv(' ') & char2slv('1') when lcd_vol_status = 30 else
              char2slv(' ') & char2slv('0') when lcd_vol_status = 31 else
              char2slv('3') & char2slv('1');


  prog_acd <= char2slv(' ') & char2slv('0') when lcd_prog_value = 0 else
              char2slv(' ') & char2slv('1') when lcd_prog_value = 1 else
              char2slv(' ') & char2slv('2') when lcd_prog_value = 2 else
              char2slv(' ') & char2slv('3') when lcd_prog_value = 3 else
              char2slv(' ') & char2slv('4') when lcd_prog_value = 4 else
              char2slv(' ') & char2slv('5') when lcd_prog_value = 5 else
              char2slv(' ') & char2slv('6') when lcd_prog_value = 6 else
              char2slv(' ') & char2slv('7') when lcd_prog_value = 7 else
              char2slv(' ') & char2slv('8') when lcd_prog_value = 8 else
              char2slv(' ') & char2slv('9') when lcd_prog_value = 9 else
              char2slv('1') & char2slv('0') when lcd_prog_value = 10 else
              char2slv('1') & char2slv('1') when lcd_prog_value = 11 else
              char2slv('1') & char2slv('2') when lcd_prog_value = 12 else
              char2slv('1') & char2slv('3') when lcd_prog_value = 13 else
              char2slv('1') & char2slv('4') when lcd_prog_value = 14 else
              char2slv('1') & char2slv('5') when lcd_prog_value = 15 else
              char2slv('1') & char2slv('6') when lcd_prog_value = 16 else
              char2slv('1') & char2slv('7') when lcd_prog_value = 17 else
              char2slv('1') & char2slv('8') when lcd_prog_value = 18 else
              char2slv('1') & char2slv('9') when lcd_prog_value = 19 else
              char2slv('2') & char2slv('0') when lcd_prog_value = 20 else
              char2slv('2') & char2slv('1') when lcd_prog_value = 21 else
              char2slv('2') & char2slv('2') when lcd_prog_value = 22 else
              char2slv('2') & char2slv('3') when lcd_prog_value = 23 else
              char2slv('2') & char2slv('4') when lcd_prog_value = 24 else
              char2slv('2') & char2slv('5') when lcd_prog_value = 25 else
              char2slv('2') & char2slv('6') when lcd_prog_value = 26 else
              char2slv('2') & char2slv('7') when lcd_prog_value = 27 else
              char2slv('2') & char2slv('8') when lcd_prog_value = 28 else
              char2slv('2') & char2slv('9') when lcd_prog_value = 29 else
              char2slv('3') & char2slv('0') when lcd_prog_value = 30 else
              char2slv('3') & char2slv('1') when lcd_prog_value = 31 else
              char2slv('3') & char2slv('2') when lcd_prog_value = 32 else
              char2slv('3') & char2slv('3') when lcd_prog_value = 33 else
              char2slv('3') & char2slv('4') when lcd_prog_value = 34 else
              char2slv('3') & char2slv('5') when lcd_prog_value = 35 else
              char2slv('3') & char2slv('6') when lcd_prog_value = 36 else
              char2slv('3') & char2slv('7') when lcd_prog_value = 37 else
              char2slv('3') & char2slv('8') when lcd_prog_value = 38 else
              char2slv('3') & char2slv('9') when lcd_prog_value = 39 else
              char2slv('4') & char2slv('0') when lcd_prog_value = 40 else
              char2slv('4') & char2slv('1') when lcd_prog_value = 41 else
              char2slv('4') & char2slv('2') when lcd_prog_value = 42 else
              char2slv('4') & char2slv('3') when lcd_prog_value = 43 else
              char2slv('4') & char2slv('4') when lcd_prog_value = 44 else
              char2slv('4') & char2slv('5') when lcd_prog_value = 45 else
              char2slv('4') & char2slv('6') when lcd_prog_value = 46 else
              char2slv('4') & char2slv('7') when lcd_prog_value = 47 else
              char2slv('4') & char2slv('8') when lcd_prog_value = 48 else
              char2slv('4') & char2slv('9') when lcd_prog_value = 49 else
              char2slv('5') & char2slv('0') when lcd_prog_value = 50 else
              char2slv('5') & char2slv('1') when lcd_prog_value = 51 else
              char2slv('5') & char2slv('2') when lcd_prog_value = 52 else
              char2slv('5') & char2slv('3') when lcd_prog_value = 53 else
              char2slv('5') & char2slv('4') when lcd_prog_value = 54 else
              char2slv('5') & char2slv('5') when lcd_prog_value = 55 else
              char2slv('5') & char2slv('6') when lcd_prog_value = 56 else
              char2slv('5') & char2slv('7') when lcd_prog_value = 57 else
              char2slv('5') & char2slv('8') when lcd_prog_value = 58 else
              char2slv('5') & char2slv('9') when lcd_prog_value = 59 else
              char2slv('6') & char2slv('0') when lcd_prog_value = 60 else
              char2slv('6') & char2slv('1') when lcd_prog_value = 61 else
              char2slv('6') & char2slv('2') when lcd_prog_value = 62 else
              char2slv('6') & char2slv('3') when lcd_prog_value = 63 else
              char2slv('6') & char2slv('4') when lcd_prog_value = 64 else
              char2slv('6') & char2slv('5') when lcd_prog_value = 65 else
              char2slv('6') & char2slv('6') when lcd_prog_value = 66 else
              char2slv('6') & char2slv('7') when lcd_prog_value = 67 else
              char2slv('6') & char2slv('8') when lcd_prog_value = 68 else
              char2slv('6') & char2slv('9') when lcd_prog_value = 69 else
              char2slv('7') & char2slv('0') when lcd_prog_value = 70 else
              char2slv('7') & char2slv('1') when lcd_prog_value = 71 else
              char2slv('7') & char2slv('2') when lcd_prog_value = 72 else
              char2slv('7') & char2slv('3') when lcd_prog_value = 73 else
              char2slv('7') & char2slv('4') when lcd_prog_value = 74 else
              char2slv('7') & char2slv('5') when lcd_prog_value = 75 else
              char2slv('7') & char2slv('6') when lcd_prog_value = 76 else
              char2slv('7') & char2slv('7') when lcd_prog_value = 77 else
              char2slv('7') & char2slv('8') when lcd_prog_value = 78 else
              char2slv('7') & char2slv('9') when lcd_prog_value = 79 else
              char2slv('8') & char2slv('0') when lcd_prog_value = 80 else
              char2slv('8') & char2slv('1') when lcd_prog_value = 81 else
              char2slv('8') & char2slv('2') when lcd_prog_value = 82 else
              char2slv('8') & char2slv('3') when lcd_prog_value = 83 else
              char2slv('8') & char2slv('4') when lcd_prog_value = 84 else
              char2slv('8') & char2slv('5') when lcd_prog_value = 85 else
              char2slv('8') & char2slv('6') when lcd_prog_value = 86 else
              char2slv('8') & char2slv('7') when lcd_prog_value = 87 else
              char2slv('8') & char2slv('8') when lcd_prog_value = 88 else
              char2slv('8') & char2slv('9') when lcd_prog_value = 89 else
              char2slv('9') & char2slv('0') when lcd_prog_value = 90 else
              char2slv('9') & char2slv('1') when lcd_prog_value = 91 else
              char2slv('9') & char2slv('2') when lcd_prog_value = 92 else
              char2slv('9') & char2slv('3') when lcd_prog_value = 93 else
              char2slv('9') & char2slv('4') when lcd_prog_value = 94 else
              char2slv('9') & char2slv('5') when lcd_prog_value = 95 else
              char2slv('9') & char2slv('6') when lcd_prog_value = 96 else
              char2slv('9') & char2slv('7') when lcd_prog_value = 97 else
              char2slv('9') & char2slv('8') when lcd_prog_value = 98 else
              char2slv('9') & char2slv('9') when lcd_prog_value = 99 else
              char2slv('0') & char2slv('0') when lcd_prog_value = 100 else
              char2slv(' ') & char2slv(' ');


end architecture;

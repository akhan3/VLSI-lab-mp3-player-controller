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
use ieee.std_logic_textio.all;
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

  signal  char_mem_addr         : std_logic_vector(7 downto 0);
  signal  cc_mem_addr           : std_logic_vector(4 downto 0);

  signal  startup_fill_char_ram : std_logic;

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


-------------------------------------------------------------------------------
-- Filling character memory with constants at startup
-------------------------------------------------------------------------------
-- startup signal. High on reset but goes down after
-- one iteration of char_mem_addr and never rises again
  process (clk, reset)
  begin
    if (reset = reset_state) then
      startup_fill_char_ram <= '1';
    elsif (clk'event and clk = clk_polarity) then
      if (startup_fill_char_ram = '1' and char_mem_addr = x"FF") then
        startup_fill_char_ram <= '0';
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      char_mem_addr <= x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (startup_fill_char_ram = '1' and char_mem_addr /= x"FF") then
        char_mem_addr <= char_mem_addr + 1;
      end if;
    end if;
  end process;


end architecture;

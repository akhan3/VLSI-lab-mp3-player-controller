-------------------------------------------------------------------------------
-- Project                    : MP3 Player Controller
-- Entity                     : file_info_processor
-- Entity description         : Extracts the file name and size information.
--                              Also writes the filename to the LCD
--
-- Author                     : AAK
-- Created on                 : 04 Jan, 2009
-- Last revision on           : 23 Jan, 2009
-- Last revision description  : Changes in ports and internal signals names
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.system_constants_pkg.all;

entity file_info_processor is
  port(
    clk               : in  std_logic;
    reset             : in  std_logic;

    file_info_start   : in  std_logic;
    file_info_ready   : out std_logic;
    file_size_byte    : out std_logic_vector(31 downto 0);

    fio_buso          : in  std_logic_vector(31 downto 0);
    fio_busov         : in  std_logic;

    lcd_filename_valid: out std_logic;
    lcd_filename      : out std_logic_vector(8*12-1 downto 0)
  );
end entity;

architecture arch of file_info_processor is
  constant  DOT_CHAR              : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(character'pos('.'), 8));
  type      filename_regarray   is  array (0 to 11) of std_logic_vector(7 downto 0);
  signal    fname                 : filename_regarray;
  signal    fio_data_counter      : std_logic_vector(3 downto 0);
  signal    fio_data_counter3_reg : std_logic;
  signal    info_ready            : std_logic;

begin

  lcd_filename_valid <= info_ready;
  lcd_filename <= fname(11) & fname(10) & fname(9) & fname(8) & fname(7) & fname(6) &
                  fname(5) & fname(4) & fname(3) & fname(2) & fname(1) & fname(0);

  process (clk, reset)
  begin
    if (reset = reset_state) then
      for i in 0 to 11 loop
        fname(i) <= x"00";
      end loop;
    elsif (clk'event and clk = clk_polarity) then
      if (fio_busov = '1') then
        if (fio_data_counter = x"0") then
          fname(0) <= fio_buso(7 downto 0);
          fname(1) <= fio_buso(15 downto 8);
          fname(2) <= fio_buso(23 downto 16);
          fname(3) <= fio_buso(31 downto 24);
        elsif (fio_data_counter = x"1") then
          fname(4) <= fio_buso(7 downto 0);
          fname(5) <= fio_buso(15 downto 8);
          fname(6) <= fio_buso(23 downto 16);
          fname(7) <= fio_buso(31 downto 24);
        elsif (fio_data_counter = x"2") then
          fname(8) <= DOT_CHAR; -- dot for extension separator
          fname(9) <= fio_buso(7 downto 0);
          fname(10) <= fio_buso(15 downto 8);
          fname(11) <= fio_buso(23 downto 16);
        end if;
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
        file_size_byte <= x"0000_0000";
    elsif (clk'event and clk = clk_polarity) then
      if (fio_busov = '1' and fio_data_counter = x"7") then
        file_size_byte <= fio_buso;
      end if;
    end if;
  end process;

  process (clk, reset)
  begin
    if (reset = reset_state) then
      fio_data_counter <= x"8";
      fio_data_counter3_reg <= '1';
    elsif (clk'event and clk = clk_polarity) then
      fio_data_counter3_reg <= fio_data_counter(3);
      if (file_info_start = '1') then
        fio_data_counter <= x"0";
      elsif (fio_busov = '1' and fio_data_counter /= x"8") then
        fio_data_counter <= fio_data_counter + x"1";
      end if;
    end if;
  end process;

--   filename_lcd_writing: process (clk, reset)
--   begin
--     if (reset = reset_state) then
--       lcdc_chrm_wen <= '0';
--     elsif (clk'event and clk = clk_polarity) then
--       if (fname_lcd_counter < x"C") then
--         lcdc_chrm_wen <= '1';
--       else
--         lcdc_chrm_wen <= '0';
--       end if;
--     end if;
--   end process;

-- 0 to 1 detector for counter[3] bit
-- detects the transition from 7 to 8
--                               _____________
-- counter[3]         __________/  ___________
-- counter3_reg       ____________/__
-- file_info_ready    ____________/  \________
  file_info_ready <= info_ready;
  process (clk, reset)
  begin
    if (reset = reset_state) then
      info_ready <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (fio_data_counter3_reg = '0' and fio_data_counter(3) = '1') then
        info_ready <= '1';
      else
        info_ready <= '0';
      end if;
    end if;
  end process;

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.system_constants_pkg.all;

entity file_info_processor is
  port(
    clk             : in  std_logic;
    reset           : in  std_logic;
    file_info_start      : in  std_logic;
    file_info_ready      : out std_logic;
    fio_buso        : in  std_logic_vector(31 downto 0);
    fio_busov       : in  std_logic;
    file_size_byte        : out std_logic_vector(31 downto 0);

    lcdc_busy       : in  std_logic;
--     lcdc_gnt        : in  std_logic;
--     lcdc_req        : out std_logic;
    lcdc_cmd        : out std_logic_vector(1 downto 0);
--     lcdc_ccrm_wdata : out std_logic_vector(35 downto 0);
--     lcdc_ccrm_waddr : out std_logic_vector(4 downto 0);
--     lcdc_ccrm_wen   : out std_logic;
    lcdc_chrm_wdata : out std_logic_vector(7 downto 0);
    lcdc_chrm_waddr : out std_logic_vector(7 downto 0);
    lcdc_chrm_wen   : out std_logic
  );
end entity;

architecture arch of file_info_processor is
  type      filename_regarray   is  array (0 to 11) of std_logic_vector(7 downto 0);
  signal    fname                 : filename_regarray;
--   constant  DOT_CHAR              : character := '.';
  constant  DOT_CHAR              : std_logic_vector(7 downto 0) := x"2E";
  signal    fname_lcd_counter     : std_logic_vector(3 downto 0);
  signal    fname_lcd_counter_reg : std_logic_vector(3 downto 0);
  signal    fio_data_counter      : std_logic_vector(3 downto 0);
  signal    fio_data_counter3_reg : std_logic;
  signal    info_ready_bit        : std_logic;
  signal    lcdc_command          : std_logic_vector(1 downto 0);
  signal    fname_wr_done         : std_logic;
begin

  filename_register: process (clk, reset)
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

  filesize_register: process (clk, reset)
  begin
    if (reset = reset_state) then
        file_size_byte <= x"0000_0000";
    elsif (clk'event and clk = clk_polarity) then
      if (fio_busov = '1' and fio_data_counter = x"7") then
        file_size_byte <= fio_buso;
      end if;
    end if;
  end process;

  fio_counter: process (clk, reset)
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

  filename_lcd_counter: process (clk, reset)
  begin
    if (reset = reset_state) then
      fname_lcd_counter <= x"C";
      fname_lcd_counter_reg <= x"C";
    elsif (clk'event and clk = clk_polarity) then
      fname_lcd_counter_reg <= fname_lcd_counter;
      if (info_ready_bit = '1') then
        fname_lcd_counter <= x"0";
      elsif (fname_lcd_counter /= x"C") then  -- 12
        fname_lcd_counter <= fname_lcd_counter + x"1";
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

  lcdc_chrm_wen <= '1' when (fname_lcd_counter < x"C") else '0';
  lcdc_chrm_waddr <= x"0" & fname_lcd_counter;

  with fname_lcd_counter select
    lcdc_chrm_wdata <= fname(0) when x"0",
                       fname(1) when x"1",
                       fname(2) when x"2",
                       fname(3) when x"3",
                       fname(4) when x"4",
                       fname(5) when x"5",
                       fname(6) when x"6",
                       fname(7) when x"7",
                       fname(8) when x"8",
                       fname(9) when x"9",
                       fname(10) when x"A",
                       fname(11) when x"B",
                       x"00" when others;

-- 0 to 1 detector for counter[3] bit
-- detects the transition from 7 to 8
--                          _____________
-- counter[3]    __________/  ___________
-- counter3_reg  ____________/__
-- file_info_ready    ____________/  \________
  file_info_ready <= info_ready_bit;
  process (clk, reset)
  begin
    if (reset = reset_state) then
      info_ready_bit <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (fio_data_counter3_reg = '0' and fio_data_counter(3) = '1') then
        info_ready_bit <= '1';
      else
        info_ready_bit <= '0';
      end if;
    end if;
  end process;

  filename_write_done: process (clk, reset) -- My thinking
  begin
    if (reset = reset_state) then
      fname_wr_done <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (fname_lcd_counter_reg = x"B" and fname_lcd_counter = x"C") then
        fname_wr_done <= '1';
      elsif(lcdc_busy = '0') then
        fname_wr_done <= '0';
      end if;
    end if;
  end process;
--   filename_write_done: process (clk, reset) -- Given in manual
--   begin
--     if (reset = reset_state) then
--       fname_wr_done <= '0';
--     elsif (clk'event and clk = clk_polarity) then
--       if (lcdc_command = LCD_REFRESH) then
--         fname_wr_done <= '0';
--       elsif(fname_lcd_counter = (x"C"-x"1")) then
--         fname_wr_done <= '1';
--       end if;
--     end if;
--   end process;

  lcdc_cmd <= lcdc_command;
  filename_lcd_refresh: process (clk, reset)  -- My thinking
  begin
    if (reset = reset_state) then
      lcdc_command <= LCD_NOP;
    elsif (clk'event and clk = clk_polarity) then
      if (fname_wr_done = '1' and lcdc_busy = '0') then
        lcdc_command <= LCD_REFRESH;
      else
        lcdc_command <= LCD_NOP;
      end if;
    end if;
  end process;
--   filename_lcd_refresh: process (clk, reset) -- Given in manual
--   begin
--     if (reset = reset_state) then
--       lcdc_command <= LCD_NOP;
--     elsif (clk'event and clk = clk_polarity) then
--       if (lcdc_command = LCD_REFRESH;) then
--         lcdc_command <= LCD_NOP;
--       elsif (fname_wr_done = '1' and lcdc_busy = '0') then
--         lcdc_command <= LCD_REFRESH;
--       end if;
--     end if;
--   end process;

end architecture;

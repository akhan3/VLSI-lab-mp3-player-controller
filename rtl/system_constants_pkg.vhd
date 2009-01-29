-------------------------------------------------------------------------------
-- Project                    : MP3 Player Controller
-- Package                    : system_constants_pkg
-- Package description        : defines supplemental constants and the basic
--                              address mapping
--
-- Author                     : AAK
-- Created on                 : 02 Jan, 2009
-- Last revision on           : 15 Jan, 2009
-- Last revision description  : Added AC97 hardware commands
-------------------------------------------------------------------------------

-- Purpose:


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

package system_constants_pkg is

  constant USECHIPSCOPE : boolean := true;
  constant reset_state  : std_logic := '1';
  constant clk_polarity : std_logic := '1';


  constant HW_BASE_ADDR : std_logic_vector(31 downto 0) := x"40000000";

  constant SYS_STATUS_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"00000000";

  constant SBUF_STATUS_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"00008000";
  constant SBUF_DATA_WRITE_OFFSET  : std_logic_vector(31 downto 0) := x"00008004";
  --the mask should have the same bit number the SBUF_SIZE_DWORDS
  constant SBUF_DCOUNT_MASK        : std_logic_vector(31 downto 0) := x"00003FFF";
  constant SBUF_SIZE_DWORDS        : std_logic_vector(31 downto 0) := x"00002000";

  constant DBUF_STATUS_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"00009000";
  constant DBUF_DATA_READ_OFFSET   : std_logic_vector(31 downto 0) := x"00009004";
  --the mask should have the same bit number the DBUF_SIZE_DWORDS
  constant DBUF_DCOUNT_MASK        : std_logic_vector(31 downto 0) := x"00000FFF";
  constant DBUF_SIZE_DWORDS        : std_logic_vector(31 downto 0) := x"00000800";

  constant SYS_RESET_MASK : std_logic_vector(31 downto 0) := x"80000000";

  constant SAMPLERATE_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"0000a000";
  constant SAMPLEFMT_ADDR_OFFSET  : std_logic_vector(31 downto 0) := x"0000a004";


  --for LCDC
  constant oe_act : std_logic := '0';

  --for fio commands
  constant FIO_BASE_ADDR            : std_logic_vector(31 downto 0) := x"40000000";
  constant FIO_STATUS_ADDR_OFFSET   : std_logic_vector(31 downto 0) := x"0000b000";
  constant FIO_CMD_STATUS_MASK      : std_logic_vector(31 downto 0) := x"80000000";
  constant FIO_CMD_FILENEXT_MASK    : std_logic_vector(31 downto 0) := x"40000000";
  constant FIO_CMD_FILEPREV_MASK    : std_logic_vector(31 downto 0) := x"20000000";
  constant FIO_CMD_READ_MASK        : std_logic_vector(31 downto 0) := x"10000000";
  constant FIO_CMD_OPEN_MASK        : std_logic_vector(31 downto 0) := x"08000000";
  constant FIO_CMD_DATASIZE_MASK    : std_logic_vector(31 downto 0) := x"04000000";
  constant FIO_DATA_SIZE_MASK       : std_logic_vector(31 downto 0) := x"000000FF";
  constant FIO_FILENAME_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"0000c000";
  constant FIO_DATA_ADDR_OFFSET     : std_logic_vector(31 downto 0) := x"0000d000";

  constant AUDIO_CMD_READ_OFFSET : std_logic_vector(31 downto 0) := x"0000e000";
  constant AUDIO_CMD_WRITE_OFFSET : std_logic_vector(31 downto 0) := x"0000e010";
  constant AUDIO_CTRL_REG_OFFSET : std_logic_vector(31 downto 0) := x"0000e004";
  constant SBUF_DATA_READ_OFFSET : std_logic_vector(31 downto 0) := x"0000f000";


  constant LCD_STATUS_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"00080000";
  constant CCRM_BASE_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"00090000";
  constant CHRM_BASE_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"000a0000";
  constant LCD_CFG_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"000b0000";


----------------------------------------------------------------------------------
-- My constants
----------------------------------------------------------------------------------
  constant  CLK_PERIOD                : natural := 31250000;

-- Hard configuration constants
  constant  FORCE_STARTUP_ENABLE      : boolean := false;   -- should be false in final release
  constant  INIT_WAIT_MILLISEC        : natural := 6000;

-- Scrolling configuration constants
  constant  SCROLL_TIMEOUT_MILLISEC_0 : natural := 200;     -- fastest ~ minium scroll delay
  constant  SCROLL_TIMEOUT_MILLISEC_1 : natural := 400;
  constant  SCROLL_TIMEOUT_MILLISEC_2 : natural := 600;
  constant  SCROLL_TIMEOUT_MILLISEC_3 : natural := 800;     -- slowest ~ maximum scroll delay

-- LCD Commands
  constant  LCD_NOP       : std_logic_vector(1 downto 0) := "00";
  constant  LCD_CLEAR     : std_logic_vector(1 downto 0) := "01";
  constant  LCD_REFRESH   : std_logic_vector(1 downto 0) := "10";

-- Keyboard Scan Codes
  constant KEY_0          : std_logic_vector(7 downto 0) := x"70";
  constant KEY_1          : std_logic_vector(7 downto 0) := x"69";
  constant KEY_2          : std_logic_vector(7 downto 0) := x"72";
  constant KEY_3          : std_logic_vector(7 downto 0) := x"7A";
  constant KEY_4          : std_logic_vector(7 downto 0) := x"6B";
  constant KEY_5          : std_logic_vector(7 downto 0) := x"73";
  constant KEY_6          : std_logic_vector(7 downto 0) := x"74";
  constant KEY_7          : std_logic_vector(7 downto 0) := x"6C";
  constant KEY_8          : std_logic_vector(7 downto 0) := x"75";
  constant KEY_9          : std_logic_vector(7 downto 0) := x"7D";
  constant KEY_ESC        : std_logic_vector(7 downto 0) := x"76";
  constant KEY_CTRL       : std_logic_vector(7 downto 0) := x"14";
  constant KEY_ALT        : std_logic_vector(7 downto 0) := x"11";
  constant KEY_BKSP       : std_logic_vector(7 downto 0) := x"66";
  constant KEY_PLUS       : std_logic_vector(7 downto 0) := x"79";
  constant KEY_MINUS      : std_logic_vector(7 downto 0) := x"7B";
  constant KEY_NUMLOCK    : std_logic_vector(7 downto 0) := x"77";
  constant KEY_ENTER      : std_logic_vector(7 downto 0) := x"5A";

-- File System Commands
  constant FIO_FILENEXT   : std_logic_vector(7 downto 0) := x"00";
  constant FIO_FILEPREV   : std_logic_vector(7 downto 0) := x"01";
  constant FIO_READ       : std_logic_vector(7 downto 0) := x"02";
  constant FIO_OPEN       : std_logic_vector(7 downto 0) := x"03";
  constant FIO_FFSEEK     : std_logic_vector(7 downto 0) := x"04";
  constant FIO_BFSEEK     : std_logic_vector(7 downto 0) := x"05";

-- AC97 Commands
  constant AC97_PAUSE     : std_logic_vector(3 downto 0) := "1001";
  constant AC97_CHANGE_VOL: std_logic_vector(3 downto 0) := "1000";
  constant AC97_VOL_MAX   : std_logic_vector(4 downto 0) := "00000";
  constant AC97_VOL_MIN   : std_logic_vector(4 downto 0) := "11111";
  constant AC97_MUTE      : std_logic := '1';
  constant AC97_UNMUTE    : std_logic := '0';

end system_constants_pkg;

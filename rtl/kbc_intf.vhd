-------------------------------------------------------------------------------
-- Project                    : MP3 Player Controller
-- Entity                     : kbc_intf
-- Entity description         :
--
-- Author                     : AAK
-- Created on                 : 02 Jan, 2009
-- Last revision on           : 12 Jan, 2009
-- Last revision description  :
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.system_constants_pkg.all;

entity kbc_intf is
  port(
    key_empty : in  std_logic;
    key_rd_ack: in  std_logic;
    key_data  : in  std_logic_vector(7 downto 0);
    key_rd    : out std_logic;
    listprev  : out std_logic;
    listnext  : out std_logic;
    play      : out std_logic;
    stop      : out std_logic;
    pause     : out std_logic;
    mute      : out std_logic;
    volinc    : out std_logic;
    voldec    : out std_logic;
    seekfwd   : out std_logic;
    seekbkw   : out std_logic
  );
end entity;

architecture arch of kbc_intf is
begin
  key_rd <= not key_empty;
  listprev  <= key_rd_ack when (key_data = KEY_8)     else '0';
  listnext  <= key_rd_ack when (key_data = KEY_2)     else '0';
  play      <= key_rd_ack when (key_data = KEY_ESC)   else '0';
  stop      <= key_rd_ack when (key_data = KEY_CTRL)  else '0';
  pause     <= key_rd_ack when (key_data = KEY_ALT)   else '0';
  mute      <= key_rd_ack when (key_data = KEY_BKSP)  else '0';
  volinc    <= key_rd_ack when (key_data = KEY_PLUS)  else '0';
  voldec    <= key_rd_ack when (key_data = KEY_MINUS) else '0';
  seekfwd   <= key_rd_ack when (key_data = KEY_6) else '0';
  seekbkw   <= key_rd_ack when (key_data = KEY_4) else '0';

end architecture;

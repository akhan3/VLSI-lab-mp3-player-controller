library ieee;
use ieee.std_logic_1164.all;
use work.system_constants_pkg.all;

entity kbc_intf is
  port(
    empty     : in  std_logic;
    rd_ack    : in  std_logic;
    data      : in  std_logic_vector(7 downto 0);
    rd        : out std_logic;
    listprev  : out std_logic;
    listnext  : out std_logic;
    key_play  : out std_logic;
    key_stop  : out std_logic;
    key_pause : out std_logic;
    key_mute  : out std_logic;
    key_volinc: out std_logic;
    key_voldec: out std_logic
  );
end entity;

architecture arch of kbc_intf is
begin
  rd <= not empty;
  listprev    <= rd_ack when (data = KEY_8)     else '0';
  listnext    <= rd_ack when (data = KEY_2)     else '0';
  key_play    <= rd_ack when (data = KEY_ESC)   else '0';
  key_stop    <= rd_ack when (data = KEY_CTRL)  else '0';
  key_pause   <= rd_ack when (data = KEY_ALT)   else '0';
  key_mute    <= rd_ack when (data = KEY_LEFT)  else '0';
  key_volinc  <= rd_ack when (data = KEY_PLUS)  else '0';
  key_voldec  <= rd_ack when (data = KEY_MINUS) else '0';
end arch;

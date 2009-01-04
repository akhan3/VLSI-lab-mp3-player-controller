library ieee;
use ieee.std_logic_1164.all;
use work.system_constants_pkg.all;

entity kbc_intf is
  port(
    empty     : in  std_logic;
    rd_ack    : in  std_logic;
    data      : in  std_logic_vector(7 downto 0);
    rd        : out std_logic;
    listnext  : out std_logic;
    listprev  : out std_logic
  );
end entity;

architecture arch of kbc_intf is
  constant KEY_2 : std_logic_vector(7 downto 0) := x"72";
  constant KEY_8 : std_logic_vector(7 downto 0) := x"75";
begin
  listnext <= rd_ack when (data = KEY_2) else '0';
  listprev <= rd_ack when (data = KEY_8) else '0';
  rd <= not empty;
end arch;

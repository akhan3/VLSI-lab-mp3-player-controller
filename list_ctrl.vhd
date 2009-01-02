library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
-- use ieee.std_logic_unsigned.all;
library work;
use work.system_constants_pkg.all;

entity list_ctrl is
  port(
    clk         : in  std_logic;
    reset       : in  std_logic;
    listnext    : in  std_logic;
    listprev    : in  std_logic;
    gnt         : in  std_logic;
    busy        : in  std_logic;
    info_ready  : in  std_logic;
    req         : out std_logic;
    busi        : out std_logic_vector(7 downto 0);
    busiv       : out std_logic;
    ctrl        : out std_logic;
    info_start  : out std_logic
  );
end entity;

architecture arch of list_ctrl is
  constant FILENEXT : std_logic_vector(7 downto 0) := x"00";
  constant FILEPREV : std_logic_vector(7 downto 0) := x"01";
  type state_type is (IDLE, WRDY, WINFO);
  signal state, next_state: state_type;
  signal busi_le : std_logic;
begin

  state_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      state <= IDLE;
    elsif (clk'event and clk = clk_polarity) then
      state <= next_state;
    end if;
  end process;

  next_state_comb_logic: process (state, listnext, listprev, gnt, busy, info_ready)
  begin
    case state is
      when IDLE =>
        if (listnext = '1' or listprev = '1') then
          next_state <= WRDY;
        else
          next_state <= IDLE;
        end if;
      when WRDY =>
        if (gnt = '1' and busy = '0') then
          next_state <= WINFO;
        else
          next_state <= WRDY;
        end if;
      when WINFO =>
        if (info_ready = '1') then
          next_state <= IDLE;
        else
          next_state <= WINFO;
        end if;
      when others =>
          next_state <= IDLE;
    end case;
  end process;

  output_comb_logic: process (state, listnext, listprev, gnt, busy, info_ready)
  begin
    req <= '0';
    busi_le <= '0';
    busiv <= '0';
    ctrl <= '0';
    info_start <= '0';
    case state is
      when IDLE =>
        if (listnext = '1' or listprev = '1') then
          busi_le <= '1';
          req <= '1';
        end if;
      when WRDY =>
        req <= '1';
        if (gnt = '1' and busy = '0') then
          busiv <= '1';
          ctrl <= '1';
          info_start <= '1';
        end if;
      when WINFO =>
        if (info_ready = '1') then
        else
          req <= '1';
        end if;
    end case;
  end process;

  busi_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      busi <= x"00";
    elsif (clk'event and clk = clk_polarity) then
      if (busi_le = '1') then
        if (listnext = '1') then
          busi <= FILENEXT;
        elsif (listprev = '1') then
          busi <= FILEPREV;
        end if;
      end if;
    end if;
  end process;

end architecture;
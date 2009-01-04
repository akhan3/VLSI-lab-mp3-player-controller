library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
-- use ieee.std_logic_unsigned.all;
library work;
use work.system_constants_pkg.all;

entity arbiter_mux is
  generic(
    M : integer := 10;  -- bus width {ctrl, busiv, busi width}
    N : integer := 3    -- number of masters
  );
  port(
    clk     : in  std_logic;
    reset   : in  std_logic;
    bus_in  : in  std_logic_vector(M*N-1 downto 0); -- M-bit bus input from N masters
    bus_out : out std_logic_vector(M-1 downto 0);   -- M-bit bus output to FIO
    req     : in  std_logic_vector(N-1 downto 0);   -- request signal from N masters
    gnt     : out std_logic_vector(N-1 downto 0)    -- grant signal to N masters
  );
end entity;

architecture arch of arbiter_mux is
  signal gnt_le   : std_logic;
  signal gnt_next : std_logic_vector(N-1 downto 0);
  signal gnt_reg  : std_logic_vector(N-1 downto 0);
  signal req_mask : std_logic_vector(N-1 downto 0);
  signal ored1    : std_logic;
  signal ored2    : std_logic;
  signal ored3    : std_logic_vector(M-1 downto 0);
begin


-- arbitration_logic using generate statements
  ored1 <= '0';
  each_master1: for i in 0 to N-1 generate
    catch_zero: if (i /= 0) generate
      big_or_gate: for j in 0 to i-1 generate
        ored1 <= ored1 or req(j);
      end generate;
    end generate;
  gnt_next(i) <= not(ored1) and req(i);
  end generate;

-- grant load enable signal
  req_mask <= req and gnt_reg;
  ored2 <= '0';
  each_master2: for i in 0 to N-1 generate
    ored2 <= ored2 or req_mask(i);
  end generate;
  gnt_le <= not ored2;

-- grant signal register
  gnt <= gnt_reg;
  gnt_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      gnt_reg <= "0";
    elsif (clk'event and clk = clk_polarity) then
      if (gnt_le = '1') then
        gnt_reg <= gnt_next;
      end if;
    end if;
  end process;

-- Multiplexer
  ored3 <= "0";
    each_bit: for j in 0 to M-1 generate
  begin
    each_master3: for i in 0 to N-1 generate
      variable ored : std_logic;
    begin
      ored := ored or (gnt_reg(i) and bus_in(i*M+j));
    end generate;
  end generate;
  bus_out <= ored3;


end architecture;
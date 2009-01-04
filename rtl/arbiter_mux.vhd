library ieee;
use ieee.std_logic_1164.all;
use work.system_constants_pkg.all;

entity arbiter_mux is
  port(
    clk     : in  std_logic;
    reset   : in  std_logic;
    bus_in  : in  std_logic_vector(3*10-1 downto 0);  -- 10-bit bus input from 3 Masters
    req     : in  std_logic_vector(2 downto 0);       -- request signal from 3 Masters
    gnt     : out std_logic_vector(2 downto 0);       -- grant signal to 3 Masters
    fio_bus : out std_logic_vector(9 downto 0)        -- 10-bit bus output to FIO
  );
end entity;

architecture arch of arbiter_mux is
  signal gnt_le   : std_logic;
  signal gnt_next : std_logic_vector(2 downto 0);
  signal gnt_reg  : std_logic_vector(2 downto 0);
  signal req_mask : std_logic_vector(2 downto 0);
begin

-- Arbitration Logic
  gnt_next(0) <= req(0);
  gnt_next(1) <= not(req(0))           and req(1);
  gnt_next(2) <= not(req(0) or req(1)) and req(2);

-- grant load enable signal
  req_mask <= req and gnt_reg;
  gnt_le <= not(req_mask(0) or req_mask(1) or req_mask(2));

-- grant signal register
  gnt <= gnt_reg;
  gnt_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      gnt_reg <= "000";
    elsif (clk'event and clk = clk_polarity) then
      if (gnt_le = '1') then
        gnt_reg <= gnt_next;
      end if;
    end if;
  end process;

-- Multiplexer
  with gnt_reg select
    fio_bus <=  bus_in(9 downto 0)    when "001",
                bus_in(19 downto 10)  when "010",
                bus_in(29 downto 20)  when "100",
                bus_in(9 downto 0)    when others;

end architecture;
library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
-- use ieee.std_logic_unsigned.all;
library work;
use work.system_constants_pkg.all;

entity arbiter_mux is
  port(
    clk       : in  std_logic;
    reset     : in  std_logic;
    lst_bus   : in  std_logic_vector(9 downto 0); -- bus input from List FSM
    ply_bus   : in  std_logic_vector(9 downto 0); -- bus input from Play FSM
    mon_bus   : in  std_logic_vector(9 downto 0); -- bus input from Monitor FSM
    lst_req   : in  std_logic;                    -- request signal from List FSM
    ply_req   : in  std_logic;                    -- request signal from Play FSM
    mon_req   : in  std_logic;                    -- request signal from Monitor FSM
    lst_gnt   : out std_logic;                    -- grant signal to List FSM
    ply_gnt   : out std_logic;                    -- grant signal to Play FSM
    mon_gnt   : out std_logic;                    -- grant signal to Monitor FSM
    fio_bus   : out std_logic_vector(9 downto 0)  -- bus output to FIO
  );
end entity;

architecture arch of arbiter_mux is
  signal gnt_le   : std_logic;
  signal lst_gnt_next, ply_gnt_next, mon_gnt_next : std_logic;
  signal lst_gnt_reg,  ply_gnt_reg,  mon_gnt_reg  : std_logic;
  signal lst_req_mask, ply_req_mask, mon_req_mask : std_logic;
  signal mux_sel  : std_logic_vector(2 downto 0);
begin

-- Arbitration Logic
  lst_gnt_next <= lst_req;
  ply_gnt_next <= not(lst_req)            and ply_req;
  mon_gnt_next <= not(lst_req or ply_req) and mon_req;

-- grant load enable signal
  lst_req_mask <= lst_req and lst_gnt_reg;
  ply_req_mask <= ply_req and ply_gnt_reg;
  mon_req_mask <= mon_req and mon_gnt_reg;
  gnt_le <= not(lst_req_mask or ply_req_mask or mon_req_mask);

-- grant signal register
  lst_gnt <= lst_gnt_reg;
  ply_gnt <= ply_gnt_reg;
  mon_gnt <= mon_gnt_reg;
  gnt_register: process (clk, reset)
  begin
    if (reset = reset_state) then
      lst_gnt_reg <= '0';
      ply_gnt_reg <= '0';
      mon_gnt_reg <= '0';
    elsif (clk'event and clk = clk_polarity) then
      if (gnt_le = '1') then
        lst_gnt_reg <= lst_gnt_next;
        ply_gnt_reg <= ply_gnt_next;
        mon_gnt_reg <= mon_gnt_next;
      end if;
    end if;
  end process;

-- Multiplexer
  mux_sel <= lst_gnt_reg & ply_gnt_reg & mon_gnt_reg;
  with (mux_sel) select
    fio_bus <=  lst_bus when "100",
                ply_bus when "010",
                mon_bus when "001",
                lst_bus when others;

end architecture;
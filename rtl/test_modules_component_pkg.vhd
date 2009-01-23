library IEEE;
use IEEE.STD_LOGIC_1164.all;

package test_modules_component_pkg is

  component ila
    port
      (
        control : in std_logic_vector(35 downto 0);
        clk     : in std_logic;
        trig0   : in std_logic_vector(255 downto 0)
        );
  end component;

  component icon
    port
      (
        control0 : out std_logic_vector(35 downto 0)
        );
  end component;

end test_modules_component_pkg;

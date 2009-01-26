--------------------------------------------------------------------------------
--     This file is owned and controlled by Xilinx and must be used           --
--     solely for design, simulation, implementation and creation of          --
--     design files limited to Xilinx devices or technologies. Use            --
--     with non-Xilinx devices or technologies is expressly prohibited        --
--     and immediately terminates your license.                               --
--                                                                            --
--     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"          --
--     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                --
--     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION        --
--     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION            --
--     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS              --
--     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                --
--     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE       --
--     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY               --
--     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                --
--     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         --
--     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        --
--     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        --
--     FOR A PARTICULAR PURPOSE.                                              --
--                                                                            --
--     Xilinx products are not intended for use in life support               --
--     appliances, devices, or systems. Use in such applications are          --
--     expressly prohibited.                                                  --
--                                                                            --
--     (c) Copyright 1995-2006 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- You must compile the wrapper file divider_core.vhd when simulating
-- the core, divider_core. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synopsys directives "translate_off/translate_on" specified
-- below are supported by XST, FPGA Compiler II, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synopsys translate_off
Library XilinxCoreLib;
-- synopsys translate_on
ENTITY divider_core IS
	port (
	clk: IN std_logic;
	aclr: IN std_logic;
	dividend: IN std_logic_VECTOR(31 downto 0);
	divisor: IN std_logic_VECTOR(31 downto 0);
	quotient: OUT std_logic_VECTOR(31 downto 0);
	remainder: OUT std_logic_VECTOR(31 downto 0);
	rfd: OUT std_logic);
END divider_core;

ARCHITECTURE divider_core_a OF divider_core IS
-- synopsys translate_off
component wrapped_divider_core
	port (
	clk: IN std_logic;
	aclr: IN std_logic;
	dividend: IN std_logic_VECTOR(31 downto 0);
	divisor: IN std_logic_VECTOR(31 downto 0);
	quotient: OUT std_logic_VECTOR(31 downto 0);
	remainder: OUT std_logic_VECTOR(31 downto 0);
	rfd: OUT std_logic);
end component;

-- Configuration specification
	for all : wrapped_divider_core use entity XilinxCoreLib.div_gen_v1_0(behavioral)
		generic map(
			divclk_sel => 1,
			exponent_width => 8,
			bias => 0,
			c_has_sclr => 0,
			latency => 1,
			c_has_ce => 0,
			c_has_aclr => 1,
			c_sync_enable => 0,
			fractional_width => 32,
			mantissa_width => 8,
			signed_b => 0,
			fractional_b => 1,
			algorithm_type => 1,
			divisor_width => 32,
			dividend_width => 32);
-- synopsys translate_on
BEGIN
-- synopsys translate_off
U0 : wrapped_divider_core
		port map (
			clk => clk,
			aclr => aclr,
			dividend => dividend,
			divisor => divisor,
			quotient => quotient,
			remainder => remainder,
			rfd => rfd);
-- synopsys translate_on

END divider_core_a;


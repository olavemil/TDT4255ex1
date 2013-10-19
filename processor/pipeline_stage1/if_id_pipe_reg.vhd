----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    12:20:15 10/19/2013
-- Design Name:
-- Module Name:    if_id_pipe_reg - behave
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity if_id_pipe_reg is
	port(
		clk			: in	STD_LOGIC;
		reset		: in	STD_LOGIC;
		if_flush	: in	STD_LOGIC; --Dunno what this is for yet, need to be found out
		haz_cntrl	: in	STD_LOGIC; --Same as above comment
		pc_in		: in	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
		pc_out		: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
		instr_in	: in	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0):
		instr_out	: out	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0)
		);
	end if_id_pipe_reg;

architecture behave of if_id_pipe_reg is
	signal switch	: STD_LOGIC := '0';
	signal CC1		: STD_LOGIC_VECTOR(63 downto 0);
	signal CC2		: STD_LOGIC_VECTOR(63 downto 0);

begin
	process(clk, reset)
	begin
		if (reset = '1') then
			CC1 <= (others => '0');
			CC2 <= (others => '0');
		elsif (rising_edge(clk)) then --Here's an assumption that the clock cycle starts with first halfperiod as positive, and not negative.
			switch <= switch nand switch;
			if (switch = '1') then
				pc_out				<= CC1(63 downto 32);
				instr_out			<= CC1(31 downto 0);
				CC2(63 downto 32)	<= pc_in;
				CC2(31 downto 0)	<= instr_in;
			else
				pc_out				<= CC2(63 downto 32);
				instr_out			<= CC2(31 downto 0);
				CC1(63 downto 32)	<= pc_in;
				CC1(31 downto 0)	<= instr_in;
			end if;
		else

		end if;

	end process;

end behave;

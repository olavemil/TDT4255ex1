library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity sign_extender is
	port(
		CLK 		: in 	STD_LOGIC;
		RESET		: in 	STD_LOGIC;
		IMMIDIATE16	: in 	STD_LOGIC_VECTOR(15 downto 0);
		IMMIDIATE32	: out	STD_LOGIC_VECTOR(31 downto 0)
	);
end sign_extender;

architecture Behavioral of sign_extender is
begin
	IMMIDIATE32 <= resize(signed(IMMIDIATE16), 32);
end Behavioral;
	

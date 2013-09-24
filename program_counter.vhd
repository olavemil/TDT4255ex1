library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;


entity program_counter is
	port(
			RESET	: in 	STD_LOGIC;
			PC_CON	: in 	STD_LOGIC;
			PC_IN	: in 	STD_LOGIC_VECTOR (IADDR_BUS-1 downto 0);
			PC_OUT	: out 	STD_LOGIC_VECTOR (IADDR_BUS-1 downto 0)
	);
end program_counter;

architecture Behavioral of program_counter is
	
	signal REG : STD_LOGIC_VECTOR (IADDR_BUS-1 downto 0);

begin
	PC_OUT <= REG;
	
	UPDATE_PC: process(PC_CON)
	begin
		--some reset code...
		if rising_edge(PC_CON) then
			REG <= PC_IN;
		end if;
	end process;

end Behavioral;



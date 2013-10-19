library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;


entity status_register is
	port (
			RESET		: in	STD_LOGIC;
			sr_w 		: in	STD_LOGIC;
			alu_flags	: in	ALU_FLAGS;
			alu_zero	: out	STD_LOGIC
		);
end status_register;

architecture Behavioral of status_register is
	
	signal REG : STD_LOGIC;

begin
	alu_zero <= REG;
	
	UPDATE_SR: process(sr_w)
	begin
		if falling_edge(sr_w) then
			REG <= alu_flags.Zero;
		end if;
	end process;

end Behavioral;


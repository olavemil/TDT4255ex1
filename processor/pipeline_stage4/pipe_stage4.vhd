library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.MIPS_CONSTANT_PKG.all;

entity pipe_stage4 is
	port(
		clk					: in	STD_LOGIC;
		wb_in				: in	STD_LOGIC;
		wb_out				: out	STD_LOGIC;
		
		alu_result_in		: in	STD_LOGIC_VECTOR(N-1 downto 0);
		alu_result_out		: out	STD_LOGIC_VECTOR(N-1 downto 0);
		
		reg_r_in			: in	STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);
		reg_r_out			: out	STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0)
	);
end pipe_stage4;

architecture behave of pipe_stage4 is

begin
	registers : process(clk)
		begin
			if rising_edge(clk) then
				wb_out			<= wb_in;
				reg_r_out		<= reg_r_in;
				alu_result_out	<= alu_result_in;
			end if;
		end process;
end behave;


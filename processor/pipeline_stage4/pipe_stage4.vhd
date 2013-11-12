library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.MIPS_CONSTANT_PKG.all;

entity pipe_stage4 is
	port(
		clk				: in	STD_LOGIC;
		--from stage 3
		wb_in			: in	STD_LOGIC;
		reg_r_in		: in	STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);
		dmem_data_in	: in	STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);
		alu_result_in	: in	STD_LOGIC_VECTOR(N-1 downto 0);

		--to stage 5
		wb_out			: out	STD_LOGIC;
		reg_r_out		: out	STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);
		dmem_data_out	: out	STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);
		alu_result_out	: out	STD_LOGIC_VECTOR(N-1 downto 0)
	);
end pipe_stage4;

architecture behave of pipe_stage4 is

begin
	registers : process(clk, dmem_data_in)
		begin
			if rising_edge(clk) then
				wb_out			<= wb_in;
				reg_r_out		<= reg_r_in;
				alu_result_out	<= alu_result_in;
			end if;
			dmem_data_out	<= dmem_data_in;
		end process;
end behave;


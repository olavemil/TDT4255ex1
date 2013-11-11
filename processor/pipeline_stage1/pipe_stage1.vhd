library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity pipe_stage1 is
	port(
		clk					: in	STD_LOGIC;
		reset				: in	STD_LOGIC;
		processor_enable	: in	STD_LOGIC;
		if_stall			: in	STD_LOGIC;
		if_flush			: in	STD_LOGIC;
		--From stage 2
		pc_in				: in	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		branch_enable		: in	STD_LOGIC;
		pc_we				: in	STD_LOGIC;
		--To imem
		instr_data			: in	STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);
		--To stage 2
		instr_addr			: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		pc_inc_out			: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		instruction			: out	STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0)
	);
end pipe_stage1;

architecture behave of pipe_stage1 is
	signal pc_inc, pc_inc_reg, pc_reg	: STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
	signal instr_reg					: STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);

	component adder
	generic (N: natural);
		port(
			X		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			Y		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			CIN		: in	STD_LOGIC;
			COUT	: out	STD_LOGIC;
			R		: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component;
begin

	pc_incrementer : adder
	generic map(N => IADDR_BUS)
	port map(
		X	=> pc_reg,
		Y 	=> ZERO32b(IADDR_BUS-1 downto 0),
		CIN	=> '1',
		R 	=> pc_inc
	);

	program_counter_register : process(clk, pc_in, pc_reg)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				pc_reg	<= X"00000000";
			elsif pc_we = '1' and processor_enable = '1' then
				if expression then

				end if ;
				pc_reg	<= pc_in;
			else
				pc_reg	<= pc_reg;
			end if;
		end if;
	end process;

	if_id_register : process(clk, processor_enable, if_stall, if_flush, instr_reg, pc_inc_reg)
	begin
		if rising_edge(clk) and processor_enable = '1' then
			if if_flush = '1' then
				pc_inc_reg	<= pc_inc_reg;
				instr_reg	<= ZERO32b(IDATA_BUS-1 downto 0);
			elsif if_stall = '1' then
				pc_inc_reg	<= pc_inc_reg;
				instr_reg	<= instr_reg;
			else
				pc_inc_reg	<= pc_inc;
				instr_reg	<= instr_data;
			end if;
		end if;
	end process;

	instr_addr	<= pc_reg;
	pc_inc_out	<= pc_inc_reg;
	instruction	<= instr_reg;
end behave;

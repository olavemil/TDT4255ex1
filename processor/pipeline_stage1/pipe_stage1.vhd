library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity pipe_stage1 is
	port(
		clk					: in	STD_LOGIC;
		reset				: in	STD_LOGIC;
		--Horrible things
		if_stall			: in	STD_LOGIC;
		if_flush_sig		: in	STD_LOGIC;
		--From stage 2
		pc_in				: in	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		pc_we				: in	STD_LOGIC;
		--To stage 2
		pc_inc_out			: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		--TO IMEM
		pc_reg_out			: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0)
	);
end pipe_stage1;

architecture behave of pipe_stage1 is
	-- Program counter signals
	signal pc_inc, pc_inc_reg, pc_reg	: STD_LOGIC_VECTOR(N-1 downto 0);
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
	generic map(N => 32)
	port map(
		X	=> pc_reg,
		Y 	=> ZERO32b,
		CIN	=> '1',
		R 	=> pc_inc
	);

	program_counter_register : process(clk, pc_in, pc_reg)
	begin
		if rising_edge(clk) then
			if pc_we = '1' then
				pc_reg <= pc_in;
			else
				pc_reg <= pc_reg;
			end if;
		end if;
	end process;
	pc_reg_out	<= pc_reg;


	if_id_register : process(clk, if_stall, if_flush_sig)
	begin
		if rising_edge(clk) then
			if if_stall = '0' then
				pc_inc_reg <= pc_inc;
			else
				pc_inc_reg <= pc_inc_reg;
			end if;
		end if;
	end process;
	pc_inc_out	<= pc_inc_reg;
end behave;

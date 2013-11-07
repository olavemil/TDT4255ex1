library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity pipe_stage1 is
	port(
		clk					: in	STD_LOGIC;
		reset				: in	STD_LOGIC;
		--From stage 2
		branch_target		: in	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		branch_enable		: in	STD_LOGIC;
		if_flush_sig		: in	STD_LOGIC;
		pc_we				: in	STD_LOGIC;
		--To stage 2
		pc_out				: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0)
	);
end pipe_stage1;

architecture behave of pipe_stage1 is
	-- Program counter signals
	signal pc_inc, pc_reg, pc_mux	: STD_LOGIC_VECTOR(N-1 downto 0);
	component adder
	generic (N: natural)   
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
	generic (N: natural)    
	port map(
		X	=> pc_reg,
		Y 	=> ZERO32b,
		CIN	=> '1',
		R 	=> pc_inc
	);

	PC_SRC_MUX : process(branch_enable, pc_inc, branch_target)
	begin
		if (branch_enable = '1') then
			pc_mux <= pc_inc;
		else
			pc_mux <= branch_target;
		end if;
	end process;

	program_counter : process(clk, pc_mux, pc_reg)
	begin
		if (rising_edge(clk)) then
			if pc_we = '1' then
				pc_reg <= pc_mux;
			else
				pc_reg <= pc_reg;
			end if;
		end if;
	end process;
	
	pc_out <= pc_reg;
end behave;


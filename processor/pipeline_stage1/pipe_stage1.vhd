library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;

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
		instr_data_in		: in	STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);
		--To stage 2
		instr_addr			: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		pc_inc_out			: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		instruction			: out	STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0)
	);
end pipe_stage1;

architecture behave of pipe_stage1 is
	signal pc_inc		: STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0) := (others => '0');
	signal pc_inc_reg	: STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0) := (others => '0');
	signal pc_reg		: STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0) := (others => '0');
	signal instr_reg	: STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);
	signal instr_data	: STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);

begin
	--Increments the value coming from pc_reg, returns it as pc_inc(remented)
	pc_inc <= std_logic_vector(unsigned(pc_reg) + 1);

	program_counter_register : process(clk, pc_in, pc_reg)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				pc_reg	<= (others => '0');
			elsif pc_we = '1' and processor_enable = '1' then
				if branch_enable = '1' then
					pc_reg	<= pc_in;
				else
					pc_reg	<= pc_inc;
				end if;
			else
				pc_reg	<= pc_reg;
			end if;
		end if;
	instr_addr	<= pc_reg;
	end process;

	flush_instruction : process(if_flush, instr_data_in)
	begin
		if if_flush = '1' then
			instr_data <= (others => '0');
		else
			instr_data <= instr_data_in;
		end if;
	end process;
	if_id_register : process(clk, processor_enable, if_stall, if_flush, instr_reg, pc_inc_reg)
	begin
		if rising_edge(clk)then
			if reset = '1' then --RESET
				pc_inc_reg <= (others => '0');
				instr_reg	<= ZERO32b(IDATA_BUS-1 downto 0);
			elsif processor_enable = '1' then
				if if_flush = '1' then --FLUSH
					pc_inc_reg	<= pc_inc_reg;
					instr_reg	<= ZERO32b(IDATA_BUS-1 downto 0);
				elsif if_stall = '1' then --STALL
					pc_inc_reg	<= pc_inc_reg;
					instr_reg	<= instr_reg;
				else --NORMAL OPERATION
					pc_inc_reg	<= pc_inc;
					instr_reg	<= instr_data;
				end if;
			else
				pc_inc_reg	<= pc_inc_reg;
				instr_reg	<= instr_reg;
			end if;
		end if;
	end process;
	pc_inc_out	<= pc_inc_reg;
	instruction	<= instr_reg;
end behave;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity hazard_detection_unit is
	port(
		clk					: in STD_LOGIC;
		reset				: in STD_LOGIC;
		stage1_rs			: in STD_LOGIC_VECTOR(4 downto 0);
		stage1_rt			: in STD_LOGIC_VECTOR(4 downto 0);
		stage2_rt			: in STD_LOGIC_VECTOR(4 downto 0);
		mem_read			: in STD_LOGIC;
		 --Also stage1 programcounter stall when equal to zero
		pc_wr_enb			: out STD_LOGIC;
		if_id_stall			: out STD_LOGIC;
		nops				: out STD_LOGIC
	);
end hazard_detection_unit;

architecture behave of hazard_detection_unit is
	type HDUstate is (STALL, RUN);
	signal state, next_state : HDUstate;

begin
	hdu : process(mem_read, stage2_rt, stage1_rt, stage1_rs)
	begin
		if (mem_read = '1') and ((stage2_rt = stage1_rt) or (stage2_rt = stage1_rs)) then --Load uses same register in stage2 as stage3 is about to use
			pc_wr_enb	<= '0';
			if_id_stall	<= '1';
			nops		<= '1';
		else
			pc_wr_enb	<= '1';
			if_id_stall	<= '0';
			nops		<= '0';
		end if;
	end process;
	
--	HDU_STATE_MACHINE : process(clk)
--	begin
--		if rising_edge(clk) then
--			if reset = '1' then
--				next_state	<= RUN;
--				pc_wr_enb	<= '0';
--				if_id_stall	<= '0';
--				nops		<= '0';
--			else
--				state <= next_state;
--
--				case state is
--					when RUN =>
--						pc_wr_enb			<= '1';
--					when STALL =>
--						pc_wr_enb			<= '0';
--						next_state			<= RUN;
--				end case;
--
--				--Implementation of load stall logic
--				if mem_read = '1' and  --Load opcode
--					((stage2_rt = stage1_rt) or (stage2_rt = stage1_rs)) then --Load uses same register in stage2 as stage3 is about to use
--					next_state <= STALL;
--				end if;
--			end if ;
--		end if;
--	end process;
end behave;

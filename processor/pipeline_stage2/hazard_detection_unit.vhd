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
		mem_read			: in STD_LOGIC_VECTOR(5 downto 0);
		--Flush the rest of the pipeline (failed branch situations)
		flush_activate		: out STD_LOGIC;
		 --Also stage1 programcounter stall when equal to zero
		pc_wr_enb			: out STD_LOGIC;
		--Stage1 output flush when 1 (AKA flush the incoming pc_value from the inpt of stage2)
		stage1_outpt_flush	: out STD_LOGIC
	);
end hazard_detection_unit;

architecture behave of hazard_detection_unit is
	type HDUstate is (STALL, FLUSH, RUN);
	signal state, next_state : HDUstate;

begin

	HDU_STATE_MACHINE : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				next_state			<= RUN;
				pc_wr_enb			<= '0';
				flush_activate		<= '0';
				stage1_outpt_flush	<= '0';
			else
				state <= next_state;

				case state is
					when RUN =>
						pc_wr_enb			<= '1';
						flush_activate		<= '0';
						stage1_outpt_flush	<= '0';
					when STALL =>
						pc_wr_enb			<= '0';
						flush_activate		<= '0';
						stage1_outpt_flush	<= '1';
						next_state			<= RUN;
					when FLUSH => --TODO
						--pc_wr_enb			<= '0';
						--flush_activate		<= '1';.
						--stage1_outpt_flush	<= 'U';
						next_state			<= RUN;
				end case;

				--Implement branch logic to see if the next state should be a flush
				--if 0 then
					--blabla
				--end if;

				--Implementation of load stall logic
				if mem_read = "1" and --Load opcode
					(stage2_rt = stage1_rt) or (stage2_rt = stage1_rs) then --Load uses same register in stage1 as stage3 is about to use
					next_state <= STALL;
				end if;
			end if ;
		end if;
	end process;
end behave;

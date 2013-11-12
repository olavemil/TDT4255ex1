library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity control_unit is
	port(
		CLK 		: in 	STD_LOGIC;
		RESET		: in 	STD_LOGIC;
		OpCode		: in	STD_LOGIC_VECTOR (31 downto 26);
		ALUOp		: out	ALU_OP;
		RegDst		: out	STD_LOGIC;
		Branch		: out	STD_LOGIC;
		MemtoReg	: out	STD_LOGIC;
		MemWrite	: out	STD_LOGIC;
		ALUSrc		: out	STD_LOGIC;
		RegWrite	: out	STD_LOGIC;
		Jump		: out	STD_LOGIC
		--control write enable for register file is the same as RegWrite?
	);
end control_unit;

architecture Behavioral of control_unit is

begin

	ALU_STATE_MACHINE: process(CLK, RESET, OpCode)

	begin
			if reset = '1' then

				RegDst		<= '0';
				Branch		<= '0';
				MemtoReg	<= '0';
				MemWrite	<= '0';
				ALUSrc		<= '0';
				RegWrite	<= '0';
				Jump		<= '0';
			else
				case OpCode is
					when "000000" =>	--R-instruction
						RegDst		<= '1';
						Branch		<= '0';
						MemtoReg	<= '0';

						ALUOp		<= ALUOP_FUNC;

						MemWrite	<= '0';
						ALUSrc		<= '0';
						RegWrite	<= '1';
						Jump		<= '0';

					when "000100" =>	--Branch opcode
						RegDst		<= '0';
						Branch		<= '1';
						MemtoReg	<= '0';

						ALUOp		<= ALUOP_BRANCH;

						MemWrite	<= '0';
						ALUSrc		<= '0';
						RegWrite	<= '0';
						Jump		<= '0';

					when "100011" =>	--Load word
						RegDst		<= '0';
						Branch		<= '0';
						MemtoReg	<= '1';

						ALUOp		<= ALUOP_LOAD_STORE;

						MemWrite	<= '0';
						ALUSrc		<= '1';
						RegWrite	<= '1';
						Jump		<= '0';
					when "101011" =>	--Store word
						RegDst		<= '0';
						Branch		<= '0';
						MemtoReg	<= '0';

						ALUOp		<= ALUOP_LOAD_STORE;

						MemWrite	<= '1';
						ALUSrc		<= '1';
						RegWrite	<= '0';
						Jump		<= '0';

					when "001000" =>	--Load immidiate. (Implemented as add immidiate where you add with the zero register)
						RegDst		<= '0';
						Branch		<= '0';
						MemtoReg	<= '0';

						ALUOp		<= ALUOP_LDI;

						MemWrite	<= '0';
						ALUSrc		<= '1';
						RegWrite	<= '1';
						Jump		<= '0';
					when "000010" =>	--Jump
						RegDst		<= '0';
						Branch		<= '0';
						MemtoReg	<= '0';

						MemWrite	<= '0';
						ALUSrc		<= '0';
						RegWrite	<= '0';
						Jump		<= '1';
					when others =>
				end case;
		end if;
	end process;
end Behavioral;

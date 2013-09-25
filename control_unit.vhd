library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity control_unit is
	port(
		CLK 		: in 	STD_LOGIC;
		RESET		: in 	STD_LOGIC;
		OpCode		: in	STD_LOGIC_VECTOR (5 downto 0);
		ALUOp		: out	ALU_OP_INPUT;
		RegDst		: out 	STD_LOGIC;
		Branch		: out 	STD_LOGIC;
		MemRead		: out 	STD_LOGIC;
		MemtoReg	: out 	STD_LOGIC;
		MemWrite	: out 	STD_LOGIC;
		ALUSrc		: out 	STD_LOGIC;
		RegWrite	: out 	STD_LOGIC;
		Jump		: out 	STD_LOGIC;
		PCWriteEnb	: out 	STD_LOGIC;
		SRWriteEnb	: out 	STD_LOGIC
		--control write enable for register file is the same as RegWrite?
	);
end control_unit;

architecture Behavioral of control_unit is

	type ALUstate is (ALU_FETCH, ALU_EXE, READ_STALL, WRITE_STALL);
	Signal state : ALUstate;

begin

	ALU_STATE_MACHINE: process(CLK, RESET, OpCode)
		
	begin
		if rising_edge(CLK) then
			if reset = '1' then
				state 		<= ALU_FETCH;
				
				RegDst		<= '0';
				Branch		<= '0';
				MemRead		<= '0';
				MemtoReg		<= '0';
				MemWrite		<= '0';
				ALUSrc		<= '0';
				RegWrite		<= '0';
				Jump			<= '0';
				PCWriteEnb	<= '0';
				SRWriteEnb	<= '0';
			else
				case state is
					when ALU_FETCH =>
						state 	<= ALU_EXE;
						PCWriteEnb	<= '0';

					when ALU_EXE =>
						PCWriteEnb 	<= '1';
						case OpCode is
							when "000000" =>	--R-instruction
								RegDst		<= '1';
								Branch		<= '0';
								MemRead		<= '0';
								MemtoReg		<= '0';

								ALUOp.Op0	<= '0';
								ALUOp.Op1	<= '1';
								ALUOp.Op2	<= '0';

								MemWrite		<= '0';
								ALUSrc		<= '0';
								RegWrite		<= '1';
								Jump			<= '0';
								SRWriteEnb	<= '0';
								
								state 		<= ALU_FETCH;
							
							when "000100" =>	--Branch opcode
								RegDst		<= '0';
								Branch		<= '1';
								MemRead		<= '0';
								MemtoReg		<= '0';

								ALUOp.Op0	<= '1';
								ALUOp.Op1	<= '0';
								ALUOp.Op2	<= '0';

								MemWrite		<= '0';
								ALUSrc		<= '0';
								RegWrite		<= '0';
								Jump			<= '0';
								SRWriteEnb	<= '1';	--setting the zero flag if equal
								
								state 		<= ALU_FETCH;

							when "100011" =>	--Load word
								RegDst		<= '0';
								Branch		<= '0';
								MemRead		<= '1';
								MemtoReg		<= '1';

								ALUOp.Op0	<= '0';
								ALUOp.Op1	<= '0';
								ALUOp.Op2	<= '0';

								MemWrite		<= '0';
								ALUSrc		<= '1';
								RegWrite		<= '0';	--Have to wait until data has been updated
								Jump			<= '0';
								SRWriteEnb	<= '0';	

								state 		<= READ_STALL;
							when "101011" =>	--Store word
								RegDst		<= '0';
								Branch		<= '0';
								MemRead		<= '0';
								MemtoReg		<= '0';

								ALUOp.Op0	<= '0';
								ALUOp.Op1	<= '0';
								ALUOp.Op2	<= '0';

								MemWrite		<= '1';
								ALUSrc		<= '1';
								RegWrite		<= '0';
								Jump			<= '0';
								SRWriteEnb	<= '0';	

								state 		<= WRITE_STALL;
							when "001000" =>	--Load immidiate. (Implemented as add immidiate where you add with the zero register)
								RegDst		<= '0';
								Branch		<= '0';
								MemRead		<= '0';
								MemtoReg		<= '0';

								ALUOp.Op0	<= '1';
								ALUOp.Op1	<= '1';
								ALUOp.Op2	<= '0';

								MemWrite		<= '0';
								ALUSrc		<= '1';
								RegWrite		<= '1';
								Jump			<= '0';
								SRWriteEnb	<= '0';	

								state 		<= ALU_FETCH;
							when "000010" =>	--Jump
								RegDst		<= '0';
								Branch		<= '0';
								MemRead		<= '0';
								MemtoReg		<= '0';

								MemWrite		<= '0';
								ALUSrc		<= '0';
								RegWrite		<= '0';
								Jump			<= '1';
								PCWriteEnb	<= '0';
								SRWriteEnb	<= '0';	

								state 		<= ALU_FETCH;
							when others =>
								null;
						end case;
					when READ_STALL =>
						RegWrite 	<= '1';
						state 		<= ALU_FETCH;
						PCWriteEnb	<= '0';
					when WRITE_STALL =>
						state 		<= ALU_FETCH;
						PCWriteEnb	<= '0';
				end case;
			end if;
		end if;
	end process;
end Behavioral;
















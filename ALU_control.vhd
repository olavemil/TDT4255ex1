library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity ALU_control is
	port(
		CLK			: in STD_LOGIC;
		RESET		: in STD_LOGIC;
		FUNC		: in STD_LOGIC_VECTOR (5 downto 0);
		ALUOp		: in ALU_OP_INPUT;
		ALU_FUNC	: out ALU_INPUT
	);
end ALU_control;

architecture Behavioral of ALU_control is

	signal alu_op 	: STD_LOGIC_VECTOR (2 downto 0);
	signal alu_f	: STD_LOGIC_VECTOR (3 downto 0)	;
	
begin
	alu_op(0) <= ALUOp.Op0;
	alu_op(1) <= ALUOp.Op1;
	alu_op(2) <= ALUOp.Op2;
	
	ALU_FUNC.Op0 <= alu_f(0);
	ALU_FUNC.Op1 <= alu_f(1);
	ALU_FUNC.Op2 <=	alu_f(2);
	ALU_FUNC.Op3 <= alu_f(3);
	
	case alu_op is
		when "000" =>	--LW, SW, LDI
			alu_f <= "0010";
		when "001" =>	--BEQ
			alu_f <= "0110";
		when "010" =>	--Function dependent
			case FUNC is
				when "100000" =>	--ADD
					alu_f <= "0010";
				when "100010" =>	--SUB
					alu_f <=	"0110";
				when "101010" =>	--SLT
					alu_f <= "0111";
				when "100100" =>	--AND
					alu_f => "0000";
				when "100101" =>	--OR
					alu_f <= "0001";
			end case;
	end case;
end Behavioral; 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity ALU_control is
	port(
		CLK			:	in STD_LOGIC;
		RESET		:	in STD_LOGIC;
		FUNC		:	in STD_LOGIC_VECTOR (5 downto 0);
		ALUOp		:	in ALU_OP_INPUT;
		ALU_FUNC	:	out ALU_INPUT
	);
end ALU_control;

architecture Behavioral of ALU_control is
	
begin
	case ALUOp is
		when "000" =>	--LW, SW, LDI
			ALU_FUNC <= "0010";
		when "001" =>	--BEQ
			ALU_FUNC <= "0110";
		when "010" =>	--Function dependent
			case FUNC is
				when "100000" =>	--ADD
					ALU_FUNC <= "0010";
				when "100010" =>	--SUB
					ALU_FUNC <=	"0110";
				when "101010" =>	--SLT
					ALU_FUNC <= "0111";
				when "100100" =>	--AND
					ALU_FUNC => "0000";
				when "100101" =>	--OR
					ALU_FUNC <= "0001";
			end case;
	end case;
end Behavioral; 

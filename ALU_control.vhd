library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity ALU_control is
	port(
		CLK			: in STD_LOGIC;
		FUNC		: in STD_LOGIC_VECTOR (5 downto 0);
		alu_op		: in ALU_OP;
		ALU_FUNC	: out ALU_INPUT
	);
end ALU_control;

architecture Behavioral of ALU_control is
	
begin
		
	alu_op_state_machine : process (alu_op, FUNC)--Need more states in our state machine...
	begin
		case alu_op is
			when ALUOP_LOAD_STORE =>	--LW, SW
				--alu_f <= "0010";
				ALU_FUNC.Op0 <= '0';
				ALU_FUNC.Op1 <= '1';
				ALU_FUNC.Op2 <= '0';
				ALU_FUNC.Op3 <= '0';
			when ALUOP_LDI =>	--LDI
				--alu_f <= "0010";
				ALU_FUNC.Op0 <= '0';
				ALU_FUNC.Op1 <= '1';
				ALU_FUNC.Op2 <= '0';
				ALU_FUNC.Op3 <= '0';
			when ALUOP_BRANCH =>	--BEQ
				--alu_f <= "0110";
				ALU_FUNC.Op0 <= '0';
				ALU_FUNC.Op1 <= '1';
				ALU_FUNC.Op2 <= '1';
				ALU_FUNC.Op3 <= '0';
			when ALUOP_FUNC =>	--Function dependent
				case FUNC is
					when "100000" =>	--ADD
						--alu_f <= "0010";
						ALU_FUNC.Op0 <= '0';
						ALU_FUNC.Op1 <= '1';
						ALU_FUNC.Op2 <= '0';
						ALU_FUNC.Op3 <= '0';
					when "100010" =>	--SUB
						--alu_f <=	"0110";
						ALU_FUNC.Op0 <= '0';
						ALU_FUNC.Op1 <= '1';
						ALU_FUNC.Op2 <= '1';
						ALU_FUNC.Op3 <= '0';
					when "101010" =>	--SLT
						--alu_f <= "0111";
						ALU_FUNC.Op0 <= '1';
						ALU_FUNC.Op1 <= '1';
						ALU_FUNC.Op2 <= '1';
						ALU_FUNC.Op3 <= '0';
					when "100100" =>	--AND
						--alu_f <= "0000";
						ALU_FUNC.Op0 <= '0';
						ALU_FUNC.Op1 <= '0';
						ALU_FUNC.Op2 <= '0';
						ALU_FUNC.Op3 <= '0';
					when "100101" =>	--OR
						--alu_f <= "0001";
						ALU_FUNC.Op0 <= '1';
						ALU_FUNC.Op1 <= '0';
						ALU_FUNC.Op2 <= '0';
						ALU_FUNC.Op3 <= '0';
					when others =>
						null;	-- case stament needed to cover all choices. 
				end case;
			when others =>
				null;	-- case stament needed to cover all choices. 
		end case;
	end process;
end Behavioral; 

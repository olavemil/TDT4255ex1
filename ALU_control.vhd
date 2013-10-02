library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity ALU_control is
	port(
		CLK			: in STD_LOGIC;
		FUNC		: in STD_LOGIC_VECTOR (5 downto 0);
		ALUOp		: in ALU_OP_INPUT;
		ALU_FUNC	: out ALU_INPUT
	);
end ALU_control;

architecture Behavioral of ALU_control is

	signal alu_op 	: STD_LOGIC_VECTOR (2 downto 0);
	--signal alu_f	: STD_LOGIC_VECTOR (3 downto 0)	;
	
begin
	alu_op(0) <= ALUOp.Op0;
	alu_op(1) <= ALUOp.Op1;
	alu_op(2) <= ALUOp.Op2;
	
	--ALU_FUNC.Op0 <= alu_f(0);
	--ALU_FUNC.Op1 <= alu_f(1);
	--ALU_FUNC.Op2 <= alu_f(2);
	--ALU_FUNC.Op3 <= alu_f(3);
	
	alu_op_state_machine : process (alu_op, FUNC, clk)--Need more states in our state machine...
	begin
		if rising_edge(CLK) then
			case alu_op is
				when "000" =>	--LW, SW, LDI
					--alu_f <= "0010";
					ALU_FUNC.Op0 <= '0';
					ALU_FUNC.Op1 <= '1';
					ALU_FUNC.Op2 <= '0';
					ALU_FUNC.Op3 <= '0';
				when "001" =>	--BEQ
					--alu_f <= "0110";
					ALU_FUNC.Op0 <= '0';
					ALU_FUNC.Op1 <= '1';
					ALU_FUNC.Op2 <= '1';
					ALU_FUNC.Op3 <= '0';
				when "010" =>	--Function dependent
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
		end if;
	end process;
end Behavioral; 

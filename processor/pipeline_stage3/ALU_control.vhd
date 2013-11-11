library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity alu_control is
    port(
		func_in			: in STD_LOGIC_VECTOR(5 downto 0);
		alu_ctrl_op_in	: in ALU_OP;
		alu_ctrl_op_out	: out ALU_INPUT
	);
end alu_control;

architecture Behavioral of alu_control is

begin
	alu_control : process(func_in, alu_ctrl_op_in)
	begin
		case alu_ctrl_op_in is
			when ALUOP_BRANCH =>
				alu_ctrl_op_out <= ('0', '1', '1', '0');
			when ALUOP_LOAD_STORE =>
				alu_ctrl_op_out <= ('0', '0', '1', '0');
			when ALUOP_FUNC =>
				case func_in is
					when "100000" => --ADD
						alu_ctrl_op_out <= ('0', '0', '1', '0');
					when "100010" => --SUB
						alu_ctrl_op_out <= ('0', '1', '1', '0');
					when "100100" => --AND
						alu_ctrl_op_out <= ('0', '0', '0', '0');
					when "100101" => --OR
						alu_ctrl_op_out <= ('0', '0', '0', '1');
					when others => --SLT
						alu_ctrl_op_out <= ('0', '1', '1', '1');
				end case;
			when ALUOP_LDI =>
				alu_ctrl_op_out <= ('0', '0', '1', '0');
		end case;
	end process;
end Behavioral;


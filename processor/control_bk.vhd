----------------------------------------------------------------------------------
-- Company: 
-- Engineer:			 
-- 
-- Create Date:    12:24:33 09/20/2013 
-- Design Name: 
-- Module Name:    control - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control is
	generic(
		-- Arithmetic & logic, R format
		ALR		: integer := "000000";
		-- Arithmetic & logic, I format
		ADDI		: integer := "001000";
		ADDIU		: integer := "001001";
		ANDI		: integer := "001100";
		ORI		: integer := "001101";
		XORI		: integer := "001110";
		-- Comparison
		SLT		: integer := "101010";
		SLTU		: integer := "101001";
		SLTI		: integer := "001010";
		SLTIU		: integer := "001001";
		-- Branch
		BEQ		: integer := "000100";
		BGTZ		: integer := "000111";
		BLEZ		: integer := "000110";
		BNE		: integer := "000101";
		-- Load
		LB			: integer := "100000";
		LBU		: integer := "100100";
		LH			: integer := "100001";
		LHU		: integer := "100101";
		LW			: integer := "100011";
		-- Store
		SB			: integer := "101000";
		SH			: integer := "101001";
		SW			: integer := "101011";
		-- Load immediate
		LHI		: integer := "011001";
		LLO		: integer := "011000";
		-- Jump
		J			: integer := "000010";
		JAL		: integer := "000011";
		JALR		: integer := "001001";
		JR			: integer := "001000";
		-- Data movement
		MFHI		: integer := "010000";
		MFLO		: integer := "010010";
		MTHI		: integer := "010001";
		MTLO		: integer := "010011"
	);
	Port ( 
		opcode		: in STD_LOGIC_VECTOR (31 downto 26);
		enabled		: in STD_LOGIC;
		clk			: in STD_LOGIC;
		
		--Output:  alu_op, alu_src, branch(3), jump, mem_w, mem_r, mem_to_reg, reg_dst, reg_w 
		control_out		: out STD_LOGIC_VECTOR (10 downto 0)
		);
end control;

architecture Behavioral of control is

begin
	READ_OPCODE : process(clk, enabled)
	begin
		if enabled and rising_edge(clk) then
			case opcode is
				-- Arithmetic, logic, R			aabbbjmmmrr
				when ALR		=> control_out <="10000000011";
				-- Arithmetic, logic, I			aabbbjmmmrr
				when ADDI	=> control_out <="11000000001";
				when ADDIU	=> control_out <="11000000001";
				when ANDI	=> control_out <="11000000001";
				when ORI		=> control_out <="11000000001";
				when XORI	=> control_out <="11000000001";
				-- Branch							aabbbjmmmrr
				when BEQ		=> control_out <="00100000000";
				when BGTZ	=> control_out <="00101000000";
				when BLEZ	=> control_out <="00110000000";
				when BNE		=> control_out <="00111000000";
				-- Load								aabbbjmmmrr
				when LB		=> control_out <="00000001101";
				when LBU		=> control_out <="00000001101";
				when LH		=> control_out <="00000001101";
				when LHU		=> control_out <="00000001101";
				when LW		=> control_out <="00000001101";
				-- Store								aabbbjmmmrr
				when SB		=> control_out <="00000010000";
				when SH		=> control_out <="00000010000";
				when SW		=> control_out <="00000010000";
				-- Load immediate					aabbbjmmmrr
				when LHI		=> control_out <="00000001101";
				when LLO		=> control_out <="00000001101";
				-- Jump								aabbbjmmmrr
				when J		=> control_out <="00000100000";
				when JAL		=> control_out <="00000100000";
				when JALR	=> control_out <="00000100000";
				when JR		=> control_out <="00000100000";
				-- Data movement					aabbbjmmmrr
				when MFHI	=> control_out <="00000000000";
				when MFLO	=> control_out <="00000000000";
				when MTHI	=> control_out <="00000000000";
				when MTLO	=> control_out <="00000000000";
			end case;
		end if;
	end process;
end Behavioral;


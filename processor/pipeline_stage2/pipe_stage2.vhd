----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:44:55 10/19/2013 
-- Design Name: 
-- Module Name:    pipe_stage2 - behave 
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

entity pipe_stage2 is
	port(
		new_pc		: in	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
		instruction	: in	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0);
		reg_w_enb	: in 	STD_LOGIC; --from mem/wb stage
		wb_in		: in 	STD_LOGIC; --from control unit to pipe register
		m_in		: in 	STD_LOGIC; --from control unit to pipe register
		ex_in		: in 	STD_LOGIC; --from control unit to pipe register

		opcode		: out	STD_LOGIC_VECTOR(5 downto 0); --to control unit
		wb_out		: out 	STD_LOGIC; --control signals
		m_out 		: out 	STD_LOGIC;
		aluop		: out 	ALU_OP_INPUT;
		reg_dst		: out 	STD_LOGIC;
		alu_src		: out 	STD_LOGIC; --control signals
		
		new_pc_out	: out 	STD_LOGIC(15 downto 0);
		reg_d_1 	: out 	STD_LOGIC;
		reg_d_2 	: out 	STD_LOGIC;
		imm_value 	: out 	STD_LOGIC_VECTOR(31 downto 0);
		reg_rt_adr 	: out 	STD_LOGIC_VECTOR(4 downto 0);
		reg_rd_adr 	: out 	STD_LOGIC_VECTOR(4 downto 0)
	);
end pipe_stage2;

architecture behave of pipe_stage2 is

component register_file is
	port(
			CLK 			:	in	STD_LOGIC;				
			RESET			:	in	STD_LOGIC;				
			RW				:	in	STD_LOGIC;				
			RS_ADDR 		:	in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0); 
			RT_ADDR 		:	in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0); 
			RD_ADDR 		:	in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0);
			WRITE_DATA		:	in	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0); 
			RS				:	out	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
			RT				:	out	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0)
	);

end component;

begin


end behave;





















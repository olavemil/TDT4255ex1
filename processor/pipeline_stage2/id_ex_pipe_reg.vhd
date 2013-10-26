----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:20:44 10/19/2013 
-- Design Name: 
-- Module Name:    id_ex_pipe_reg - behave 
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

entity id_ex_pipe_reg is
	port(
		wb_in 		:in STD_LOGIC;
		m_in 		:in STD_LOGIC;
		ex_in 		:in --some kind of bus thingy
		new_pc_in 	:in STD_LOGIC_VECTOR(15 downto 0);
		reg_d_1_in	:in STD_LOGIC_VECTOR(15 downto 0);
		reg_d_2_in 	:in STD_LOGIC_VECTOR(15 downto 0);
		imm_in		:in STD_LOGIC_VECTOR(31 downto 0);
		reg_rt_in 	:in STD_LOGIC_VECTOR(4 downto 0);
		reg_rd_in 	:in STD_LOGIC_VECTOR(4 downto 0);

		wb_out 		:out STD_LOGIC;
		m_out 		:out STD_LOGIC;
		ex_out 		:out --some kind of bus thingy, aluop
		new_pc_out 	:out STD_LOGIC_VECTOR(15 downto 0);
		reg_d_1_out :out STD_LOGIC_VECTOR(15 downto 0);
		reg_d_2_out :out STD_LOGIC_VECTOR(15 downto 0);
		imm_out		:out STD_LOGIC_VECTOR(31 downto 0);
		reg_rt_out 	:out STD_LOGIC_VECTOR(4 downto 0);
		reg_rd_out 	:out STD_LOGIC_VECTOR(4 downto 0)
	);
end id_ex_pipe_reg;

architecture behave of id_ex_pipe_reg is

begin


end behave;


















----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:45:39 10/19/2013 
-- Design Name: 
-- Module Name:    pipe_stage4 - behave 
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

entity pipe_stage4 is
	port(
		wb_in				: in	STD_LOGIC;
		wb_out				: out	STD_LOGIC;
		
		alu_result_in		: in	STD_LOGIC_VECTOR(31 downto 0);
		alu_result_out		: out	STD_LOGIC_VECTOR(31 downto 0);
		
		reg_r_in			: in	STD_LOGIC_VECTOR(31 downto 0);
		reg_r_out			: out	STD_LOGIC_VECTOR(31 downto 0)
	);
end pipe_stage4;

architecture behave of pipe_stage4 is

begin
	registers : process(clk)
		begin
			if rising_edge(clk) then
				wb_out			<= wb_in;
				reg_r_out		<= reg_r_in;
				alu_result_out	<= alu_result_in;
			end if;
		end process;
end behave;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity hazard_detection_unit is
	port(
		clk				: in STD_LOGIC;
		id_ex_reg_rt	: in STD_LOGIC_VECTOR(4 downto 0);
		if_id_reg_rs	: in STD_LOGIC_VECTOR(4 downto 0);
		if_id_reg_rt	: in STD_LOGIC_VECTOR(4 downto 0);
		id_ex_mem_rd	: in STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);
		nops_activate	: out STD_LOGIC;
		pc_wr_enb		: out STD_LOGIC;
		if_id_wr_enb	: out STD_LOGIC
	);
end hazard_detection_unit;

architecture behave of hazard_detection_unit is

begin


|

end behave;


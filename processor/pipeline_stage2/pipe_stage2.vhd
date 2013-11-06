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
		clk				: in	STD_LOGIC;
		--in from stage 1
		instruction_in	: in	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0);
		pc_in				: in	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
		--in from stage 4/5   
		reg_r_in			: in	STD_LOGIC_VECTOR(31 downto 0);
		data_in			: in	STD_LOGIC_VECTOR(31 downto 0);--alu_result/dmem_out
		reg_w_e			: in  STD_LOGIC;
		--in from stage 3
		hz
		hz
		
		--out to stage 1
		branch_adr		: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
		flush_out		: out	STD_LOGIC;
		branch_val_out	: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
		--out to stage 3
		func_out			: out	STD_LOGIC_VECTOR(5 downto 0);
		alu_op_out		: out	ALU_OP_INPUT;
		
		m_we_out			: out	STD_LOGIC;
		wb_out			: out	STD_LOGIC;
		
		reg_dst_out		: out	STD_LOGIC;
		alu_src_out		: out	STD_LOGIC;
		
		alu_reg_1_out	: out	STD_LOGIC_VECTOR(31 downto 0);
		alu_reg_2_out	: out	STD_LOGIC_VECTOR(31 downto 0);
		
		imm_val_out 	: out	STD_LOGIC_VECTOR(31 downto 0);
		
		reg_rt_out 		: out	STD_LOGIC_VECTOR(4 downto 0);
		reg_rd_out 		: out	STD_LOGIC_VECTOR(4 downto 0);
		--out to forwarding unit
		reg_rs_out 		: out	STD_LOGIC_VECTOR(4 downto 0);
		reg_rt_out 		: out	STD_LOGIC_VECTOR(4 downto 0)
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





















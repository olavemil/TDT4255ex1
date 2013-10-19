----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    11:44:23 10/19/2013
-- Design Name:
-- Module Name:    pipe_stage1 - behave
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
use IEEE.STD_LOGIC_ARITH.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pipe_stage1 is
	port(
		clk				: in	STD_LOGIC;
		pc_wr_enb		: in	STD_LOGIC;
		pc_src			: in	STD_LOGIC;
		haz_contrl_sig	: in	STD_LOGIC;
		if_flush_sig	: in	STD_LOGIC;
		pc_alu_src		: in	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
		instr_mem_outpt	: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
		pc_alu_outpt	: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0)
	);
end pipe_stage1;

architecture behave of pipe_stage1 is

	-- Program counter signals
	signal PC_Out		: STD_LOGIC_VECTOR(N-1 downto 0);

	component program_counter
		port(
			RESET	: in	STD_LOGIC;
			PC_W	: in	STD_LOGIC;
			PC_IN	: in	STD_LOGIC_VECTOR (IADDR_BUS-1 downto 0);
			PC_OUT	: out	STD_LOGIC_VECTOR (IADDR_BUS-1 downto 0)
		);
	end component;

	--Adder signals
	signal PC_Incr_In	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal PC_Incr_Out	: STD_LOGIC_VECTOR(N-1 downto 0);

	component adder
		generic (N : natural);
		port(
			X		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			Y		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			CIN		: in	STD_LOGIC;
			COUT	: out	STD_LOGIC;
			R		: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component;

	--Instruction memory signals
	signal InstrMemInpt	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal InstrMemOupt	: STD_LOGIC_VECTOR(N-1 downto 0);

	component instruction_memory_module --is lacking from the ISE project for the time being?
		port(
			clk		: in	STD_LOGIC
			inpt	: in	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			outpt	: out	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0)
			--++ more I would guess
		);
	end component;

	component if_id_pipe_reg
		port(
			clk			: in	STD_LOGIC;
			reset		: in	STD_LOGIC;
			if_flush	: in	STD_LOGIC;
			haz_cntrl	: in	STD_LOGIC;
			pc_in		: in	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			pc_out		: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			instr_in	: in	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0):
			instr_out	: out	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0)
		);
	end component;

begin




end behave;


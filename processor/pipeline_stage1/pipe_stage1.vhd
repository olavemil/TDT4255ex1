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
		clk					: in	STD_LOGIC;
		pc_src				: in	STD_LOGIC;
		pc_reset			: in	STD_LOGIC;
		pc_wr_enb			: in	STD_LOGIC;
		if_flush_sig		: in	STD_LOGIC;
		haz_contrl_sig		: in	STD_LOGIC;
		pc_alu_src			: in	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		imem_data_in		: in	STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);
		imem_address		: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		pc_buffer_outpt		: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		imem_buffer_outpt	: out	STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0)
	);
end pipe_stage1;

architecture behave of pipe_stage1 is

	-- Program counter signals
	signal pc_inpt		: STD_LOGIC_VECTOR(N-1 downto 0);
	signal pc_outpt		: STD_LOGIC_VECTOR(N-1 downto 0);

	component program_counter
		port(
			CLK 		: in	STD_LOGIC;
			RESET		: in	STD_LOGIC;
			PC_WR_EN	: in	STD_LOGIC; --ProgramCounter Write Enable pin
			PC_IN		: in	STD_LOGIC_VECTOR (IADDR_BUS-1 downto 0);
			PC_OUT		: out	STD_LOGIC_VECTOR (IADDR_BUS-1 downto 0)
		);
	end component;

	signal pc_incr_outpt	: STD_LOGIC_VECTOR(N-1 downto 0);

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

	--IF/ID Buffer signals
	signal instr_buffr, pc_buffr	: STD_LOGIC_VECTOR(N-1 downto 0);

begin

	PC : program_counter
		port map(
			CLK			=> clk,
			RESET		=> pc_reset,
			PC_WR_EN	=> pc_wr_enb,
			PC_IN		=> pc_inpt,
			PC_OUT		=> pc_outpt
		);

	PC_INCR : adder
		generic map (N => 32)
		port map(
			X	=> pc_outpt,
			Y 	=> ZERO32b,
			CIN	=> '1',
			COUT=> open,
			R 	=> pc_incr_outpt
		);

	PC_MUX : process(pc_src, clk, pc_incr_outpt, pc_alu_src)
	begin
		if (pc_src = '1') then
			pc_inpt <= pc_alu_src;
		else
			pc_inpt <= pc_incr_outpt;
		end if;
	end process;

	CTRL : process(clk, pc_outpt)
	begin
		if (rising_edge(clk)) then
			pc_buffer_outpt		<= pc_buffr;
			imem_buffer_outpt	<= instr_buffr;
			pc_buffr	<= pc_outpt;
			instr_buffr	<= imem_data_in;
		else

		end if ;
	end process;

end behave;


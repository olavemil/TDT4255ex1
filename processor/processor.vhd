----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    12:27:34 10/19/2013
-- Design Name:
-- Module Name:    processor - behave
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

entity processor is
	generic(
		MEM_ADDR_BUS	: integer := 32;
		MEM_DATA_BUS	: integer := 32;
		N				: integer := 32
		);
	port(
		clk					: in	STD_LOGIC;
		reset				: in	STD_LOGIC;
		processor_enable	: in	STD_LOGIC;
		imem_address 		: out	STD_LOGIC_VECTOR (MEM_ADDR_BUS-1 downto 0);
		imem_data_in 		: in	STD_LOGIC_VECTOR (MEM_DATA_BUS-1 downto 0);
		dmem_data_in 		: in	STD_LOGIC_VECTOR (MEM_DATA_BUS-1 downto 0);
		dmem_address 		: out	STD_LOGIC_VECTOR (MEM_ADDR_BUS-1 downto 0);
		dmem_address_wr		: out	STD_LOGIC_VECTOR (MEM_ADDR_BUS-1 downto 0);
		dmem_data_out		: out	STD_LOGIC_VECTOR (MEM_DATA_BUS-1 downto 0);
		dmem_write_enable	: out	STD_LOGIC
		);
end processor;

architecture behave of processor is

--	MUX Control Signals
	signal PCSrc		: STD_LOGIC;
	signal RegDst		: STD_LOGIC;
	signal MemToReg		: STD_LOGIC;
	signal ALU_Inpt1	: STD_LOGIC_VECTOR(1 downto 0);
	signal ALU_Inpt2	: STD_LOGIC_VECTOR(1 downto 0);
	--signal HazardDetectionUnitChoosesIfControlUnitDecidesNext : STD_LOGIC;  --Needs new name

--	PipeStage1 signals
	signal PC_WrEn		: STD_LOGIC;
	signal IF_Flush		: STD_LOGIC;
	--signal HazardDetectionControlSignalToBuffr : STD_LOGIC; --Needs new name
	signal PC_ALUSrc	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal pipe1_instr	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal pipe1_PC_out	: STD_LOGIC_VECTOR(N-1 downto 0);


--	Connect port map of pipe_stage1
	component pipe_stage1
		port(
			clk					: in	STD_LOGIC;
			pc_src				: in	STD_LOGIC;
			pc_wr_enb			: in	STD_LOGIC;
			if_flush_sig		: in	STD_LOGIC;
			haz_contrl_sig		: in	STD_LOGIC;
			pc_alu_src			: in	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			imem_data_in		: in	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0);
			imem_address		: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			pc_buffer_outpt		: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			imem_buffer_outpt	: out	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0)
		);
	end component;


--	Connect port map of pipe_stage2
	component pipe_stage2

	end component;


--	Connect port map of pipe_stage3
	component pipe_stage3

	end component;


--	Connect port map of pipe_stage4
	component pipe_stage4

	end component;


--	Connect port map of pipe_stage5
	component pipe_stage5

	end component;


-- Connect port map of hazard detection unit
	component hazard_detection_unit

	end component;


-- Connect port map of forwarding unit
	component forwarding_unit

	end component;


begin


end behave;

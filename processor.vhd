-------------	---------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:55:44 09/19/2013 
-- Design Name: 
-- Module Name:    processor - Behavioral 
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
	generic (
		MEM_ADDR_BUS	: integer	:= 32;
		MEM_DATA_BUS	: integer	:= 32;
		N				: integer	:= 32;
		ONE				: integer	:= 1
	);
	Port ( 
		clk 				: in	STD_LOGIC;
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

architecture Behavioral of processor is

	component register_file
		port (
			clk 		: in	STD_LOGIC;				
			reset		: in	STD_LOGIC;				
			rw			: in	STD_LOGIC;				
			rs_addr		: in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0); 
			rt_addr 	: in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0); 
			rd_addr 	: in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0);
			write_data	: in	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0); 
			rs			: out	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
			rt			: out	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0)
		);
	end component;
	
	component alu
		port (
			X		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			Y		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			ALU_IN	: in	ALU_INPUT;
			R		: out	STD_LOGIC_VECTOR(N-1 downto 0);
			FLAGS	: out	ALU_FLAGS
		);
	end component;
	
	component adder
		port (
			X		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			Y		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			CIN		: in	STD_LOGIC;
			COUT	: out	STD_LOGIC;
			R		: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component;
	
	component ALU_control
		port(
			CLK			: in	STD_LOGIC;
			RESET		: in	STD_LOGIC;
			FUNC		: in	STD_LOGIC_VECTOR (5 downto 0);
			ALUOp		: in	ALU_OP_INPUT;
			ALU_FUNC	: out	ALU_INPUT
		);
	end component;
	
	component control_unit
		port(
			CLK 		: in 	STD_LOGIC;
			RESET		: in 	STD_LOGIC;
			OpCode		: in	STD_LOGIC_VECTOR (5 downto 0);
			ALUOp		: out	ALU_OP_INPUT;
			RegDst		: out 	STD_LOGIC;
			Branch		: out 	STD_LOGIC;
			MemRead		: out 	STD_LOGIC;
			MemtoReg	: out 	STD_LOGIC;
			MemWrite	: out 	STD_LOGIC;
			ALUSrc		: out 	STD_LOGIC;
			RegWrite	: out 	STD_LOGIC;
			Jump		: out 	STD_LOGIC;
			PCWriteEnb	: out 	STD_LOGIC;
			SRWriteEnb	: out 	STD_LOGIC
		);
	end component;
	
	component program_counter
		port (
			RESET	: in 	STD_LOGIC;
			PC_CON	: in 	STD_LOGIC;
			PC_IN	: in 	STD_LOGIC_VECTOR (N-1 downto 0);
			PC_OUT	: out 	STD_LOGIC_VECTOR (N-1 downto 0)
		);
	end component;
	
	component status_register
		port (
			RESET		: in	STD_LOGIC;
			sr_w 		: in	STD_LOGIC;
			alu_flags	: in	ALU_FLAGS;
			alu_zero	: out	STD_LOGIC
		);
	end component;
	
	--program counter and incrementer output
	signal pc_out			: STD_LOGIC_VECTOR (31 downto 0);
	signal pc_incrementer	: STD_LOGIC_VECTOR (31 downto 0);
	--register destination multiplexer output
	signal reg_dst_mux		: STD_LOGIC_VECTOR (31 downto 0);
	--register file outputs
	signal reg_read_a		: STD_LOGIC_VECTOR (31 downto 0);
	signal reg_read_b		: STD_LOGIC_VECTOR (31 downto 0);
	--branch and jump multiplexer inputs
	signal sign_ext_instr	: STD_LOGIC_VECTOR (31 downto 0);
	signal branch_add		: STD_LOGIC_VECTOR (31 downto 0);
	--branch and jump multiplexer outputs
	signal branch_mux		: STD_LOGIC_VECTOR (31 downto 0);
	signal jump_mux			: STD_LOGIC_VECTOR (31 downto 0);
	--alu output
	signal alu_flags		: ALU_FLAGS;
	signal alu_result		: STD_LOGIC_VECTOR (31 downto 0);
	--alu source multiplexer output
	signal alu_src_mux		: STD_LOGIC_VECTOR (31 downto 0);
	--alu memory multiplexer output
	signal alu_mem_mux		: STD_LOGIC_VECTOR (31 downto 0);
	--status register output
	signal alu_zero			:STD_LOGIC;
	
	--control signals
	signal alu_op			: ALU_OP_INPUT;
	signal alu_src			: STD_LOGIC;
	
	signal branch			: STD_LOGIC;
	signal jump				: STD_LOGIC;
	
	signal mem_r			: STD_LOGIC;
	signal mem_w			: STD_LOGIC;
	signal mem_to_reg		: STD_LOGIC;
	
	signal reg_dst			: STD_LOGIC;
	signal reg_w			: STD_LOGIC;
	
	signal pc_w				: STD_LOGIC;
	signal sr_w				: STD_LOGIC;
	--ALU control signals
	signal alu_ctrl			: ALU_INPUT;
	--constant value inputs
	
begin
	
	dmem_data_out 			<= reg_read_b; 	--write data
	dmem_address 			<= alu_result; 	--read address
	dmem_address_wr 		<= alu_result; 	--write address
	dmem_write_enable		<= mem_w;		--write enable
	imem_address			<= pc_out;
	sign_ext_instr			<= SXT(imem_data_in (15 downto 0), 31);

	PC : program_counter port map (
		RESET		 	=> reset,
		PC_CON			=> pc_w,
		PC_IN			=> jump_mux,
		PC_OUT			=> pc_out
	);
	
	SR : status_register port map (
		RESET		 	=> reset,
		sr_w			=> sr_w,
		alu_flags		=> alu_flags,
		alu_zero		=> alu_zero
	);
	
	PC_INC : adder port map(
		X 				=> pc_out,
		Y	 			=> ZERO32b,
		CIN				=> '1',
		R				=> pc_incrementer
	);
	
	B_ADD : adder port map(
		X 				=> pc_incrementer,
		Y				=> sign_ext_instr,
		CIN				=> '0',
		R				=> branch_add
	);
	
	REG_FILE : register_file port map(
		clk 			=> clk,
		reset			=> reset,
		rw				=> reg_w,
		rs_addr			=> imem_data_in (25 downto 21),
		rt_addr			=> imem_data_in (20 downto 20),
		rd_addr			=> reg_dst_mux,
		write_data		=> alu_mem_mux,
		rs				=> reg_read_a,
		rt				=> reg_read_b
	);
	
	ALU_UNIT : alu port map (
		X				=> reg_read_a,
		Y				=> reg_read_b,
		ALU_IN			=> alu_ctrl,
		r				=> alu_result,
		FLAGS			=> alu_flags
	);
	
	ALU_C : ALU_control port map (
		CLK			=> clk,
		RESET		=> reset,
		FUNC		=> imem_data_in (5 downto 0),
		ALUOp		=> alu_op,
		ALU_FUNC	=> alu_ctrl
	);
	
	CTRL : control_unit port map(
		CLK			=> clk,
		RESET		=> reset,
		OpCode		=> imem_data_in (31 downto 26),
		ALUOp		=> alu_op,
		ALUSrc		=> alu_src,
		
		Branch		=> branch,
		Jump		=> jump,
		
		MemWrite	=> mem_w,
		MemRead		=> mem_r,
		MemtoReg	=> mem_to_reg,
		
		RegWrite	=> reg_w,
		RegDst		=> reg_dst,
		
		PCWriteEnb	=> pc_w,
		SRWriteEnb	=> sr_w
	);
	
	B_MUX : process (branch, alu_zero)
	begin
		if branch = '1' and alu_zero = '1' then
			branch_mux <= branch_add;
		else
			branch_mux <= pc_incrementer;
		end if;
	end process;
	
	J_MUX : process (jump)
	begin
		if jump = '0' then
			jump_mux 		<= branch_mux;
		else
			jump_mux 		<= pc_incrementer (31 downto 26) & imem_data_in (25 downto 0);
		end if;
	end process;
	
	RDST_MUX : process (reg_dst)
	begin
		if reg_dst = '1' then
			reg_dst_mux <= imem_data_in (15 downto 11);
		else
			reg_dst_mux <= imem_data_in (20 downto 16);
		end if;
	end process;
	
	ALU_SOURCE_MUX : process (alu_src)
	begin
		if alu_src = '1' then
			alu_src_mux <= sign_ext_instr;
		else
			alu_src_mux <= reg_read_b;
		end if;
	end process;
	
	ALU_MEMORY_MUX : process (mem_to_reg)
	begin
		if mem_to_reg = '1' then
			alu_mem_mux <= dmem_data_in;
		else
			alu_mem_mux <= alu_result;
		end if;
	end process;
	
end Behavioral;
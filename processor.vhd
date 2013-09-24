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

	component regfile
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
	end component
	
	component program_counter
		port (
			CLK 	: in 	STD_LOGIC;
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
	signal program_counter	: STD_LOGIC_VECTOR (31 downto 0);
	signal pc_incrementer	: STD_LOGIC_VECTOR (31 downto 0);
	--register destination multiplexer output
	signal reg_dst_mux		: STD_LOGIC_VECTOR (31 downto 0);
	--register file outputs
	signal reg_read_a		: STD_LOGIC_VECTOR (31 downto 0);
	signal reg_read_b		: STD_LOGIC_VECTOR (31 downto 0);
	--branch and jump multiplexer inputs
	signal sign_ext_instr	: SXT (imem_data_in (15 downto 0), 31);
	signal branch_add		: STD_LOGIC_VECTOR (31 downto 0);
	--branch and jump multiplexer outputs
	signal branch_mux		: STD_LOGIC_VECTOR (31 downto 0);
	signal jump_mux			: STD_LOGIC_VECTOR (31 downto 0);
	--alu output
	signal alu_flags		: ALU_FLAGS;
	signal alu_result		: STD_LOGIC_VECTOR (31 downto 0);
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
	signal alu_control		: ALU_INPUT;
	
begin
	
	dmem_data_out 			<= reg_read_b; 	--write data
	dmem_address 			<= alu_result; 	--read address
	dmem_address_wr 		<= alu_result; 	--write address
	dmem_write_enable		<= mem_w;		--write enable
	imem_address			<= program_counter;
	ONE						<= '1';

	PC : program_counter port map (
		reset		 	=> RESET;
		pc_w			=> PC_CON;
		jump_mux		=> PC_IN;
		program_counter	=> PC_OUT
	);
	
	SR : status_register port map (
		reset		 	=> RESET;
		sr_w			=> sr_w;
		alu_flags		=> alu_flags;
		alu_zero		=> alu_zero
	);
	
	PC_INC : adder port map(
		program_counter 	=> X,
		ONE 				=> Y,
		pc_incrementer		=> R
	);
	
	BRANCH_ADD : adder port map(
		pc_incrementer 		=> X,
		sign_ext_instr		=> Y,
		branch_add			=> R
	);
	
	REG_FILE : register_file port map(
		clk 						=> clk,
		reset						=> reset,
		reg_w						=> rw,
		imem_data_in (25 downto 21)	=> rs_addr,
		imem_data_in (20 downto 20)	=> rt_addr,
		reg_dst_mux					=> rd_addr,
		alu_mem_mux					=> write_data,
		reg_read_a					=> rs,
		reg_read_b					=> rt
	);
	
	ALU : alu port map (
		reg_read_a			=> X,
		reg_read_b			=> Y,
		alu_control			=> ALU_IN,
		alu_result			=> R,
		alu_flags			=> FLAGS
	);
	
	ALU_CONTROL : ALU_control port map (
		clk			=> CLK,
		reset		=> RESET,
		func		=> FUNC,
		alu_op		=> ALUOp,
		alu_control	=> ALU_FUNC
	);
	
	CONTROL_UNIT : control_unit port map(
	clk			=> CLK,
	reset		=> RESET,
	imem_data_in (31 downto 26)	=> OpCode,
	alu_op		=> ALUOp,
	alu_src		=> ALUSrc,
	
	branch		=> Branch,
	jump		=> Jump,
	
	mem_w		=> MemWrite,
	mem_r		=> MemRead,
	mem_to_reg	=> MemtoReg,
	
	reg_w		=> RegWrite,
	reg_dst		=> RegDst,
	
	pc_w		=> PCWriteEnb,
	sr_w		=> SRWriteEnb
	);
	
	BRANCH_MUX : process (branch, alu_zero)
	begin
		if branch and alu_zero then
			branch_mux <= branch_add;
		else
			branch_mux <= pc_incrementer;
		end if;
	end process;
	
	JUMP_MUX : process (jump_control)
	begin
		if jump_control = '0' then
			jump_mux 		<= branch_mux;
		else
			jump_mux 		<= pc_incrementer (31 downto 26) & imem_data_in (25 downto 0);
		end if;
	end process;
	
	REG_DST_MUX : process (reg_dst)
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
	
	ALU_MEM_MUX : process (mem_to_reg)
	begin
		if mem_to_reg = '1' then
			alu_mem_mux <= dmem_data_in;
		else
			alu_mem_mux <= alu_result;
		end if;
	end process;
	
end Behavioral;
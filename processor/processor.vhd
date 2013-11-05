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


--	Definition and signals for pipe_stage1
	component pipe_stage1
		port(
			clk					: in	STD_LOGIC;
			pc_src				: in	STD_LOGIC;
			if_flush_sig		: in	STD_LOGIC;
			haz_contrl_sig		: in	STD_LOGIC;
			pc_alu_src			: in	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			imem_data_in		: in	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0);
			imem_address		: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			pc_buffer_outpt		: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			imem_buffer_outpt	: out	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0)
		);
	end component;

	signal stage_1_out_pc			: STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
	signal stage_1_out_instruction	: STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0);

--	Definition and signals for pipe_stage2
	component pipe_stage2
		port(
			clk				: in	STD_LOGIC;
			--in from stage 1
			instruction_in	: in	STD_LOGIC_VECTOR(MEM_DATA_BUS-1 downto 0);
			pc_in			: in	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			--in from stage 4/5
			wb_in			: in	STD_LOGIC;
			reg_r_in		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			data_in			: in	STD_LOGIC_VECTOR(N-1 downto 0);--alu_result/dmem_out
			--out to stage 1
			pc_out			: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			flush_out		: out	STD_LOGIC;
			branch_val_out	: out	STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
			--out to stage 3
			function_out	: out	STD_LOGIC_VECTOR(  5 downto 0);
			alu_op_out		: out	ALU_OP_INPUT;
			
			m_we_out		: out	STD_LOGIC;
			wb_out			: out	STD_LOGIC;
			
			reg_dst_out		: out	STD_LOGIC;
			alu_src_out		: out	STD_LOGIC;
			
			alu_reg_1_out	: out	STD_LOGIC_VECTOR(N-1 downto 0);
			alu_reg_2_out	: out	STD_LOGIC_VECTOR(N-1 downto 0);
			
			imm_val_out 		: out	STD_LOGIC_VECTOR(N-1 downto 0);
			
			reg_rt_out 		: out	STD_LOGIC_VECTOR(  4 downto 0);
			reg_rd_out 		: out	STD_LOGIC_VECTOR(  4 downto 0);
			--out to forwarding unit
			reg_rs_out 		: out	STD_LOGIC_VECTOR(  4 downto 0);
			reg_rt_out 		: out	STD_LOGIC_VECTOR(  4 downto 0)
		);
	end component;
	signal stage_2_out_pc			: STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
	signal stage_2_out_flush		: STD_LOGIC;
	signal stage_2_out_branch_val	: STD_LOGIC_VECTOR(MEM_ADDR_BUS-1 downto 0);
	signal stage_2_out_func			: STD_LOGIC_VECTOR(  5 downto 0);
	signal stage_2_out_alu_op		: ALU_OP_INPUT;
	signal stage_2_out_m_we			: STD_LOGIC;
	signal stage_2_out_wb			: STD_LOGIC;
	signal stage_2_out_reg_dst		: STD_LOGIC;
	signal stage_2_out_alu_src		: STD_LOGIC;
	signal stage_2_out_alu_reg_1	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal stage_2_out_alu_reg_2	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal stage_2_out_imm_val		: STD_LOGIC_VECTOR(N-1 downto 0);
	signal stage_2_out_reg_rt		: STD_LOGIC_VECTOR(  4 downto 0);
	signal stage_2_out_reg_rd		: STD_LOGIC_VECTOR(  4 downto 0);
	signal stage_2_out_fwd_rs		: STD_LOGIC_VECTOR(  4 downto 0);
	signal stage_2_out_fwd_rt		: STD_LOGIC_VECTOR(  4 downto 0);
	
--	Definition and signals for pipe_stage3
	component pipe_stage3
		port(
			func_in				: in	STD_LOGIC_VECTOR( 5 downto 0);
			
			alu_op_in			: in	ALU_OP_INPUT;
			
			m_we_in				: in	STD_LOGIC;
			m_we_out			: out	STD_LOGIC;
			
			wb_in				: in	STD_LOGIC;
			wb_out				: out	STD_LOGIC;
			
			alu_reg_in_1		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			alu_reg_in_2		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			alu_result_out		: out	STD_LOGIC_VECTOR(N-1 downto 0);
			
			dmem_address		: out	STD_LOGIC_VECTOR(N-1 downto 0);
			
			reg_rt_in			: in	STD_LOGIC_VECTOR(N-1 downto 0);
			reg_rd_in			: in	STD_LOGIC_VECTOR(N-1 downto 0);
			reg_r_out			: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component;
	signal stage_3_out_m_we			: STD_LOGIC;
	signal stage_3_out_wb			: STD_LOGIC;
	signal stage_3_out_alu_result	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal stage_3_out_reg_r		: STD_LOGIC_VECTOR(  4 downto 0);

--	Definition and signals for pipe_stage4
	component pipe_stage4
		port(
			wb_in				: in	STD_LOGIC;
			wb_out				: out	STD_LOGIC;
			
			alu_result_in		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			alu_result_out		: out	STD_LOGIC_VECTOR(N-1 downto 0);
			
			reg_r_in			: in	STD_LOGIC_VECTOR(N-1 downto 0);
			reg_r_out			: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component;
	signal stage_4_out_wb			: STD_LOGIC;
	signal stage_4_out_alu_result	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal stage_4_out_reg_r		: STD_LOGIC_VECTOR(  4 downto 0);

--	Definition and signals for pipe_stage5
	component pipe_stage5

	end component;


-- Connect port map of hazard detection unit
	component hazard_detection_unit

	end component;


-- Connect port map of forwarding unit
	component forwarding_unit

	end component;


begin
	--STAGE 1
	stage_1: pipe_stage1
		port map(
			clk					=> clk,
			--in from stage 2
			pc_src				=> stage_2_out_pc,
			if_flush_sig		=> stage_2_out_flush,
			haz_contrl_sig		=> hazard_out,
			pc_alu_src			=> stage_2_out_branch_val,
			--out to stage 2
			imem_address		=> imem_address,
			pc_buffer_outpt		=> stage_1_out_pc
		);
		stage_1_out_instruction <= imem_data_in;
		
	--STAGE 2
	stage_2: pipe_stage2
		port map(
			clk				=> clk,
			--in from stage 1
			instruction_in	=> stage_1_out_instruction,
			pc_in			=> stage_1_out_pc,
			--in from stage 4/5
			wb_in			=> stage_4_out_wb,
			reg_r_in		=> stage_4_out_reg_r,
			data_in			=> alu_mem_mux_out,
			--out to stage 1
			pc_out			=> stage_2_out_pc,
			flush_out		=> stage_2_out_flush,
			branch_val_out	=> stage_2_out_branch_val,
			--out to stage 3
			func_out		=> stage_2_out_func,
			alu_op_out		=> stage_2_out_alu_op,
			
			m_we_out		=> stage_2_out_m_we,
			wb_out			=> stage_2_out_wb,
			
			reg_dst_out		=> stage_2_out_reg_dst,
			alu_src_out		=> stage_2_out_alu_src,
			
			alu_reg_1_out	=> stage_2_out_alu_reg_1,
			alu_reg_2_out	=> stage_2_out_alu_reg_2,
			
			imm_val_out		=> stage_2_out_imm_val,
			
			reg_rt_out		=> stage_2_out_reg_rt,
			reg_rd_out		=> stage_2_out_reg_rd,
			--out to forwarding unit
			reg_rs_out		=> stage_2_out_fwd_rs,
			reg_rt_out		=> stage_2_out_fwd_rt
		);
		
	--STAGE 3
	stage_3: pipe_stage3 
		port map(
			--in from stage 2
			func_in			=> stage_2_out_func,
			alu_op_in		=> stage_2_out_alu_op,
			
			m_we_in			=> stage_2_out_m_we,
			wb_in			=> stage_2_out_wb,
			
			reg_dst_in		=> stage_2_out_reg_dst,
			alu_src_in		=> stage_2_out_alu_src,
			
			alu_reg_in_1	=> stage_2_out_alu_reg_1,
			alu_reg_in_2	=> stage_2_out_alu_reg_2,
			
			imm_val_in		=> stage_2_out_imm_val,
			
			reg_rt_in		=> stage_2_out_reg_rt,
			reg_rd_in		=> stage_2_out_reg_rd,
			--in from forwarding unit
			
			--out to stage 4
			m_we_out		=> stage_3_out_m_we,
			wb_out			=> stage_3_out_wb,
			
			dmem_address	=> dmem_address,
			alu_result_out	=> stage_3_out_alu_result,
			
			reg_r_out		=> stage_3_out_reg_r
		);
	--STAGE 4
	dmem_address_we		<= stage_3_out_m_we;
	dmem_data_in		<= stage_3_out_alu_result;
		
	stage_4: pipe_stage4
		port map(
			--in from stage 3
			wb_in			<= stage_3_out_wb,
			
			alu_result_in	<= stage_3_out_alu_result,
			reg_r_in		<= stage_3_out_reg_r,
			--out to stage 5/1
			wb_out			<= stage_4_out_wb,
			alu_result_out	<= stage_4_out_alu_result,
			reg_r_out		<= stage_4_out_reg_r
		);
	
	
	--STAGE 5
end behave;

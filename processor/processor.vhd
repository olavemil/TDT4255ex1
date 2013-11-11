----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:	12:27:34 10/19/2013
-- Design Name:
-- Module Name:	processor - behave
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
	port(
		clk					: in	STD_LOGIC;
		reset					: in	STD_LOGIC;
		processor_enable	: in	STD_LOGIC;
		imem_address 		: out	STD_LOGIC_VECTOR (IADDR_BUS-1 downto 0);
		imem_data_in 		: in	STD_LOGIC_VECTOR (IDATA_BUS-1 downto 0);
		dmem_data_in 		: in	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
		dmem_address 		: out	STD_LOGIC_VECTOR (DADDR_BUS-1 downto 0);
		dmem_address_wr	: out	STD_LOGIC_VECTOR (DADDR_BUS-1 downto 0);
		dmem_data_out		: out	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
		dmem_write_enable	: out	STD_LOGIC
		);
end processor;

architecture behave of processor is

--	Definition and signals for pipe_stage1
	component pipe_stage1
		port(
			clk					: in	STD_LOGIC;
			reset				: in	STD_LOGIC;
			processor_enable	: in	STD_LOGIC;

			--stuff
			if_stall			: in	STD_LOGIC;
			if_flush			: in	STD_LOGIC;
			--From stage 2
			pc_in				: in	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
			pc_we				: in	STD_LOGIC;
			--to/from imem
			instr_data			: in	STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);
			instr_addr			: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
			--To stage 2
			pc_inc_out			: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
			instruction			: out	STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0)
		);
	end component;

	signal stage_1_out_pc			: STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
	signal stage_1_out_instruction	: STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);

--	Definition and signals for pipe_stage2
	component pipe_stage2
		port(
			clk				: in	STD_LOGIC;
			reset			: in	STD_LOGIC;
			processor_enable: in	STD_LOGIC;
			
			--in from stage 1
			pc_in			: in	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
			instruction		: in	STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);

			--in from stage 4/5
			reg_r_in		: in	STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);
				--alu_result/dmem_out
			data_in			: in	STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);
			wb_in			: in	STD_LOGIC;

			--out to stage 1
			pc_we			: out	STD_LOGIC;
			pc_out			: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
			if_stall		: out	STD_LOGIC;
			if_flush		: out	STD_LOGIC;

			--out to stage 3
				--TODO, why is the function going out? ANSWER: Alu_ctrl needs it.
			func_out		: out	STD_LOGIC_VECTOR(5 downto 0);
			alu_op_out		: out	ALU_OP;
			m_we_out		: out	STD_LOGIC;
			wb_out			: out	STD_LOGIC;
			reg_dst_out		: out	STD_LOGIC;
			alu_src_out		: out	STD_LOGIC;
			mem_to_reg		: out	STD_LOGIC;
			alu_reg_1_out	: out	STD_LOGIC_VECTOR(31 downto 0);
			alu_reg_2_out	: out	STD_LOGIC_VECTOR(31 downto 0);
			imm_val_out		: out	STD_LOGIC_VECTOR(31 downto 0);
			reg_rt_out		: out	STD_LOGIC_VECTOR(4 downto 0);
			reg_rd_out		: out	STD_LOGIC_VECTOR(4 downto 0);

			--out to forwarding unit
			reg_rs_out		: out	STD_LOGIC_VECTOR(4 downto 0)
		);
	end component;
	signal stage_2_out_pc_src		: STD_LOGIC;
	signal stage_2_out_hazard		: std_logic;
	signal stage_2_out_if_stall		: STD_LOGIC;
	signal stage_2_out_if_flush		: STD_LOGIC;
	signal stage_2_out_pc			: STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
	signal stage_2_out_pc_we		: STD_LOGIC;
	signal stage_2_out_func			: STD_LOGIC_VECTOR(5 downto 0);
	signal stage_2_out_alu_op		: ALU_OP;
	signal stage_2_out_m_we			: STD_LOGIC;
	signal stage_2_out_wb			: STD_LOGIC;
	signal stage_2_out_reg_dst		: STD_LOGIC;
	signal stage_2_out_alu_src		: STD_LOGIC;
	signal stage_2_out_mem_to_reg	: STD_LOGIC;
	signal stage_2_out_alu_reg_1	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal stage_2_out_alu_reg_2	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal stage_2_out_imm_val		: STD_LOGIC_VECTOR(N-1 downto 0);
	signal stage_2_out_reg_rt		: STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);
	signal stage_2_out_reg_rd		: STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);
	signal stage_2_out_reg_rs		: STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);

--	Definition and signals for pipe_stage3
	component pipe_stage3
		port(
			clk					: in	STD_LOGIC;
			processor_enable	: in	STD_LOGIC;
			--In from stage 2
			func_in				: in	STD_LOGIC_VECTOR(5 downto 0);
			alu_ctrl_op_in			: in	ALU_OP;

			m_we_in,
			wb_in				: in	STD_LOGIC;

			reg_dst_in			: in	STD_LOGIC;
			alu_src_in			: in	STD_LOGIC;

			reg_data_1_in,
			reg_data_2_in		: in	STD_LOGIC_VECTOR(N-1 downto 0);

			imm_val_in			: in	STD_LOGIC_VECTOR(N-1 downto 0);

			reg_rt_in,
			reg_rd_in			: in	STD_LOGIC_VECTOR(4 downto 0);

			--In from stage 4
			alu_data_1_in,
			alu_data_2_in		: in	STD_LOGIC_VECTOR(N-1 downto 0);

			--In from stage 5
			mem_data_1_in,
			mem_data_2_in	 	: in	STD_LOGIC_VECTOR(N-1 downto 0);

			--From forwarding unit
			mux_reg_1_in		: in	STD_LOGIC_VECTOR(1 downto 0);
			mux_reg_2_in		: in	STD_LOGIC_VECTOR(1 downto 0);

			--Out to stage 4
			alu_result_out,
			dmem_data			: out	STD_LOGIC_VECTOR(N-1 downto 0);

			alu_flags_out		: out	ALU_FLAGS;

			wb_out,
			m_we_out			: out	STD_LOGIC;

			reg_r_out			: out	STD_LOGIC_VECTOR(4 downto 0)
		);
	end component;
	signal stage_3_out_dmem_data	: std_logic_vector(N-1 downto 0);
	signal stage_3_out_m_we			: STD_LOGIC;
	signal stage_3_out_wb			: STD_LOGIC;
	signal stage_3_out_alu_result	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal stage_3_out_alu_flags	: alu_flags;
	signal stage_3_out_reg_r		: STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);

--	Definition and signals for pipe_stage4
	component pipe_stage4
		port(
			clk					: in	STD_LOGIC;
			--from stage 3
			wb_in				: in	STD_LOGIC;
			reg_r_in			: in	STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);
			dmem_data_in		: in	STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);
			alu_result_in		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			
			--to stage 5
			wb_out				: out	STD_LOGIC;
			reg_r_out			: out	STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);
			dmem_data_out		: out	STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);
			alu_result_out		: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component;
	signal stage_4_out_wb			: STD_LOGIC;
	signal stage_4_out_alu_result	: STD_LOGIC_VECTOR(N-1 downto 0);
	signal stage_4_out_dmem_data	: STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);
	signal stage_4_out_reg_r		: STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);

--	Definition and signals for forwarding unit
	component forwarding_unit
	port(
		ex_reg_addr_in_1,
		ex_reg_addr_in_2,
		mem_reg_addr_in,
		wb_reg_addr_in			: in std_logic_vector(RADDR_BUS-1 downto 0);

		mem_reg_we,
		wb_reg_we				: in std_logic;

		reg_1_mux_control_out,
		reg_2_mux_control_out	: out std_logic_vector(1 downto 0)
	);
	end component;
	signal fw_reg_1_mux_control	: std_logic_vector(1 downto 0);
	signal fw_reg_2_mux_control	: std_logic_vector(1 downto 0);

--	Other
	signal alu_mem_mux_out	: std_logic_vector(N-1 downto 0);
begin
	--STAGE 1
	stage_1: pipe_stage1
	port map(
		clk					=> clk,
		reset				=> reset,
		processor_enable	=> processor_enable,
		--ctrl
		if_stall			=> stage_2_out_if_stall,
		if_flush			=> stage_2_out_if_flush,
		--to/from imem
		instr_data			=> imem_data_in,
		instr_addr			=> imem_address,
		--in from stage 2
		pc_in				=> stage_2_out_pc,
		pc_we				=> stage_2_out_pc_we,
		--out to stage 2
		pc_inc_out			=> stage_1_out_pc,
		instruction			=> stage_1_out_instruction
	);
	
	--STAGE 2
	stage_2: pipe_stage2
	port map(
		clk				=> clk,
		reset			=> reset,
		processor_enable=> processor_enable,

		--in from stage 1
		pc_in			=> stage_1_out_pc,
		instruction		=> stage_1_out_instruction,

		--in from stage 4/5
		reg_r_in		=> stage_4_out_reg_r,
			--alu_result/dmem_out
		data_in			=> alu_mem_mux_out,
		wb_in			=> stage_4_out_wb,

		--out to stage 1
		pc_we			=> stage_2_out_pc_we,
		pc_out			=> stage_2_out_pc,
		if_stall		=> stage_2_out_if_stall,
		if_flush		=> stage_2_out_if_flush,
		--out to stage 3
			--TODO, why is the function going out? ANSWER: Alu_ctrl needs it.
		func_out		=> stage_2_out_func,
		alu_op_out		=> stage_2_out_alu_op,
		m_we_out		=> stage_2_out_m_we,
		wb_out			=> stage_2_out_wb,
		reg_dst_out		=> stage_2_out_reg_dst,
		alu_src_out		=> stage_2_out_alu_src,
		mem_to_reg		=> stage_2_out_mem_to_reg,
		alu_reg_1_out	=> stage_2_out_alu_reg_1,
		alu_reg_2_out	=> stage_2_out_alu_reg_2,
		imm_val_out		=> stage_2_out_imm_val,
		reg_rt_out		=> stage_2_out_reg_rt,
		reg_rd_out		=> stage_2_out_reg_rd,
		--out to forwarding unit
		reg_rs_out		=> stage_2_out_reg_rs
	);

	--STAGE 3
	stage_3: pipe_stage3
	port map(
		clk				=> clk,
		processor_enable=> processor_enable,
		--in from stage 2
		func_in			=> stage_2_out_func,
		alu_ctrl_op_in		=> stage_2_out_alu_op,

		m_we_in			=> stage_2_out_m_we,
		wb_in			=> stage_2_out_wb,

		reg_dst_in		=> stage_2_out_reg_dst,
		alu_src_in		=> stage_2_out_alu_src,

		reg_data_1_in	=> stage_2_out_alu_reg_1,
		reg_data_2_in	=> stage_2_out_alu_reg_2,

		imm_val_in		=> stage_2_out_imm_val,

		reg_rt_in		=> stage_2_out_reg_rt,
		reg_rd_in		=> stage_2_out_reg_rd,

		--in from stage 4
		alu_data_1_in	=> stage_2_out_alu_reg_1,
		alu_data_2_in	=> stage_2_out_alu_reg_2,

		--in from stage 5
		mem_data_1_in	=> stage_2_out_alu_reg_1,
		mem_data_2_in	=> stage_2_out_alu_reg_2,

		--in from forwarding unit
		mux_reg_1_in	=> fw_reg_1_mux_control,
		mux_reg_2_in	=> fw_reg_2_mux_control,

		--out to stage 4
		m_we_out		=> stage_3_out_m_we,
		wb_out			=> stage_3_out_wb,

		dmem_data	=> stage_3_out_dmem_data,
		alu_result_out	=> stage_3_out_alu_result,

		alu_flags_out	=> stage_3_out_alu_flags,

		reg_r_out		=> stage_3_out_reg_r
	);
	dmem_write_enable	<= stage_3_out_m_we;
	
	fwu : forwarding_unit
	port map(
		ex_reg_addr_in_1		=> stage_2_out_reg_rs,
		ex_reg_addr_in_2		=> stage_2_out_reg_rt,
		mem_reg_addr_in		 	=> stage_3_out_reg_r,
		wb_reg_addr_in			=> stage_4_out_reg_r,

		mem_reg_we				=> stage_3_out_wb,
		wb_reg_we				=> stage_4_out_wb,

		reg_1_mux_control_out	=> fw_reg_1_mux_control,
		reg_2_mux_control_out	=> fw_reg_2_mux_control
	);
	--STAGE 4
	dmem_address_wr		<= stage_3_out_alu_result(DADDR_BUS-1 downto 0);
	dmem_address		<= stage_3_out_alu_result(DADDR_BUS-1 downto 0);
	dmem_data_out		<= stage_3_out_dmem_data;

	stage_4: pipe_stage4
	port map(
		clk				=> clk,
		--in from stage 3
		wb_in			=> stage_3_out_wb,
		reg_r_in		=> stage_3_out_reg_r,
		dmem_data_in	=> dmem_data_in,
		alu_result_in	=> stage_3_out_alu_result,
		--out to stage 5/1
		wb_out			=> stage_4_out_wb,
		reg_r_out		=> stage_4_out_reg_r,
		dmem_data_out	=> stage_4_out_dmem_data,
		alu_result_out	=> stage_4_out_alu_result
	);
	
	alu_mem_mux : process(stage_2_out_mem_to_reg, stage_4_out_alu_result, stage_4_out_dmem_data)
	begin
		if stage_2_out_mem_to_reg = '1' then
			alu_mem_mux_out <= stage_4_out_alu_result;
		else
			alu_mem_mux_out <= stage_4_out_dmem_data;
		end if;
	end process;
	--STAGE 5
end behave;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity pipe_stage2 is
	port(
		clk				: in	STD_LOGIC;
		reset			: in	STD_LOGIC;

		--in from stage 1
		pc_in			: in	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);

		--in from instruction memory
		instruction_in	: in	STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);

		--in from stage 4/5
		reg_r_in		: in	STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);
			--alu_result/dmem_out
		data_in			: in	STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);
		wb_in			: in	STD_LOGIC;

		--out to stage 1
		pc_we			: out	STD_LOGIC;
		branch_target	: out	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		branch_enable	: out	STD_LOGIC;

		--out to stage 3
			--TODO, why is the function going out? ANSWER: Alu_ctrl needs it.
		func_out		: out	STD_LOGIC_VECTOR(5 downto 0);
		alu_op_out		: out	ALU_OP;
		m_we_out		: out	STD_LOGIC;
		wb_out			: out	STD_LOGIC;
		reg_dst_out		: out	STD_LOGIC;
		alu_src_out		: out	STD_LOGIC;
		alu_reg_1_out	: out	STD_LOGIC_VECTOR(31 downto 0);
		alu_reg_2_out	: out	STD_LOGIC_VECTOR(31 downto 0);
		imm_val_out		: out	STD_LOGIC_VECTOR(31 downto 0);
		reg_rt_out		: out	STD_LOGIC_VECTOR(4 downto 0);
		reg_rd_out		: out	STD_LOGIC_VECTOR(4 downto 0);

		--out to forwarding unit
		reg_rs_out		: out	STD_LOGIC_VECTOR(4 downto 0)
	);
end pipe_stage2;

architecture behave of pipe_stage2 is

	component register_file is
		port(
			CLK				: in	STD_LOGIC;
			RESET			: in	STD_LOGIC;
			RW				: in	STD_LOGIC;
			RS_ADDR			: in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0);
			RT_ADDR			: in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0);
			RD_ADDR			: in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0);
			WRITE_DATA		: in	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
			RS				: out	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
			RT				: out	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0)
		);
	end component;

	component control_unit is
		port(
			CLK				: in	STD_LOGIC;
			RESET			: in	STD_LOGIC;
			OpCode			: in	STD_LOGIC_VECTOR (31 downto 26);
			ALUOp			: out	ALU_OP;
			RegDst			: out	STD_LOGIC;
			Branch			: out	STD_LOGIC;
			MemtoReg		: out	STD_LOGIC;
			MemWrite		: out	STD_LOGIC;
			ALUSrc			: out	STD_LOGIC;
			RegWrite		: out	STD_LOGIC;
			Jump			: out	STD_LOGIC;
			PCWriteEnb		: out	STD_LOGIC;
			SRWriteEnb		: out	STD_LOGIC
		);
	end component;

	component hazard_detection_unit is
		port(
			clk					: in	STD_LOGIC;
			reset				: in	STD_LOGIC;
			stage1_rs			: in	STD_LOGIC_VECTOR(4 downto 0);
			stage1_rt			: in	STD_LOGIC_VECTOR(4 downto 0);
			stage2_rt			: in	STD_LOGIC_VECTOR(4 downto 0);
			mem_read			: in	STD_LOGIC;
			--Also stage1 programcounter stall when equal to zero
			pc_wr_enb			: out	STD_LOGIC
		);
	end component;

	component adder is
	generic (N: natural);
		port(
			X		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			Y		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			CIN		: in	STD_LOGIC;
			COUT	: out	STD_LOGIC;
			R		: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component;

	--Register file signals
	signal reg_rs_data	: STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
	signal reg_rt_data	: STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);

	--Internal signals
	signal flush				: STD_LOGIC := '0';
	signal reg_rt_reg			: STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);
	signal sxt_signal_intrnl	: STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);

	--control signals
	signal alu_op_internal		: ALU_OP;
	signal reg_dst_internal		: STD_LOGIC;
	signal mem_to_reg_internal	: STD_LOGIC;
	signal mem_wr_internal		: STD_LOGIC;
	signal alu_src_internal		: STD_LOGIC;
	signal reg_wr_internal		: STD_LOGIC;
	signal jump_enable			: std_logic;

	--hazard detection unit signals
	signal hdu_reset : STD_LOGIC := '0';

begin
	sxt_signal_intrnl		<= SXT(instruction_in(15 downto 0), 32);

	registers: register_file
	port map(
		CLK			=> clk,
		RESET		=> hdu_reset,
		RW			=> wb_in,
		RS_ADDR		=> instruction_in(25 downto 21),
		RT_ADDR		=> instruction_in(20 downto 16),
		RD_ADDR		=> reg_r_in,
		WRITE_DATA	=> data_in,
		RS			=> reg_rs_data,
		RT			=> reg_rt_data
	);

	branch_adder: adder
	generic map(N => 32)
	port map(
		X		=> sxt_signal_intrnl,
		Y		=> pc_in,
		CIN		=> '0',
		R		=> branch_target
	);

	hazards: hazard_detection_unit
	port map(
		clk			=> clk,
		reset		=> reset,
		stage1_rs	=> instruction_in(25 downto 21),
		stage1_rt	=> instruction_in(20 downto 16),
		stage2_rt	=> reg_rt_reg,
		mem_read	=> mem_to_reg_internal,
		 --Also stage1 programcounter stall when equal to zero
		pc_wr_enb	=> pc_we
	);

	CTRL: control_unit
	port map(
		CLK			=> clk,
		RESET		=> reset,
		OpCode		=> instruction_in(31 downto 26),
		ALUOp		=> alu_op_internal,
		RegDst		=> reg_dst_internal,
		Branch		=> branch_enable,--TODO
		MemtoReg	=> mem_to_reg_internal,
		MemWrite	=> mem_wr_internal,
		ALUSrc		=> alu_src_internal,
		RegWrite	=> reg_wr_internal,
		Jump		=> jump_enable,--TODO say whaaat? Har vi ikke jump?
		PCWriteEnb	=> pc_we,--TODO
		SRWriteEnb	=> sr_we--TODO
	);

	write_buffer_register: process(clk)
	begin
		if rising_edge(clk) then
			reg_rs_out				<= instruction_in(25 downto 21);
			reg_rt_reg				<= instruction_in(20 downto 16);
			reg_rd_out				<= instruction_in(15 downto 11);
			alu_reg_1_out			<= reg_rs_data;
			alu_reg_2_out			<= reg_rt_data;
			imm_val_out				<= sxt_signal_intrnl;
			alu_op_out				<= alu_op_internal;
			if flush = '0' then
				wb_out		<= reg_wr_internal;
				mem_to_reg	<= mem_to_reg_internal;
				m_we_out	<= mem_wr_internal;
				alu_op_out	<= alu_op_internal;
				reg_dst_out	<= reg_dst_internal;
			else
				wb_out		<= '0';
				mem_to_reg	<= '0';
				m_we_out	<= '0';
				alu_src_out <= '0';
				reg_dst_out	<= '0';
			end if;
		end if;
		reg_rt_out <= reg_rt_reg;
	end process;

end behave;

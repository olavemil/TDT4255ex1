library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity pipe_stage2 is
	port(
		clk				: in	STD_LOGIC;
		reset			: in	STD_LOGIC;
		processor_enable: in	STD_LOGIC;

		--in from stage 1
		pc_in			: in	STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);

		--in from instruction memory
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
		branch_out		: out	STD_LOGIC;

		--out to stage 3
			--TODO, why is the function going out? ANSWER: Alu_ctrl needs it.
		func_out		: out	STD_LOGIC_VECTOR(5 downto 0);
		alu_op_out		: out	ALU_OP;
		m_we_out		: out	STD_LOGIC;
		wb_out			: out	STD_LOGIC;
		reg_dst_out		: out	STD_LOGIC;
		alu_src_out		: out	STD_LOGIC;
		mem_to_reg_out	: out	STD_LOGIC;
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
			Jump			: out	STD_LOGIC
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
			nops				: out	STD_LOGIC;
			if_id_stall			: out	STD_LOGIC;
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
	signal nops					: STD_LOGIC;
	signal flush				: STD_LOGIC;
	signal reg_rt_reg			: STD_LOGIC_VECTOR(RADDR_BUS-1 downto 0);
	signal imm_val_reg			: STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);
	signal mem_to_reg			: STD_LOGIC;
	signal branch_offset		: STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);

	signal branch_enable		: STD_LOGIC;
	signal branch_mux_out		: STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
	signal branch_target		: STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);

	--control signals
	signal alu_op_internal		: ALU_OP;
	signal reg_dst_internal		: STD_LOGIC;
	signal mem_to_reg_internal	: STD_LOGIC;
	signal mem_wr_internal		: STD_LOGIC;
	signal alu_src_internal		: STD_LOGIC;
	signal reg_wr_internal		: STD_LOGIC;
	signal jump_enable			: std_logic;

begin
	imm_val_reg		<= SXT(instruction(15 downto 0), DDATA_BUS);
	branch_offset	<= SXT(instruction(15 downto 0), IADDR_BUS);
	func_out		<= instruction(5 downto 0);
	if_flush		<= flush;

	registers: register_file
	port map(
		CLK			=> clk,
		RESET		=> reset,
		RW			=> wb_in,
		RS_ADDR		=> instruction(25 downto 21),
		RT_ADDR		=> instruction(20 downto 16),
		RD_ADDR		=> reg_r_in,
		WRITE_DATA	=> data_in,
		RS			=> reg_rs_data,
		RT			=> reg_rt_data
	);

	branch_adder: adder
	generic map(N => IADDR_BUS)
	port map(
		X		=> branch_offset,
		Y		=> pc_in,
		CIN		=> '0',
		R		=> branch_target
	);

	branch_mux: process(branch_enable, reg_rs_data, reg_rt_data, branch_target, pc_in)
	begin
		if branch_enable = '1' and (reg_rs_data = reg_rt_data) then
			branch_mux_out	<= branch_target;
			flush			<= '1';
			branch_out		<= '1';
		else
			branch_mux_out	<= pc_in;
			flush			<= '0';
			branch_out		<= '0';
		end if;
	end process;

	jump_mux: process(jump_enable, pc_in, instruction, branch_mux_out)
	begin
		if jump_enable = '1' then
			pc_out <= instruction(IADDR_BUS-1 downto 0);
		else
			pc_out <= branch_mux_out;
		end if;
	end process;

	hazards: hazard_detection_unit
	port map(
		clk			=> clk,
		reset		=> reset,
		stage1_rs	=> instruction(25 downto 21),
		stage1_rt	=> instruction(20 downto 16),
		stage2_rt	=> reg_rt_reg,
		mem_read	=> mem_to_reg,
		--Also stage1 programcounter stall when equal to zero
		nops		=> nops,
		if_id_stall	=> if_stall,
		pc_wr_enb	=> pc_we
	);

	CTRL: control_unit
	port map(
		CLK			=> clk,
		RESET			=> reset,
		OpCode		=> instruction(31 downto 26),
		ALUOp			=> alu_op_internal,
		RegDst		=> reg_dst_internal,
		Branch		=> branch_enable,--TODO
		MemtoReg		=> mem_to_reg_internal,
		MemWrite		=> mem_wr_internal,
		ALUSrc		=> alu_src_internal,
		RegWrite		=> reg_wr_internal,
		Jump			=> jump_enable
	);

	write_buffer_register: process(clk, processor_enable, reg_rt_reg, reg_rt_data, reg_rs_data, mem_to_reg)
	begin
		if rising_edge(clk) and processor_enable = '1' then
			reg_rs_out				<= instruction(25 downto 21);
			reg_rt_reg				<= instruction(20 downto 16);
			reg_rd_out				<= instruction(15 downto 11);
			alu_reg_1_out 			<= reg_rt_data;
			alu_reg_2_out 			<= reg_rs_data;

			imm_val_out				<= imm_val_reg;
			alu_op_out				<= alu_op_internal;
			alu_src_out				<= alu_src_internal;
			reg_dst_out				<= reg_dst_internal;
			mem_to_reg				<= mem_to_reg_internal;
			if nops = '0' and flush = '0' then
				wb_out		<= reg_wr_internal;
				m_we_out	<= mem_wr_internal;
			else
				wb_out		<= '0';
				m_we_out	<= '0';
			end if;
		end if;
		reg_rt_out <= reg_rt_reg;
		mem_to_reg_out <= mem_to_reg;
	end process;

end behave;

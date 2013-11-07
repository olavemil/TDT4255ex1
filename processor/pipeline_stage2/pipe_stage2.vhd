library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity pipe_stage2 is
	port(
		clk				: in STD_LOGIC;
		reset			: in STD_LOGIC;
		--in from stage 1
		instruction_in	: in STD_LOGIC_VECTOR(IDATA_BUS-1 downto 0);
		pc_in			: in STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		--in from stage 4/5
		reg_r_in		: in STD_LOGIC_VECTOR(31 downto 0);
		data_in			: in STD_LOGIC_VECTOR(31 downto 0);--alu_result/dmem_out
		reg_w_e			: in STD_LOGIC;
		--in from stage 3
		id_ex_reg_rt_in : in STD_LOGIC_VECTOR(4 downto 0);
		id_ex_mem_rd	: in STD_LOGIC;

		--out to stage 1
		pc_we			: out STD_LOGIC;
		if_id_wr_enb	: out STD_LOGIC;
		flush_out		: out STD_LOGIC;
		branch_target	: out STD_LOGIC_VECTOR(IADDR_BUS-1 downto 0);
		branch_enable	: out STD_LOGIC;
		--out to stage 3
		func_out		: out STD_LOGIC_VECTOR(5 downto 0);	--TODO, why is the function going out? ANSWER: Alu_ctrl needs it.
		alu_op_out		: out ALU_OP;
		sr_we			: out std_logic;

		m_we_out		: out STD_LOGIC;
		mem_to_reg		: out STD_LOGIC;
		wb_out			: out STD_LOGIC;

		reg_dst_out		: out STD_LOGIC;
		alu_src_out		: out STD_LOGIC;

		alu_reg_1_out	: out STD_LOGIC_VECTOR(31 downto 0);
		alu_reg_2_out	: out STD_LOGIC_VECTOR(31 downto 0);

		imm_val_out 	: out STD_LOGIC_VECTOR(31 downto 0);

		reg_rt_out 		: out STD_LOGIC_VECTOR(4 downto 0);
		reg_rd_out 		: out STD_LOGIC_VECTOR(4 downto 0);
		--out to forwarding unit
		reg_rs_out 		: out	STD_LOGIC_VECTOR(4 downto 0)
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
component control_unit is
	port(
		CLK 			: in 	STD_LOGIC;
		RESET			: in 	STD_LOGIC;
		OpCode			: in	STD_LOGIC_VECTOR (31 downto 26);
		ALUOp			: out	ALU_OP;
		RegDst			: out	STD_LOGIC;
		Branch			: out 	STD_LOGIC;
		MemtoReg		: out 	STD_LOGIC;
		MemWrite		: out 	STD_LOGIC;
		ALUSrc			: out 	STD_LOGIC;
		RegWrite		: out 	STD_LOGIC;
		Jump			: out 	STD_LOGIC;
		PCWriteEnb		: out 	STD_LOGIC;
		SRWriteEnb		: out 	STD_LOGIC;
		if_flush		: out 	STD_LOGIC
	);
end component;

component hazard_detection_unit is
	port(
		id_ex_reg_rt	: in STD_LOGIC_VECTOR(4 downto 0);
		if_id_reg_rs	: in STD_LOGIC_VECTOR(4 downto 0);
		if_id_reg_rt	: in STD_LOGIC_VECTOR(4 downto 0);
		id_ex_mem_rd	: in STD_LOGIC;
		nops_activate	: out STD_LOGIC;
		pc_wr_enb		: out STD_LOGIC;
		if_id_wr_enb	: out STD_LOGIC
	);
end component;

component adder is
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


--control signals
signal alu_op_internal	: ALU_OP;
signal reg_dst_internal :STD_LOGIC;
signal mem_to_reg_internal : STD_LOGIC;
signal mem_wr_internal :STD_LOGIC;
signal alu_src_internal : STD_LOGIC;
signal reg_wr_internal : STD_LOGIC;
signal jump_enable	: std_logic;

--hazard signals
signal nops : STD_LOGIC;

begin

	registers: register_file
	port map(
		CLK 		=> clk,
		RESET		=> reset,
		RW			=>	reg_w_e,
		RS_ADDR 	=>	instruction_in(25 downto 21),
		RT_ADDR 	=> instruction_in(20 downto 16),
		RD_ADDR 	=>	reg_r_in,
		WRITE_DATA	=>	data_in,
		RS			=>	reg_rs_data,
		RT			=>	reg_rt_data
	);

	branch_adder: adder
	port map(
		X		=> SXT(instruction_in(15 downto 0), 32),
		Y		=> pc_in,
		CIN		=> '0',
		COUT	=> '-',
		R		=> branch_target
	);


	hazards: hazard_detection_unit
	port map(
		nops_activate	=> nops,
		id_ex_mem_rd	=> id_ex_mem_rd,
		if_id_reg_rs	=> instruction_in(25 downto 21),
		if_id_reg_rt	=> instruction_in(20 downto 16),
		id_ex_reg_rt	=> id_ex_reg_rt_in,
		pc_wr_enb		=> pc_we,
		if_id_wr_enb	=> if_id_wr_enb
	);

	CTRL: control_unit
	port map(
		CLK 		=> clk,
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
		SRWriteEnb	=> sr_we,--TODO
		if_flush	=> flush_out
	);


	write_buffer_register: process(clk)
	begin
		if rising_edge(clk) then
			reg_rs_out 	<= instruction_in(25 downto 21);
			reg_rt_out	<= instruction_in(20 downto 16);
			reg_rd_out	<= instruction_in(15 downto 11);
			alu_reg_1_out	<= reg_rs_data;
			alu_reg_2_out	<= reg_rt_data;
			imm_val_out	<= SXT(instruction_in(15 downto 0), 32);
			alu_op_out	<= alu_op_internal;
			if nops = '0' then
				wb_out		<= reg_wr_internal;
				mem_to_reg	<= mem_to_reg_internal;
				m_we_out		<= mem_wr_internal;
				alu_op_out	<= alu_op_internal;
				reg_dst_out	<= reg_dst_internal;
			else
				wb_out		<= '0';
				mem_to_reg	<= '0';
				m_we_out		<= '0';
				alu_src_out <= '0';
				reg_dst_out	<= '0';
			end if;
		end if;
	end process;
end behave;





















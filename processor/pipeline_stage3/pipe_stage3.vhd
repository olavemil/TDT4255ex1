
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity pipe_stage3 is
    port (
        clk                 : in    STD_LOGIC;
        --In from stage 2
        func_in				: in	STD_LOGIC_VECTOR(5 downto 0);
        alu_op_in			: in	ALU_OP_INPUT;
        
        m_we_in,
        wb_in				: in	STD_LOGIC;
        
        reg_dst_in          : in    STD_LOGIC;
        alu_src_in          : in    STD_LOGIC;
        
        reg_data_1_in,
        reg_data_2_in       : in    STD_LOGIC_VECTOR(N-1 downto 0);
        
        imm_val_in           : in    STD_LOGIC_VECTOR(N-1 downto 0);
        
        reg_rt_in,
        reg_rd_in			: in	STD_LOGIC_VECTOR(4 downto 0);
        
        --In from stage 4
        alu_data_1_in,
        alu_data_2_in       : in    STD_LOGIC_VECTOR(N-1 downto 0);
        
        --In from stage 5
        mem_data_1_in,
        mem_data_2_in       : in    STD_LOGIC_VECTOR(N-1 downto 0);
        
        --From forwarding unit
        mux_reg_1_in        : in	STD_LOGIC_VECTOR(1 downto 0);
        mux_reg_2_in        : in	STD_LOGIC_VECTOR(1 downto 0);
        
        --Out to stage 4
        alu_result_out,
        dmem_address		: out	STD_LOGIC_VECTOR(N-1 downto 0);
        
        alu_flags_out       : out   ALU_FLAGS;
        
        wb_out,
        m_we_out			: out	STD_LOGIC;
        
        reg_r_out			: out	STD_LOGIC_VECTOR(4 downto 0)
    );
end pipe_stage3;

architecture behaviour of pipe_stage3 is
--ALU
    --ALU input
    signal mux_reg_1_data_out, mux_reg_2_data_out, mux_alu_src_out : STD_LOGIC_VECTOR(N-1 downto 0);
    signal alu_op       : ALU_INPUT;
    --ALU component
    component alu
        port (
            X			: in STD_LOGIC_VECTOR(N-1 downto 0);
            Y			: in STD_LOGIC_VECTOR(N-1 downto 0);
            ALU_IN		: in ALU_INPUT;
            R			: out STD_LOGIC_VECTOR(N-1 downto 0);
            FLAGS		: out ALU_FLAGS
        );
    end component;
    --ALU output
    signal alu_result   : STD_LOGIC_VECTOR(N-1 downto 0);
    signal alu_flags    : ALU_FLAGS;
    --Reg r
    signal reg_r        : STD_LOGIC_VECTOR(4 downto 0);
begin
    mux_reg_data : process(mux_reg_1_in)
    begin
        if mux_reg_1_in = "00" then
            mux_reg_1_data_out <= reg_data_1_in;
        elsif mux_reg_1_in = "01" then
            mux_reg_1_data_out <= alu_data_1_in;
        else
            mux_reg_1_data_out <= mem_data_1_in;
        end if;
    end process;
    mux_reg_data : process(mux_reg_2_in)
    begin 
        if mux_reg_1_in = "00" then
            mux_reg_1_data_out <= reg_data_1_in;
        elsif mux_reg_1_in = "01" then
            mux_reg_1_data_out <= alu_data_1_in;
        else
            mux_reg_1_data_out <= mem_data_1_in;
        end if;
    end process;
    mux_alu_src : process(alu_src_in)
    begin
        if alu_src_in = '1' then
            mux_alu_src_out <= mux_reg_2_data_out;
        else
            mux_alu_src_out <= imm_val_in;
        end if;
    end process;
    
    
    --THIS NEEDS WORK!
    --Implemented using only ALU_OP.Op0 and ALU_OP.Op1,
    --for instructions specified in fig 4.12, page 317.
    alu_control : process(imm_val_in, alu_op_in)
    begin
        if alu_op_in.Op0 = '1' then
            --branch
            alu_op <= ('0', '1', '1', '0');
        else
            if alu_op_in.Op1 = '0' then
                alu_op <= ('0', '0', '1', '0');
            else
                case imm_value_in is
                    when "100000" => --ADD
                        alu_op <= ('0', '0', '1', '0');
                    when "100010" => --SUB
                        alu_op <= ('0', '1', '1', '0');
                    when "100100" => --AND
                        alu_op <= ('0', '0', '0', '0');
                    when "100101" => --OR
                        alu_op <= ('0', '0', '0', '1');
                    when "101010" => --SLT
                        alu_op <= ('0', '1', '1', '1');
                    when others =>
                        alu_op <= ('1', '1', '1', '1');
                end case;
            end if;
        end if;
    end process;
    alu_unit : alu
    port map (
        X       => mux_reg_1_data_out,
        Y       => mux_alu_src_out,
        ALU_IN  => alu_op,
        R       => alu_result,
        FLAGS   => alu_flags_out
    );
    
    mux_reg_dst : process(reg_dst_in)
    begin
        if reg_dst = '1' then
            reg_r <= reg_rd_in;
        else
            reg_r <= reg_rt_in;
        end if;
    end process;
    --Pipeline registers for stage 3
    pipeline_regz_yo : process(clk)
    begin
        if rising_edge(clk) then
            wb_out          <= wb_in;
            m_we_out        <= m_we_in;
            alu_result_out  <= alu_result;
            alu_flags_out   <= alu_flags;
            dmem_address    <= mux_reg_2_data_out;
            reg_r_out       <= reg_r;
        end if;
    end process;
end behaviour;


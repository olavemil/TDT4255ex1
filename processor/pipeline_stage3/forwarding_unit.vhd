library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use WORK.MIPS_CONSTANT_PKG.ALL;

entity forwarding_unit is
    port(
        ex_reg_addr_in_1,
        ex_reg_addr_in_2,
        mem_reg_addr_in,
        wb_reg_addr_in          : in std_logic_vector(RADDR_BUS-1 downto 0);
        
        mem_reg_we,
        wb_reg_we               : in std_logic;
        
        reg_1_mux_control_out,
        reg_2_mux_control_out   : out std_logic_vector(1 downto 0)
    );
end forwarding_unit;

architecture behaviour of forwarding_unit is

begin
    forward : process(mem_reg_addr_in, ex_reg_addr_in_1, wb_reg_addr_in, ex_reg_addr_in_2, mem_reg_we, wb_reg_we)
    begin
        if (mem_reg_addr_in = ex_reg_addr_in_1) and (mem_reg_we = '1') then
            reg_1_mux_control_out <= "10";
        elsif (wb_reg_addr_in = ex_reg_addr_in_1) and (wb_reg_we = '1') then
            reg_1_mux_control_out <= "01";
        else
            reg_1_mux_control_out <= "00";
        end if;
        
        if (mem_reg_addr_in = ex_reg_addr_in_2) and (mem_reg_we = '1') then
            reg_2_mux_control_out <= "10";
        elsif (wb_reg_addr_in = ex_reg_addr_in_2) and (wb_reg_we = '1') then
            reg_2_mux_control_out <= "01";
        else
            reg_2_mux_control_out <= "00";
        end if;
    end process;
end behaviour;


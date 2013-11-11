--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:38:03 10/02/2013
-- Design Name:   
-- Module Name:   M:/MultiCycleMips/tb_processor.vhd
-- Project Name:  MultiCycleMips
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: processor
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_processor IS
END tb_processor;
 
ARCHITECTURE behavior OF tb_processor IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT processor
    port(
		clk				: in	STD_LOGIC;
		reset				: in	STD_LOGIC;
		processor_enable	: in	STD_LOGIC;
		imem_address 		: out	STD_LOGIC_VECTOR (IADDR_BUS-1 downto 0);
		imem_data_in 		: in	STD_LOGIC_VECTOR (IDATA_BUS-1 downto 0);
		dmem_data_in 		: in	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
		dmem_address 		: out	STD_LOGIC_VECTOR (DADDR_BUS-1 downto 0);
		dmem_address_wr		: out	STD_LOGIC_VECTOR (DADDR_BUS-1 downto 0);
		dmem_data_out		: out	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
		dmem_write_enable	: out	STD_LOGIC
		);
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal processor_enable : std_logic := '0';
   signal imem_data_in : std_logic_vector(IDATA_BUS-1 downto 0) := (others => '0');
   signal dmem_data_in : std_logic_vector(DDATA_BUS-1 downto 0) := (others => '0');

 	--Outputs
   signal imem_address : std_logic_vector(IADDR_BUS-1 downto 0);
   signal dmem_address : std_logic_vector(DADDR_BUS-1 downto 0);
   signal dmem_address_wr : std_logic_vector(DADDR_BUS-1 downto 0);
   signal dmem_data_out : std_logic_vector(DDATA_BUS-1 downto 0);
   signal dmem_write_enable : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: processor PORT MAP (
          clk => clk,
          reset => reset,
          processor_enable => processor_enable,
          imem_address => imem_address,
          imem_data_in => imem_data_in,
          dmem_data_in => dmem_data_in,
          dmem_address => dmem_address,
          dmem_address_wr => dmem_address_wr,
          dmem_data_out => dmem_data_out,
          dmem_write_enable => dmem_write_enable
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		wait for 100 ns;	
		reset <= '1';
		wait for clk_period;
		reset <= '0';
		
		wait for clk_period*3;
		
		
		

		-- insert stimulus here 
		imem_data_in <= X"20010002"; --LDI reg1  "2"
		wait for clk_period;
		
		imem_data_in <= X"2002000A"; --LDI reg2  "10"
		wait for clk_period;
		
		
		imem_data_in <= X"00221820"; --ADD reg3 <- reg1 + reg2 (2 + 10)
		wait for clk_period;
		assert dmem_address = x"02" report "LDI not working!"; 
		
		wait for clk_period;
		assert dmem_address = x"0A" report "LDI not working!";
		
		wait for clk_period;
		assert dmem_address = x"0C" report "ADD not working!";

			
		

      wait;
   end process;

END;

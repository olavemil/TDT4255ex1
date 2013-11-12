--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:08:49 10/26/2013
-- Design Name:   
-- Module Name:   C:/Users/chrischa/Documents/GitHub/TDT4255ex1/testbenches/tb_pipe1.vhd
-- Project Name:  TDT4255_Ex2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pipe_stage1
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_pipe1 IS
END tb_pipe1;
 
ARCHITECTURE behavior OF tb_pipe1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pipe_stage1
    PORT(
         clk : IN  std_logic;
         pc_src : IN  std_logic;
         pc_reset : IN  std_logic;
         pc_wr_enb : IN  std_logic;
         if_flush_sig : IN  std_logic;
         haz_contrl_sig : IN  std_logic;
         pc_alu_src : IN  std_logic_vector(31 downto 0);
         imem_data_in : IN  std_logic_vector(31 downto 0);
         imem_address : OUT  std_logic_vector(31 downto 0);
         pc_buffer_outpt : OUT  std_logic_vector(31 downto 0);
         imem_buffer_outpt : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal pc_src : std_logic := '0';
   signal pc_reset : std_logic := '0';
   signal pc_wr_enb : std_logic := '0';
   signal if_flush_sig : std_logic := '0';
   signal haz_contrl_sig : std_logic := '0';
   signal pc_alu_src : std_logic_vector(31 downto 0) := (others => '0');
   signal imem_data_in : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal imem_address : std_logic_vector(31 downto 0);
   signal pc_buffer_outpt : std_logic_vector(31 downto 0);
   signal imem_buffer_outpt : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pipe_stage1 PORT MAP (
          clk => clk,
          pc_src => pc_src,
          pc_reset => pc_reset,
          pc_wr_enb => pc_wr_enb,
          if_flush_sig => if_flush_sig,
          haz_contrl_sig => haz_contrl_sig,
          pc_alu_src => pc_alu_src,
          imem_data_in => imem_data_in,
          imem_address => imem_address,
          pc_buffer_outpt => pc_buffer_outpt,
          imem_buffer_outpt => imem_buffer_outpt
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      
      wait for 100 ns;
	  pc_reset	<= '1';
	  pc_wr_enb	<= '1';

      wait for clk_period*10;
		pc_reset <= '0';

      -- insert stimulus here 
	  
	  pc_alu_src <= X"0C031BD9";	  
	  
	  --Test case 1
	  wait for clk_period*4;
	  pc_src <= '1';
	  wait for clk_period;
	  pc_src <= '0';
	  
	 
		--Test case 2
	  wait for clk_period*10;
	  pc_reset <= '1';
	  wait for clk_period*2;
	  pc_reset <= '0';
	 
	  wait for clk_period*10;

      wait;
   end process;

END;

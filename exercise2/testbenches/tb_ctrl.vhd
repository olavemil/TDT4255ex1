--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:21:05 10/02/2013
-- Design Name:   
-- Module Name:   M:/MultiCycleMips/tb_ctrl.vhd
-- Project Name:  MultiCycleMips
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: control_unit
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
LIBRARY ieee, work;
USE ieee.std_logic_1164.ALL;
USE WORK.MIPS_CONSTANT_PKG.ALL;

 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_ctrl IS
END tb_ctrl;
 
ARCHITECTURE behavior OF tb_ctrl IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT control_unit
    PORT(
         CLK 		: IN  	std_logic;
         RESET 		: IN  	std_logic;
         OpCode 	: IN  	std_logic_vector(5 downto 0);
         ALUOp 		: OUT 	alu_op_input;
         RegDst 	: OUT 	std_logic;
         Branch 	: OUT 	std_logic;
         MemRead 	: OUT 	std_logic;
         MemtoReg 	: OUT 	std_logic;
         MemWrite 	: OUT 	std_logic;
         ALUSrc 	: OUT 	std_logic;
         RegWrite 	: OUT 	std_logic;
         Jump 		: OUT 	std_logic;
         PCWriteEnb : OUT 	std_logic;
         SRWriteEnb : OUT 	std_logic
        );	
    END COMPONENT;
    

	--Inputs
	signal CLK 	: std_logic := '0';
	signal RESET : std_logic := '0';
	signal OpCode : std_logic_vector(5 downto 0) := (others => '0');

	--Outputs
	signal ALUOp : alu_op_input;
	signal RegDst : std_logic;
	signal Branch : std_logic;
	signal MemRead : std_logic;
	signal MemtoReg : std_logic;
	signal MemWrite : std_logic;
	signal ALUSrc : std_logic;
	signal RegWrite : std_logic;
	signal Jump : std_logic;
	signal PCWriteEnb : std_logic;
	signal SRWriteEnb : std_logic;

	-- Clock period definitions
	constant CLK_period : time := 10 ns;
	
	--Instructions (from tb_toplevel).
   	constant ins0  : std_logic_vector(0 to 31) := X"8C010001";
	constant ins1  : std_logic_vector(0 to 31) := X"8C020002";
	constant ins2  : std_logic_vector(0 to 31) := X"8C020002";
	constant ins3  : std_logic_vector(0 to 31) := X"00221820";
	constant ins4  : std_logic_vector(0 to 31) := X"AC030005";
	constant ins5  : std_logic_vector(0 to 31) := X"10000002";
	constant ins6  : std_logic_vector(0 to 31) := X"AC030003";
	constant ins7  : std_logic_vector(0 to 31) := X"AC030004";
	constant ins8  : std_logic_vector(0 to 31) := X"AC030006";
	constant ins9  : std_logic_vector(0 to 31) := X"AC030007";
	constant ins10 : std_logic_vector(0 to 31) := X"3C030006";
	constant ins11 : std_logic_vector(0 to 31) := X"AC030008";
	constant ins12 : std_logic_vector(0 to 31) := X"00231820";
	constant ins13 : std_logic_vector(0 to 31) := X"AC030009";
	constant ins14 : std_logic_vector(0 to 31) := X"1000FFFD";
	constant ins15 : std_logic_vector(0 to 31) := X"AC03000A";
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: control_unit PORT MAP (
          CLK => CLK,
          RESET => RESET,
          OpCode => OpCode,
          ALUOp => ALUOp,
          RegDst => RegDst,
          Branch => Branch,
          MemRead => MemRead,
          MemtoReg => MemtoReg,
          MemWrite => MemWrite,
          ALUSrc => ALUSrc,
          RegWrite => RegWrite,
          Jump => Jump,
          PCWriteEnb => PCWriteEnb,
          SRWriteEnb => SRWriteEnb
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;

      -- insert stimulus here 
	  OpCode <= ins0(31 downto 26);
	  

      wait;
   end process;

END;

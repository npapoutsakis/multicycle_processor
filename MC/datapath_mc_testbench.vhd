--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:11:52 05/09/2022
-- Design Name:   
-- Module Name:   C:/Users/Nick-PC/Documents/VHDL/HRY302-Phase04v2/datapath_mc_testbench.vhd
-- Project Name:  HRY302-Phase04v2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DATAPATH_MC
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
 
ENTITY datapath_mc_testbench IS
END datapath_mc_testbench;
 
ARCHITECTURE behavior OF datapath_mc_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DATAPATH_MC
    PORT(
         D_CLK : IN  std_logic;
         D_Reset : IN  std_logic;
         D_PC_Sel : IN  std_logic;
         D_PC_LdEn : IN  std_logic;
         D_PC : OUT  std_logic_vector(31 downto 0);
         alpha_we : IN  std_logic;
         beta_we : IN  std_logic;
         instr_reg_we : IN  std_logic;
         mem_reg_we : IN  std_logic;
         alu_reg_we : IN  std_logic;
         D_Instr : IN  std_logic_vector(31 downto 0);
         D_RF_WrEnable : IN  std_logic;
         D_RF_WrData_Selection : IN  std_logic;
         D_RF_B_Selection : IN  std_logic;
         D_ALU_Bin_Selection : IN  std_logic;
         D_ALU_Function : IN  std_logic_vector(3 downto 0);
         D_ALU_Zero : OUT  std_logic;
         D_Byte_Operation : IN  std_logic;
         D_MEM_WrEnable : IN  std_logic;
         D_MM_ReadData : IN  std_logic_vector(31 downto 0);
         D_MM_Addr : OUT  std_logic_vector(31 downto 0);
         D_MM_WrEn : OUT  std_logic;
         D_MM_WrData : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal D_CLK : std_logic := '0';
   signal D_Reset : std_logic := '0';
   signal D_PC_Sel : std_logic := '0';
   signal D_PC_LdEn : std_logic := '0';
   signal alpha_we : std_logic := '0';
   signal beta_we : std_logic := '0';
   signal instr_reg_we : std_logic := '0';
   signal mem_reg_we : std_logic := '0';
   signal alu_reg_we : std_logic := '0';
   signal D_Instr : std_logic_vector(31 downto 0) := (others => '0');
   signal D_RF_WrEnable : std_logic := '0';
   signal D_RF_WrData_Selection : std_logic := '0';
   signal D_RF_B_Selection : std_logic := '0';
   signal D_ALU_Bin_Selection : std_logic := '0';
   signal D_ALU_Function : std_logic_vector(3 downto 0) := (others => '0');
   signal D_Byte_Operation : std_logic := '0';
   signal D_MEM_WrEnable : std_logic := '0';
   signal D_MM_ReadData : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal D_PC : std_logic_vector(31 downto 0);
   signal D_ALU_Zero : std_logic;
   signal D_MM_Addr : std_logic_vector(31 downto 0);
   signal D_MM_WrEn : std_logic;
   signal D_MM_WrData : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant D_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DATAPATH_MC PORT MAP (
          D_CLK => D_CLK,
          D_Reset => D_Reset,
          D_PC_Sel => D_PC_Sel,
          D_PC_LdEn => D_PC_LdEn,
          D_PC => D_PC,
          alpha_we => alpha_we,
          beta_we => beta_we,
          instr_reg_we => instr_reg_we,
          mem_reg_we => mem_reg_we,
          alu_reg_we => alu_reg_we,
          D_Instr => D_Instr,
          D_RF_WrEnable => D_RF_WrEnable,
          D_RF_WrData_Selection => D_RF_WrData_Selection,
          D_RF_B_Selection => D_RF_B_Selection,
          D_ALU_Bin_Selection => D_ALU_Bin_Selection,
          D_ALU_Function => D_ALU_Function,
          D_ALU_Zero => D_ALU_Zero,
          D_Byte_Operation => D_Byte_Operation,
          D_MEM_WrEnable => D_MEM_WrEnable,
          D_MM_ReadData => D_MM_ReadData,
          D_MM_Addr => D_MM_Addr,
          D_MM_WrEn => D_MM_WrEn,
          D_MM_WrData => D_MM_WrData
        );

   -- Clock process definitions
   D_CLK_process :process
   begin
		D_CLK <= '0';
		wait for D_CLK_period/2;
		D_CLK <= '1';
		wait for D_CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for D_CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;

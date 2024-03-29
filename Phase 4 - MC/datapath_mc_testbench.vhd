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
         D_ALU_Op : IN  std_logic_vector(2 downto 0);
         D_ALU_Zero : OUT  std_logic;
         D_Byte_Operation : IN  std_logic;
         D_MEM_WrEnable : IN  std_logic;
         D_MM_ReadData : IN  std_logic_vector(31 downto 0);
         D_MM_Addr : OUT  std_logic_vector(31 downto 0);
         D_MM_WrEn : OUT  std_logic;
         D_MM_WrData : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    
	 COMPONENT RAM is
     port (
		  clk       : in std_logic;
        inst_addr : in std_logic_vector(10 downto 0); 
        inst_dout : out std_logic_vector(31 downto 0);
        data_we   : in std_logic;
        data_addr : in std_logic_vector(10 downto 0); 
        data_din  : in std_logic_vector(31 downto 0); 
        data_dout : out std_logic_vector(31 downto 0));
	 end COMPONENT;

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
   signal D_ALU_Op : std_logic_vector(2 downto 0) := (others => '0');
   signal D_Byte_Operation : std_logic := '0';
   signal D_MEM_WrEnable : std_logic := '0';
   signal D_MM_ReadData : std_logic_vector(31 downto 0) := (others => '0');

	signal clk : std_logic := '0';
	signal inst_addr : std_logic_vector(10 downto 0) := (others => '0');
	signal data_we : std_logic := '0';
	signal data_addr : std_logic_vector(10 downto 0) := (others => '0');
	signal data_din : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal D_PC : std_logic_vector(31 downto 0);
   signal D_ALU_Zero : std_logic;
   signal D_MM_Addr : std_logic_vector(31 downto 0);
   signal D_MM_WrEn : std_logic;
   signal D_MM_WrData : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant D_CLK_period : time := 100 ns;
 
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
          D_ALU_Op => D_ALU_Op,
          D_ALU_Zero => D_ALU_Zero,
          D_Byte_Operation => D_Byte_Operation,
          D_MEM_WrEnable => D_MEM_WrEnable,
          D_MM_ReadData => D_MM_ReadData,
          D_MM_Addr => D_MM_Addr,
          D_MM_WrEn => D_MM_WrEn,
          D_MM_WrData => D_MM_WrData
        );

	memory : RAM PORT MAP (
			 clk => D_CLK,
			 inst_addr => D_PC(12 downto 2),
			 inst_dout => D_Instr,
			 data_we   => D_MM_WrEn,
			 data_addr => D_MM_Addr(12 downto 2),
			 data_din  => D_MM_WrData,
			 data_dout => D_MM_ReadData
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
      D_Reset <= '1';
		wait for D_CLK_period*2;	
		
		-- addi
		--Instruction Fetch
		D_Reset <= '0';
		mem_reg_we <= '0';
		D_PC_LdEn <= '0';
		D_PC_Sel <= '0';
		instr_reg_we <= '1';
		alpha_we <= '0';	--Dont care
		beta_we <= '0';	--Dont care
		D_ALU_Op <= "000";
		D_MEM_WrEnable <= '0';
 		D_RF_WrEnable <= '0';
		wait for D_CLK_period;
		
		--Instruction Decode + Register Fetch
		D_ALU_Op <= "001";
		D_MEM_WrEnable <= '0';
		alpha_we <= '1';	
		beta_we <= '0';
		alu_reg_we <= '1';
		D_RF_B_Selection <= '0';
		wait for D_CLK_period;		
		
		--Execute instruction addi
		D_ALU_Bin_Selection <= '1';
		D_ALU_Op <= "001";
		alu_reg_we <= '1';
		wait for D_CLK_period;
		
		--Complete
		alu_reg_we <= '0';
		D_RF_WrData_Selection <= '0';
		D_RF_WrEnable <= '1';
		D_PC_LdEn <= '1';
		wait for D_CLK_period;		
		
		-- ori
		--Instruction Fetch
		D_Reset <= '0';
		mem_reg_we <= '0';
		D_PC_LdEn <= '0';
		D_PC_Sel <= '0';
		instr_reg_we <= '1';
		alpha_we <= '0';	--Dont care
		beta_we <= '0';	--Dont care
		D_ALU_Op <= "000";
		D_MEM_WrEnable <= '0';
 		D_RF_WrEnable <= '0';
		wait for D_CLK_period;
		
		--Instruction Decode + Register Fetch
		D_ALU_Op <= "010";
		D_MEM_WrEnable <= '0';
		alpha_we <= '1';	
		beta_we <= '0';
		alu_reg_we <= '1';
		D_RF_B_Selection <= '0';
		wait for D_CLK_period;		
		
		--Execute instruction ori
		D_ALU_Bin_Selection <= '1';
		alu_reg_we <= '1';
		wait for D_CLK_period;		
		
		--Complete
		alu_reg_we <= '0';
		D_RF_WrData_Selection <= '0';
		D_RF_WrEnable <= '1';
		D_PC_LdEn <= '1';
		wait for D_CLK_period;
		

		-- sw
		--Instruction Fetch	
		mem_reg_we <= '0';
		D_PC_LdEn <= '0';
		D_PC_Sel <= '0';
		instr_reg_we <= '1';
		alpha_we <= '0';	--Dont care
		beta_we <= '0';	--Dont care
		D_ALU_Op <= "001";
		D_MEM_WrEnable <= '0';
 		D_RF_WrEnable <= '0';
		wait for D_CLK_period;		
		
		--Instruction Decode + Register Fetch
		D_ALU_Op <= "001";
		D_MEM_WrEnable <= '0';
		alpha_we <= '1';	
		beta_we <= '1';
		alu_reg_we <= '1';
		D_RF_B_Selection <= '1';
		mem_reg_we <= '1';
		wait for D_CLK_period;		
		
		--Execute instruction sw
		D_ALU_Bin_Selection <= '1';
		alu_reg_we <= '1';
		wait for D_CLK_period;	
		
		--Complete
		alu_reg_we <= '0';
		D_RF_WrData_Selection <= '0';
		D_RF_WrEnable <= '0';
		D_PC_LdEn <= '1';
		D_MEM_WrEnable <= '1';
		wait for D_CLK_period;		
		
		
		-- lw
		--Instruction Fetch
		mem_reg_we <= '0';
		D_PC_LdEn <= '0';
		D_PC_Sel <= '0';
		instr_reg_we <= '1';
		alpha_we <= '0';	--Dont care
		beta_we <= '0';	--Dont care
		D_ALU_Op <= "001";
		D_MEM_WrEnable <= '0';
 		D_RF_WrEnable <= '0';
		wait for D_CLK_period;		
		
		--Instruction Decode + Register Fetch
		D_ALU_Op <= "001";
		D_MEM_WrEnable <= '0';
		alpha_we <= '1';	
		beta_we <= '0';
		alu_reg_we <= '1';
		D_RF_B_Selection <= '1';
		mem_reg_we <= '1';
		wait for D_CLK_period;		
		
		--Execute instruction lw
		D_ALU_Bin_Selection <= '1';
		wait for D_CLK_period;		
		
		
		--Mem
		wait for D_CLK_period;
		
		--Complete -> Load on RF
		alu_reg_we <= '1';
		D_RF_WrData_Selection <= '1';
		D_RF_WrEnable <= '1';
		D_PC_LdEn <= '1';
		D_MEM_WrEnable <= '0';
		wait for D_CLK_period;		
		
		D_Reset <= '1';
		D_PC_LdEn <= '0';
		wait for D_CLK_period*2;	
		wait;
   end process;

END;

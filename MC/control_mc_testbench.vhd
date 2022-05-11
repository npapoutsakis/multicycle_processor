--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:39:06 05/11/2022
-- Design Name:   
-- Module Name:   C:/Users/Nick-PC/Documents/VHDL/HRY302-Phase04v2/control_mc_testbench.vhd
-- Project Name:  HRY302-Phase04v2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CONTROL_MC
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
 
ENTITY control_mc_testbench IS
END control_mc_testbench;
 
ARCHITECTURE behavior OF control_mc_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CONTROL_MC
    PORT(
         C_Reset : IN  std_logic;
         C_Clk : IN  std_logic;
         Opcode : IN  std_logic_vector(5 downto 0);
         Zero : IN  std_logic;
         PC_Selection : OUT  std_logic;
         PC_LoadEnable : OUT  std_logic;
         RF_B_Selection : OUT  std_logic;
         RF_WriteEn : OUT  std_logic;
         RF_WriteData_Selection : OUT  std_logic;
         ALU_Bin_Selection : OUT  std_logic;
         ALU_Operation : OUT  std_logic_vector(2 downto 0);
         Byte_Operation : OUT  std_logic;
         MEM_Enable : OUT  std_logic;
         A_Enable : OUT  std_logic;
         B_Enable : OUT  std_logic;
         InstrReg_Enable : OUT std_logic;
         MemReg_Enable : OUT  std_logic;
         AluReg_Enable : OUT  std_logic
        );
    END COMPONENT;
   
	COMPONENT DATAPATH_MC is
    Port ( 
			  -- IFSTAGE
			  D_CLK : in  STD_LOGIC;                                          --General
           D_Reset : in  STD_LOGIC;														--General
           D_PC_Sel : in  STD_LOGIC;													--Comes from control
           D_PC_LdEn : in  STD_LOGIC;													--Comes from control
			  
			  D_PC : out  STD_LOGIC_VECTOR (31 downto 0);							--Goes to MEM for instr
           
			  --Update!! -> Signals for registers
			  alpha_we : in STD_LOGIC;
			  beta_we : in STD_LOGIC;
			  instr_reg_we : in STD_LOGIC;
			  mem_reg_we : in STD_LOGIC;
			  alu_reg_we : in STD_LOGIC;
							  	  
			  -- DECSTAGE
			  D_Instr : in  STD_LOGIC_VECTOR (31 downto 0);							--Takes from MEM (text segment)
           D_RF_WrEnable : in  STD_LOGIC;												--Comes from control -> RegWrite
           D_RF_WrData_Selection : in  STD_LOGIC;									--Comes from control -> ALU_OUT or MEM_OUT
           D_RF_B_Selection : in  STD_LOGIC;											--Comes from control -> RegDest
			  
			  -- EXSTAGE
           D_ALU_Bin_Selection : in  STD_LOGIC;										--Comes from control -> ALUScr
           D_ALU_Op : in  STD_LOGIC_VECTOR (2 downto 0);							--Comes from control -> ALUCtrl
			  D_ALU_Zero : out  STD_LOGIC;												--Will connect it with and AND gate and with pc_sel
			  
			  -- MEMSTAGE
           D_Byte_Operation : in  STD_LOGIC;											--Comes from control
           D_MEM_WrEnable : in  STD_LOGIC;											--Comes from control
           D_MM_ReadData : in  STD_LOGIC_VECTOR (31 downto 0);					--Will come from RAM
			  
			  D_MM_Addr : out STD_LOGIC_VECTOR (31 downto 0);						--Goes to RAM -> data_addr
			  D_MM_WrEn : out STD_LOGIC;												   --Goes to RAM -> data_we
			  D_MM_WrData : out STD_LOGIC_VECTOR (31 downto 0)						--Goes to RAM -> data_in
			  
			 );     
	
	end COMPONENT; 

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
   signal C_Reset : std_logic := '0';
   signal C_Clk : std_logic := '0';
   signal Opcode : std_logic_vector(5 downto 0) := (others => '0');
   signal Zero : std_logic := '0';
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

	signal inst_addr : std_logic_vector(10 downto 0) := (others => '0');
	signal data_we : std_logic := '0';
	signal data_addr : std_logic_vector(10 downto 0) := (others => '0');
	signal data_din : std_logic_vector(31 downto 0) := (others => '0');
 	
	--Outputs
   signal PC_Selection : std_logic;
   signal PC_LoadEnable : std_logic;
   signal RF_B_Selection : std_logic;
   signal RF_WriteEn : std_logic;
   signal RF_WriteData_Selection : std_logic;
   signal ALU_Bin_Selection : std_logic;
   signal Byte_Operation : std_logic;
   signal MEM_Enable : std_logic;
	
	signal ALU_Operation : std_logic_vector(2 downto 0);
   signal A_Enable : std_logic;
   signal B_Enable : std_logic;
   signal InstrReg_Enable : std_logic;
   signal MemReg_Enable : std_logic;
   signal AluReg_Enable : std_logic;

   signal D_PC : std_logic_vector(31 downto 0);
   signal D_ALU_Zero : std_logic;
   signal D_MM_Addr : std_logic_vector(31 downto 0);
   signal D_MM_WrEn : std_logic;
   signal D_MM_WrData : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 50 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CONTROL_MC PORT MAP (
          C_Reset => C_Reset,
          C_Clk => C_Clk,
          Opcode => D_Instr(31 downto 26),
          Zero => D_ALU_Zero,
          PC_Selection => PC_Selection,
          PC_LoadEnable => PC_LoadEnable,
          RF_B_Selection => RF_B_Selection,
          RF_WriteEn => RF_WriteEn,
          RF_WriteData_Selection => RF_WriteData_Selection,
          ALU_Bin_Selection => ALU_Bin_Selection,
          ALU_Operation => ALU_Operation,
          Byte_Operation => Byte_Operation,
          MEM_Enable => MEM_Enable,
          A_Enable => A_Enable,
          B_Enable => B_Enable,
          InstrReg_Enable => InstrReg_Enable,
          MemReg_Enable => MemReg_Enable,
          AluReg_Enable => AluReg_Enable
        );
   
	path: DATAPATH_MC PORT MAP (
          D_CLK => C_Clk,
          D_Reset => C_Reset,
          D_PC_Sel => PC_Selection,
          D_PC_LdEn => PC_LoadEnable,
          D_PC => D_PC,
          alpha_we => A_Enable,
          beta_we => B_Enable,
          instr_reg_we => InstrReg_Enable,
          mem_reg_we => MemReg_Enable,
          alu_reg_we => AluReg_Enable,
          D_Instr => D_Instr,
          D_RF_WrEnable => RF_WriteEn,
          D_RF_WrData_Selection => RF_WriteData_Selection,
          D_RF_B_Selection => RF_B_Selection,
          D_ALU_Bin_Selection => ALU_Bin_Selection,
          D_ALU_Op => ALU_Operation,
          D_ALU_Zero => D_ALU_Zero,
          D_Byte_Operation => Byte_Operation,
          D_MEM_WrEnable => MEM_Enable,
          D_MM_ReadData => D_MM_ReadData,
          D_MM_Addr => D_MM_Addr,
          D_MM_WrEn => D_MM_WrEn,
          D_MM_WrData => D_MM_WrData
        );
	
	memory : RAM PORT MAP (
			 clk => C_Clk,
			 inst_addr => D_PC(12 downto 2),
			 inst_dout => D_Instr,
			 data_we   => D_MM_WrEn,
			 data_addr => D_MM_Addr(12 downto 2),
			 data_din  => D_MM_WrData,
			 data_dout => D_MM_ReadData
		  );

   -- Clock process definitions
   Clk_process :process
   begin
		C_Clk <= '0';
		wait for Clk_period/2;
		C_Clk <= '1';
		wait for Clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		C_Reset <= '1';
		wait for Clk_period*3;	
		C_Reset <= '0';
		wait for Clk_period*30;
		
		C_Reset <= '1';
		wait for Clk_period*3;	
      -- insert stimulus here 

      wait;
   end process;

END;

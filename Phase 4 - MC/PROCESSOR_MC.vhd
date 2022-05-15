----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:57:48 05/10/2022 
-- Design Name: 
-- Module Name:    PROCESSOR_MC - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PROCESSOR_MC is
	Port ( CLK : in STD_LOGIC;
			 RESET : in STD_LOGIC );		

end PROCESSOR_MC;

architecture Behavioral of PROCESSOR_MC is

--Components that implement the multicycle processor 
-- CONTROL - DATAPATH - MEMORY

component CONTROL_MC is
	Port ( 
			 C_Reset : in STD_LOGIC;
			 C_Clk : in STD_LOGIC;	
				
			 Opcode : in STD_LOGIC_VECTOR(5 downto 0);					--Opcode of Instruction
			 Zero : in STD_LOGIC;												--ALU_Zero
			 
			 --Ifstage
			 PC_Selection : out STD_LOGIC;									--D_PC_sel
			 PC_LoadEnable : out STD_LOGIC;									--PC Register Enable
				
			 --Decstage
			 RF_B_Selection : out STD_LOGIC;									--RegDst
			 RF_WriteEn : out STD_LOGIC;										--RegWr
			 RF_WriteData_Selection : out STD_LOGIC;						--Mem/AluToReg
			 
			 --Exstage
			 ALU_Bin_Selection : out STD_LOGIC;								--ALU_Source
			 ALU_Operation : out  STD_LOGIC_VECTOR (2 downto 0);		--ALU_Control
			
			 --Memstage
          Byte_Operation : out  STD_LOGIC;								--word/byte
          MEM_Enable : out  STD_LOGIC;										--MEM_Read/MEM_Write
			
			 --Registers Enable
			 A_Enable : out STD_LOGIC;											--for register a
			 B_Enable : out STD_LOGIC;											--for register b
			 InstrReg_Enable : out STD_LOGIC;								--for instructrion reg
			 MemReg_Enable : out STD_LOGIC;									--for mem data register
			 AluReg_Enable : out STD_LOGIC			 						--for alu register		
			
			);
			
end component;

component DATAPATH_MC is
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
	
end component;

component RAM is
     port (
		  clk       : in std_logic;
        inst_addr : in std_logic_vector(10 downto 0); 
        inst_dout : out std_logic_vector(31 downto 0);
        data_we   : in std_logic;
        data_addr : in std_logic_vector(10 downto 0); 
        data_din  : in std_logic_vector(31 downto 0); 
        data_dout : out std_logic_vector(31 downto 0));
end component;

--Useful signal declared to establish connection between modules
signal instruction : std_logic_vector(31 downto 0);
signal address_of_instruction : std_logic_vector(31 downto 0);

signal alu_zero : std_logic;
signal pc_sel : std_logic;
signal pc_lden : std_logic;
signal rfb_sel : std_logic;
signal register_file_en : std_logic;
signal register_file_data_sel : std_logic;
signal alu_sel : std_logic;
signal alu_op : std_logic_vector(2 downto 0);
signal byte_op : std_logic;
signal alpha : std_logic;
signal beta : std_logic;
signal instrReg : std_logic;
signal memreg : std_logic;
signal alureg : std_logic;
signal memory_en : std_logic;

--Datapath + Memory Signals
signal mem_enable_signal : std_logic;
signal data_mem_address : std_logic_vector(31 downto 0);
signal data_in_mem : std_logic_vector(31 downto 0);
signal data_took_fromMem : std_logic_vector(31 downto 0);


begin

   control : CONTROL_MC PORT MAP (
          C_Reset => RESET,
          C_Clk => CLK,
          Opcode => instruction(31 downto 26),
          Zero => alu_zero,
          PC_Selection => pc_sel,
          PC_LoadEnable => pc_lden,
          RF_B_Selection => rfb_sel,
          RF_WriteEn => register_file_en,
          RF_WriteData_Selection => register_file_data_sel,
          ALU_Bin_Selection => alu_sel,
          ALU_Operation => alu_op,
          Byte_Operation => byte_op,
          MEM_Enable => memory_en,
          A_Enable => alpha,
          B_Enable => beta,
          InstrReg_Enable => instrReg,
          MemReg_Enable => memreg,
          AluReg_Enable => alureg
        );

	path : DATAPATH_MC PORT MAP (
          D_CLK => CLK,
          D_Reset => RESET,
          D_PC_Sel => pc_sel,
          D_PC_LdEn => pc_lden,
          D_PC => address_of_instruction,
          alpha_we => alpha,
          beta_we => beta,
          instr_reg_we => instrReg,
          mem_reg_we => memreg,
          alu_reg_we => alureg,
          D_Instr => instruction,
          D_RF_WrEnable => register_file_en,
          D_RF_WrData_Selection => register_file_data_sel,
          D_RF_B_Selection => rfb_sel,
          D_ALU_Bin_Selection => alu_sel,
          D_ALU_Op => alu_op,
          D_ALU_Zero => alu_zero,
          D_Byte_Operation => byte_op,
          D_MEM_WrEnable => memory_en,
          D_MM_ReadData => data_took_fromMem,
          D_MM_Addr => data_mem_address,
          D_MM_WrEn => mem_enable_signal,
          D_MM_WrData => data_in_mem
        );

	memory : RAM PORT MAP (
			 clk => CLK,
			 inst_addr => address_of_instruction(12 downto 2),
			 inst_dout => instruction,
			 data_we   => mem_enable_signal,
			 data_addr => data_mem_address(12 downto 2),
			 data_din  => data_in_mem,
			 data_dout => data_took_fromMem
		  );


end Behavioral;


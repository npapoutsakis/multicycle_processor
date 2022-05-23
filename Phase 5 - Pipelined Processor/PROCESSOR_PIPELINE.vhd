----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:22:53 05/20/2022 
-- Design Name: 
-- Module Name:    PROCESSOR_PIPELINE - Behavioral 
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

entity PROCESSOR_PIPELINE is
	 Port ( CLK : in STD_LOGIC;
			  RESET : in STD_LOGIC);
end PROCESSOR_PIPELINE;

architecture Behavioral of PROCESSOR_PIPELINE is

component DATAPATH_PIPELINE is
    Port ( 
			  -- IFSTAGE
			  D_CLK : in  STD_LOGIC;                                          --General
           D_Reset : in  STD_LOGIC;														--General
           D_PC_Sel : in  STD_LOGIC;													--Comes from control
--           D_PC_LdEn : in  STD_LOGIC;													--Comes from control
			  
			  D_PC : out  STD_LOGIC_VECTOR (31 downto 0);							--Goes to MEM for instr
           
			  --Update!! -> Signals for registers
--			  IF_ID_RegEnable : in STD_LOGIC;

			  IF_ID_Opcode : out STD_LOGIC_VECTOR (5 downto 0);
			  
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

component CONTROL_PIPELINE is
    Port ( PC_Selection : out  STD_LOGIC;								--PC_sel
--         PC_LoadEnable : out  STD_LOGIC;							--Register Enable
           Opcode : in  STD_LOGIC_VECTOR (5 downto 0);			--Opcode of Instruction
			  RF_B_Selection : out  STD_LOGIC;							--RegDst
           RF_WriteEn : out  STD_LOGIC;								--RegWr
           RF_WriteData_Selection : out  STD_LOGIC;				--MemToReg
           ALU_Op : out  STD_LOGIC_VECTOR (2 downto 0);			--ALU_Opcode
			  ALU_Bin : out  STD_LOGIC;									--ALU_Bin_Sel
           Zero : in  STD_LOGIC;											--ALU_Zero
           Byte_Op : out  STD_LOGIC;									--word/byte
           MEM_Enable : out  STD_LOGIC);
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
signal memory_en : std_logic;

--Datapath + Memory Signals
signal mem_enable_signal : std_logic;
signal data_mem_address : std_logic_vector(31 downto 0);
signal data_in_mem : std_logic_vector(31 downto 0);
signal data_took_fromMem : std_logic_vector(31 downto 0);

signal IF_Opcode : std_logic_vector(5 downto 0);

begin

   control : CONTROL_PIPELINE PORT MAP (
          Opcode => IF_Opcode,
          Zero => alu_zero,
          PC_Selection => pc_sel,
--          PC_LoadEnable => pc_lden,
          RF_B_Selection => rfb_sel,
          RF_WriteEn => register_file_en,
          RF_WriteData_Selection => register_file_data_sel,
          ALU_Bin => alu_sel,
          ALU_Op => alu_op,
          Byte_Op => byte_op,
          MEM_Enable => memory_en
        );

	path : DATAPATH_PIPELINE PORT MAP (
          D_CLK => CLK,
          D_Reset => RESET,
          D_PC_Sel => pc_sel,
--          D_PC_LdEn => pc_lden,
          D_PC => address_of_instruction,
--			 IF_ID_RegEnable => '1',
			 IF_ID_Opcode => IF_Opcode,
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


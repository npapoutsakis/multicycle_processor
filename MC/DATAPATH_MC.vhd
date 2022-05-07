----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:54:41 04/05/2022 
-- Design Name: 
-- Module Name:    DATAPATH - Behavioral 
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

entity DATAPATH is
    Port ( 
			  -- IFSTAGE
			  D_CLK : in  STD_LOGIC;                                          --General
           D_Reset : in  STD_LOGIC;														--General
           D_PC_Sel : in  STD_LOGIC;													--Comes from control
           D_PC_LdEn : in  STD_LOGIC;													--Comes from control
			  D_PC : out  STD_LOGIC_VECTOR (31 downto 0);							--Goes to MEM for instr
           
			  -- DECSTAGE
			  D_Instr : in  STD_LOGIC_VECTOR (31 downto 0);							--Takes from MEM (text segment)
           D_RF_WrEnable : in  STD_LOGIC;												--Comes from control -> RegWrite
           D_RF_WrData_Selection : in  STD_LOGIC;									--Comes from control -> ALU_OUT or MEM_OUT
           D_RF_B_Selection : in  STD_LOGIC;											--Comes from control -> RegDest
			  
			  -- EXSTAGE
           D_ALU_Bin_Selection : in  STD_LOGIC;										--Comes from control -> ALUScr
           D_ALU_Function : in  STD_LOGIC_VECTOR (3 downto 0);					--Comes from control -> ALUCtrl
			  D_ALU_Zero : out  STD_LOGIC;												--Will connect it with and AND gate and with pc_sel
			  
			  -- MEMSTAGE
           D_Byte_Operation : in  STD_LOGIC;											--Comes from control
           D_MEM_WrEnable : in  STD_LOGIC;											--Comes from control
           D_MM_ReadData : in  STD_LOGIC_VECTOR (31 downto 0);					--Will come from RAM
			  D_MM_Addr : out STD_LOGIC_VECTOR (31 downto 0);						--Goes to RAM -> data_addr
			  D_MM_WrEn : out STD_LOGIC;												   --Goes to RAM -> data_we
			  D_MM_WrData : out STD_LOGIC_VECTOR (31 downto 0)						--Goes to RAM -> data_in
			  
			 );     
	
end DATAPATH;

architecture Behavioral of DATAPATH is

component IFSTAGE is
    Port ( PC_Immed : in  STD_LOGIC_VECTOR (31 downto 0);
           PC_Sel : in  STD_LOGIC;
           PC_LdEn : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           PC : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component DECSTAGE is
    Port ( Instr : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_WrEn : in  STD_LOGIC;
           ALU_out : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_out : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_WrData_sel : in  STD_LOGIC;
           RF_B_sel : in  STD_LOGIC;
           RST : in STD_LOGIC;
			  Clk : in  STD_LOGIC;
           Immed : out  STD_LOGIC_VECTOR (31 downto 0);
           RF_A : out  STD_LOGIC_VECTOR (31 downto 0);
           RF_B : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component EXSTAGE is
    Port ( RF_A : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_B : in  STD_LOGIC_VECTOR (31 downto 0);
           Immed : in  STD_LOGIC_VECTOR (31 downto 0);
           ALU_Bin_sel : in  STD_LOGIC;
           ALU_func : in  STD_LOGIC_VECTOR (3 downto 0);
           ALU_out : out  STD_LOGIC_VECTOR (31 downto 0);
           ALU_zero : out  STD_LOGIC);
end component;

component MEMSTAGE is
    Port ( ByteOp : in  STD_LOGIC;
           Mem_WrEn : in  STD_LOGIC;
           ALU_MEM_Addr : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_DataIn : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_DataOut : out  STD_LOGIC_VECTOR (31 downto 0);
           MM_WrEn : out  STD_LOGIC;
           MM_Addr : out  STD_LOGIC_VECTOR (31 downto 0);
           MM_WrData : out  STD_LOGIC_VECTOR (31 downto 0);
           MM_RdData : in  STD_LOGIC_VECTOR (31 downto 0));
end component;

signal immed_signal : STD_LOGIC_VECTOR (31 downto 0);
signal alu_out_signal : STD_LOGIC_VECTOR (31 downto 0);
signal mem_dataOut_signal : STD_LOGIC_VECTOR (31 downto 0);
signal data_from_rfA : STD_LOGIC_VECTOR (31 downto 0);
signal data_from_rfB : STD_LOGIC_VECTOR (31 downto 0);

begin

	If_Stage : IFSTAGE
		port map ( PC_Immed => immed_signal,
					  PC_Sel => D_PC_Sel,
					  PC_LdEn => D_PC_LdEn,
					  Reset => D_Reset,
					  Clk => D_CLK,
					  PC => D_PC
					);


	Dec_Stage : DECSTAGE
		port map ( Instr => D_Instr,
					  RF_WrEn => D_RF_WrEnable,
					  ALU_out => alu_out_signal,
					  MEM_out => mem_dataOut_signal,
					  RF_WrData_sel => D_RF_WrData_Selection,
					  RF_B_sel => D_RF_B_Selection,
					  RST => D_Reset,
					  Clk => D_CLK,
					  Immed => immed_signal,
					  RF_A => data_from_rfA,
					  RF_B => data_from_rfB
			  );	


	Ex_Stage : EXSTAGE
		port map ( RF_A => data_from_rfA,
					  RF_B => data_from_rfB,
					  Immed => immed_signal,
					  ALU_Bin_sel => D_ALU_Bin_Selection,
					  ALU_func => D_ALU_Function,
					  ALU_out => alu_out_signal,
					  ALU_zero => D_ALU_Zero
					);


	Mem_Stage : MEMSTAGE
		port map ( ByteOp => D_Byte_Operation,
					  Mem_WrEn => D_MEM_WrEnable,
					  ALU_MEM_Addr => alu_out_signal,
					  MEM_DataIn => data_from_rfB,
					  MEM_DataOut => mem_dataOut_signal,
					  MM_WrEn => D_MM_WrEn,
					  MM_Addr => D_MM_Addr,
					  MM_WrData => D_MM_WrData,
					  MM_RdData => D_MM_ReadData
					);

end Behavioral;


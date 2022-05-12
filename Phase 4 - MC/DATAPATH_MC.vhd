----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:49:34 05/09/2022 
-- Design Name: 
-- Module Name:    DATAPATH_MC - Behavioral 
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

entity DATAPATH_MC is
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
	
end DATAPATH_MC;

architecture Behavioral of DATAPATH_MC is

--Datapath is the connection of all the stages we've created so far
--Component declaration: 

component Register32Bit is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           WE : in  STD_LOGIC;
           Datain : in  STD_LOGIC_VECTOR (31 downto 0);
           Dataout : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

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

component ALU_Control is
    Port ( instr_funct : in  STD_LOGIC_VECTOR (5 downto 0);
           op : in  STD_LOGIC_VECTOR (2 downto 0);
           alu_funct : out  STD_LOGIC_VECTOR (3 downto 0));
end component;

--Declaring usefull signals to connect components.
signal immed_signal : STD_LOGIC_VECTOR (31 downto 0);
signal alu_out_signal : STD_LOGIC_VECTOR (31 downto 0);
signal mem_dataOut_signal : STD_LOGIC_VECTOR (31 downto 0);

--Connect each output with a register
signal data_from_rfA : STD_LOGIC_VECTOR (31 downto 0);
signal data_from_rfB : STD_LOGIC_VECTOR (31 downto 0);

--Connect PC to register signal
signal to_reg : STD_LOGIC_VECTOR (31 downto 0);

--Connects the instruction from register to DECstage
signal instReg_to_decstage : STD_LOGIC_VECTOR (31 downto 0);

--Connects the output of the mem_register to the decstage -> MEM_OUT
signal mem_register_to_dec : STD_LOGIC_VECTOR (31 downto 0);

--Signals for A, B registers and their outputs
signal alpha_to_ex : STD_LOGIC_VECTOR (31 downto 0);
signal beta_to_ex : STD_LOGIC_VECTOR (31 downto 0);

--Signals declared to move from mux to the Exstage
signal to_exstage : STD_LOGIC_VECTOR (31 downto 0);

--Signal for output of the alu register
signal alu_register_out : STD_LOGIC_VECTOR (31 downto 0);

----Signal that give us the jump adress
--signal jump : STD_LOGIC_VECTOR (31 downto 0);
--
----Signal connecting last mux with the data in of the PC
--signal jump_mux_out : STD_LOGIC_VECTOR (31 downto 0);

--Signal for alu_ctrl - exstage connection
signal funct : STD_LOGIC_VECTOR (3 downto 0);

begin
	
	--After the update, IFSTAGE is the same as on the single cycle.
	If_Stage : IFSTAGE
		port map ( PC_Immed => immed_signal,
					  PC_Sel => D_PC_Sel,
					  PC_LdEn => D_PC_LdEn,
					  Reset => D_Reset,
					  Clk => D_CLK,
					  PC => D_PC
					);

	Instruction_Register : Register32Bit
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => instr_reg_we,
					  Datain => D_Instr,													--COMES THE INSTR FROM MEM
					  Dataout => instReg_to_decstage									--will connect to the input of dec_stage
					);	
	
	Memory_data_register : Register32Bit
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => mem_reg_we,
					  Datain => mem_dataOut_signal,									--COMES DATA FROM MEM
					  Dataout => mem_register_to_dec									--The MEM_OUT input
					);	
	
	Dec_Stage : DECSTAGE	
		port map ( Instr => instReg_to_decstage,									--Contains the Istruction
					  RF_WrEn => D_RF_WrEnable,	
					  ALU_out => alu_register_out,									--Took input from alu register									
					  MEM_out => mem_register_to_dec, 								--Output of the mem_reg connected
					  RF_WrData_sel => D_RF_WrData_Selection,
					  RF_B_sel => D_RF_B_Selection,
					  RST => D_Reset,
					  Clk => D_CLK,
					  Immed => immed_signal,
					  RF_A => data_from_rfA,
					  RF_B => data_from_rfB
			  );	

	alu_ctrl : ALU_Control
		port map ( instr_funct => instReg_to_decstage(5 downto 0),
					  op => D_ALU_Op,
					  alu_funct => funct
					);


	alpha_register : Register32Bit
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => alpha_we,
					  Datain => data_from_rfA,											--Comes from the decstage
					  Dataout => alpha_to_ex 									      --Goes to ExStage
					);	
	
	
	beta_register : Register32Bit
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => beta_we,
					  Datain => data_from_rfB,											--Comes from the decstag
					  Dataout => beta_to_ex								         	--Goes to the Ex-stage
					);
	
	
	Ex_Stage : EXSTAGE
		port map ( RF_A => alpha_to_ex,												--Inputs now are coming from the registers
					  RF_B => beta_to_ex,
					  Immed => immed_signal,
					  ALU_Bin_sel => D_ALU_Bin_Selection,
					  ALU_func => funct,
					  ALU_out => alu_out_signal,
					  ALU_zero => D_ALU_Zero
					);
	
	
	alu_out_register : Register32Bit
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => alu_reg_we,
					  Datain => alu_out_signal,										--Comes from the exstage
					  Dataout => alu_register_out								      
					);
	
	
	Mem_Stage : MEMSTAGE
		port map ( ByteOp => D_Byte_Operation,
					  Mem_WrEn => D_MEM_WrEnable,
					  ALU_MEM_Addr => alu_register_out,								--Register output taken
					  MEM_DataIn => beta_to_ex,										--Takes the data from beta register (Rd)
					  MEM_DataOut => mem_dataOut_signal,
					  MM_WrEn => D_MM_WrEn,
					  MM_Addr => D_MM_Addr,
					  MM_WrData => D_MM_WrData,
					  MM_RdData => D_MM_ReadData
					);

	--calculating the jump address
--	jump(31 downto 28)<= to_mux(31 downto 28);
--	jump(27 downto 0) <= std_logic_vector(shift_left(signed(instReg_to_decstage(25 downto 0)), 2)); 
--
--	branch_mux : Mux4to1
--		port map ( InputA => alu_out_signal,
--					  InputB => alu_register_out,
--					  InputC =>	jump,
--					  InputD => (others => '0'), 
--					  Sel => D_PCSource,
--					  mux_out => jump_mux_out	
--					);	

end Behavioral;


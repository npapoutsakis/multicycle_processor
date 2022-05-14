----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:20:27 05/13/2022 
-- Design Name: 
-- Module Name:    DATAPATH_PIPELINE - Behavioral 
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

entity DATAPATH_PIPELINE is
    Port ( 
			  -- IFSTAGE
			  D_CLK : in  STD_LOGIC;                                          --General
           D_Reset : in  STD_LOGIC;														--General
           D_PC_Sel : in  STD_LOGIC;													--Comes from control
           D_PC_LdEn : in  STD_LOGIC;													--Comes from control
			  
			  D_PC : out  STD_LOGIC_VECTOR (31 downto 0);							--Goes to MEM for instr
           
			  -- Update!! -> Signals for registers
--			  alpha_we : in STD_LOGIC;
--			  beta_we : in STD_LOGIC;
			  instr_reg_we : in STD_LOGIC;
--			  mem_reg_we : in STD_LOGIC;
--			  alu_reg_we : in STD_LOGIC;
							  	  
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

end DATAPATH_PIPELINE;


architecture Behavioral of DATAPATH_PIPELINE is

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
signal immed_signal : STD_LOGIC_VECTOR (31 downto 0);  --will come from decode
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

--gia to immed + pc + 4
signal immed_reg_out : STD_LOGIC_VECTOR (31 downto 0);

--For ID/EX -> Rd, Rs, Rt and Control Signals
signal rt_rd_rs_plus_signals : STD_LOGIC_VECTOR (31 downto 0);

--For ID/EX -> Rd, Rs, Rt and Control Signals
signal regs_and_control_signals_out : STD_LOGIC_VECTOR (31 downto 0);

--Signal for alu_ctrl - exstage connection
signal funct : STD_LOGIC_VECTOR (3 downto 0);

begin

	If_Stage : IFSTAGE
		port map ( PC_Immed => immed_reg_out,
					  PC_Sel => D_PC_Sel,
					  PC_LdEn => D_PC_LdEn,
					  Reset => D_Reset,
					  Clk => D_CLK,
					  PC => D_PC
					);
	
	
	--Same as the instruction register. In this project we execute only li, lw, sw and add instructions, so no branch.
	--Otherwise we should add PC+4 in the IF/ID register
	--IF/ID Register
	IF_ID : Register32Bit
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => instr_reg_we,												--WriteEnable will be controlled from HazardDetectionUnit
					  Datain => D_Instr,													--COMES THE INSTR FROM MEM
					  Dataout => instReg_to_decstage									--will connect to the input of dec_stage
					);	

	
	Dec_Stage : DECSTAGE	
		port map ( Instr => instReg_to_decstage,									--Contains the Instruction
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


	--ID/EX Register
	-------------------------------------------------------------------------------
	
	--All control signals
	rt_rd_rs_plus_signals(8 downto 0) <= D_RF_WrEnable & D_RF_B_Selection & D_RF_WrData_Selection & D_ALU_Bin_Selection & D_ALU_Op & D_Byte_Operation & D_MEM_WrEnable;
	
	--For Rs
	rt_rd_rs_plus_signals(23 downto 19) <= instReg_to_decstage(25 downto 21);
	
	--For Rd
	rt_rd_rs_plus_signals(18 downto 14) <= instReg_to_decstage(20 downto 16);
	
	--For Rt
	rt_rd_rs_plus_signals(13 downto 9) <= instReg_to_decstage(15 downto 11);
	
	alpha_register : Register32Bit
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => '1',
					  Datain => data_from_rfA,											--Comes from the decstage
					  Dataout => alpha_to_ex 									      --Goes to ExStage
					);
					
	beta_register : Register32Bit
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => '1',
					  Datain => data_from_rfB,											--Comes from the decstag
					  Dataout => beta_to_ex								         	--Goes to the Ex-stage
					);	
	
	immed_register : Register32Bit			
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => '1',
					  Datain => immed_signal,											--Comes from the decstag
					  Dataout => immed_reg_out								         --Goes to the Ex-stage and opcode goes to AlucControl
					);					
	
	regs_and_control_signals : Register32Bit			
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => '1',
					  Datain => rt_rd_rs_plus_signals,								--Comes from the decstage
					  Dataout => regs_and_control_signals_out  					--Goes to ExStage
					);			
					
	----------------------------------------------------------------------------------

	alu_ctrl : ALU_Control
		port map ( instr_funct => immed_reg_out(5 downto 0),
					  op => rt_rd_rs_plus_signals(4 downto 2),
					  alu_funct => funct
					);


	Ex_Stage : EXSTAGE
		port map ( RF_A => alpha_to_ex,												--Inputs now are coming from the registers
					  RF_B => beta_to_ex,
					  Immed => immed_reg_out,
					  ALU_Bin_sel => rt_rd_rs_plus_signals(5),					--Take it from register
					  ALU_func => funct,
					  ALU_out => alu_out_signal,
					  ALU_zero => D_ALU_Zero
					);
	





















end Behavioral;


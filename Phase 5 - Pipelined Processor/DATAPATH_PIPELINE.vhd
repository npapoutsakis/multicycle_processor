----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:08:55 05/18/2022 
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
--         D_PC_LdEn : in  STD_LOGIC;													--Comes from control
			  
			  D_PC : out  STD_LOGIC_VECTOR (31 downto 0);							--Goes to MEM for instr
           
			  --Update!! -> Signals for registers
--			  alpha_we : in STD_LOGIC;
--			  beta_we : in STD_LOGIC;
--			  IF_ID_RegEnable : in STD_LOGIC;
--			  mem_reg_we : in STD_LOGIC;
--			  alu_reg_we : in STD_LOGIC;
			  
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
			 
end DATAPATH_PIPELINE;

architecture Behavioral of DATAPATH_PIPELINE is

--Datapath is the connection of all the stages we've created so far
--Component declaration: 

component GenericRegister is
	 generic ( Size : Integer); --Size we want
	 Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           WE : in  STD_LOGIC;
           Datain : in  STD_LOGIC_VECTOR (Size - 1 downto 0);
           Dataout : out  STD_LOGIC_VECTOR (Size - 1 downto 0));
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
           RF_Address_Write : in  STD_LOGIC_VECTOR (4 downto 0);
			  RF_WrData_sel : in  STD_LOGIC;
           RF_B_sel : in  STD_LOGIC;
           FinalData : out STD_LOGIC_VECTOR (31 downto 0);
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

component ForwardingUnit is
	Port ( ID_EX_Rs :in STD_LOGIC_VECTOR(4 downto 0);
			 ID_EX_Rt :in STD_LOGIC_VECTOR(4 downto 0);
			 EX_MEM_Rd : in STD_LOGIC_VECTOR(4 downto 0);
			 MEM_WB_Rd : in STD_LOGIC_VECTOR(4 downto 0); 
			
		 	 EX_MEM_RF_WrEn : in STD_LOGIC;
			 MEM_WB_RF_WrEn : in STD_LOGIC;
			
			 FORWARD_A : out STD_LOGIC_VECTOR(1 downto 0);
			 FORWARD_B : out STD_LOGIC_VECTOR(1 downto 0)
		);
end component;

component MUX_4x1 is
    Port ( inputA : in  STD_LOGIC_VECTOR (31 downto 0);
           inputB : in 	STD_LOGIC_VECTOR (31 downto 0);
           inputC : in  STD_LOGIC_VECTOR (31 downto 0);
			  inputD : in 	STD_LOGIC_VECTOR (31 downto 0);
           Selector : in  STD_LOGIC_VECTOR (1 downto 0);
           MuxOut : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component SignalMux is
    Port ( inputA : in  STD_LOGIC_VECTOR (7 downto 0);
           chooser : in  STD_LOGIC;
			  control_signal_out : out  STD_LOGIC_VECTOR (7 downto 0)
			 );
end component;

component HazardDetectionUnit is
	Port ( IF_ID_Rs : in STD_LOGIC_VECTOR(4 downto 0);
			 IF_ID_Rt : in STD_LOGIC_VECTOR(4 downto 0);
			 ID_EX_RD : in STD_LOGIC_VECTOR(4 downto 0);
			 ID_EX_MemWrEn : in STD_LOGIC; 
			 ID_EX_Opcode : in STD_LOGIC_VECTOR(5 downto 0);
			 Control_Mux_Sel : out STD_LOGIC;
			 IF_ID_WrEn : out STD_LOGIC;
			 PC_LdEnable : out STD_LOGIC
			);
end component;


--Signal for alu_ctrl - exstage connection
signal funct : STD_LOGIC_VECTOR (3 downto 0);

--Declaring usefull signals to connect components.
signal immed_signal : STD_LOGIC_VECTOR (31 downto 0);
signal alu_out_signal : STD_LOGIC_VECTOR (31 downto 0);
signal mem_dataOut_signal : STD_LOGIC_VECTOR (31 downto 0);

--Connect each output with a register
signal data_from_rfA : STD_LOGIC_VECTOR (31 downto 0);
signal data_from_rfB : STD_LOGIC_VECTOR (31 downto 0);

signal if_id_instr : STD_LOGIC_VECTOR (31 downto 0);

signal if_id_en : STD_LOGIC;

--signal id_ex_input : STD_LOGIC_VECTOR (108 downto 0);
signal id_ex_output : STD_LOGIC_VECTOR (124 downto 0);

--signal ex_mem_input : STD_LOGIC_VECTOR (72 downto 0);
signal ex_mem_output : STD_LOGIC_VECTOR (72 downto 0);

--signal mem_wb_input : STD_LOGIC_VECTOR (70 downto 0);
signal mem_wb_output : STD_LOGIC_VECTOR (70 downto 0);


--Signals for selectors in 4x1 mux -> Forward
signal forward_alpha : STD_LOGIC_VECTOR (1 downto 0);
signal forward_beta : STD_LOGIC_VECTOR (1 downto 0);

signal mux_rfa_out : STD_LOGIC_VECTOR (31 downto 0);
signal mux_rfb_out : STD_LOGIC_VECTOR (31 downto 0);

--Comes from decstage
signal data_out : STD_LOGIC_VECTOR (31 downto 0);

signal control_mux_out : STD_LOGIC_VECTOR (7 downto 0);
signal control_mux_selector : STD_LOGIC;

signal pc_load_enable : STD_LOGIC;

begin

	If_Stage : IFSTAGE
		port map ( PC_Immed => id_ex_output(36 downto 5),
					  PC_Sel => D_PC_Sel,
					  PC_LdEn => pc_load_enable,
					  Reset => D_Reset,
					  Clk => D_CLK,
					  PC => D_PC
					);

	IF_ID_Register : GenericRegister
		generic map ( Size => 32 )
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => if_id_en,
					  Datain => D_Instr,
					  Dataout => if_id_instr
					);

	IF_ID_Opcode <= if_id_instr(31 downto 26);

	Dec_Stage : DECSTAGE
		port map ( Instr => if_id_instr,
					  RF_WrEn => mem_wb_output(70),
					  ALU_out => mem_wb_output(36 downto 5),
					  MEM_out => mem_wb_output(68 downto 37),
					  RF_Address_Write => mem_wb_output(4 downto 0), 		
					  RF_WrData_sel => mem_wb_output(69),						
					  RF_B_sel => D_RF_B_Selection,
					  FinalData => data_out,
					  RST => D_Reset,
					  Clk => D_CLK,
					  Immed => immed_signal,
					  RF_A => data_from_rfA,
					  RF_B => data_from_rfB
			  );	
	
	
	ControlMux : SignalMux
		port map ( InputA(7) => D_RF_WrEnable,
					  InputA(6) => D_RF_WrData_Selection,
					  InputA(5) => D_MEM_WrEnable,
					  InputA(4) => D_Byte_Operation,
					  InputA(3) => D_ALU_Bin_Selection,
					  InputA(2 downto 0) => D_ALU_Op,
					  chooser => control_mux_selector, 					
					  control_signal_out => control_mux_out
					);	
	
	
--	id_ex_input(108 downto 107) <= D_RF_WrEnable & D_RF_WrData_Selection; 	--wb signals
--	id_ex_input(106 downto 105) <= D_MEM_WrEnable & D_Byte_Operation;			--mem signals
--	id_ex_input(104 downto 101) <= D_ALU_Bin_Selection & D_ALU_Op;				--ex signals
--	id_ex_input(100 downto 69) <= data_from_rfA;										--RF_A
--	id_ex_input(68 downto 37) <= data_from_rfB;										--RF_B
--	id_ex_input(36 downto 5) <= immed_signal;											--Immed
--	id_ex_input(4 downto 0) <= if_id_instr(20 downto 16);							--Rd
	
	ID_EX_Register : GenericRegister
		generic map ( Size => 125)
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => '1',
					  Datain(124 downto 119) => if_id_instr(31 downto 26),					--Opcode
					  Datain(118 downto 114) => if_id_instr(25 downto 21),					--Rs
					  Datain(113 downto 109) => if_id_instr(15 downto 11),					--Rt
					  Datain(108) => control_mux_out(7),
					  Datain(107) => control_mux_out(6),
					  Datain(106) => control_mux_out(5),
					  Datain(105) => control_mux_out(4),
					  Datain(104) => control_mux_out(3),
					  Datain(103 downto 101) => control_mux_out(2 downto 0),
					  Datain(100 downto 69) => data_from_rfA,
					  Datain(68 downto 37) => data_from_rfB,
					  Datain(36 downto 5) => immed_signal,
					  Datain(4 downto 0) => if_id_instr(20 downto 16),		--Rd
					  Dataout => id_ex_output
					);	
	
	Ex_Stage : EXSTAGE
		port map ( RF_A => mux_rfa_out,
					  RF_B => mux_rfb_out,
					  Immed => id_ex_output(36 downto 5),
					  ALU_Bin_sel => id_ex_output(104),
					  ALU_func => funct,
					  ALU_out => alu_out_signal,
					  ALU_zero => D_ALU_Zero
					);

	alu_ctrl : ALU_Control
		port map ( instr_funct => id_ex_output(10 downto 5),						
					  op => id_ex_output(103 downto 101),
					  alu_funct => funct
					);

	Forward : ForwardingUnit
		port map ( ID_EX_Rs => id_ex_output(118 downto 114),
					  ID_EX_Rt => id_ex_output(113 downto 109),
			        EX_MEM_Rd => ex_mem_output(4 downto 0),
			        MEM_WB_Rd => mem_wb_output(4 downto 0),			
					  EX_MEM_RF_WrEn => ex_mem_output(72),
					  MEM_WB_RF_WrEn => mem_wb_output(70),
					  
					  FORWARD_A => forward_alpha,
					  FORWARD_B =>	forward_beta
					);
	
	Stall : HazardDetectionUnit
		port map ( IF_ID_Rs => if_id_instr(25 downto 21),
					  IF_ID_Rt => if_id_instr(15 downto 11),
					  ID_EX_RD => id_ex_output(4 downto 0), 			--Rd
					  ID_EX_MemWrEn => id_ex_output(106),
					  ID_EX_Opcode => id_ex_output(124 downto 119),
					  Control_Mux_Sel => control_mux_selector,
					  IF_ID_WrEn => if_id_en,
					  PC_LdEnable => pc_load_enable
					);
	

	muxRFA : MUX_4x1
		port map ( InputA => id_ex_output(100 downto 69),
					  InputB => data_out,
					  InputC => ex_mem_output(68 downto 37),
					  InputD => (others => '0'),
					  Selector => forward_alpha,
					  MuxOut => mux_rfa_out
					);
	
	muxRFB : MUX_4x1
		port map ( InputA => id_ex_output(68 downto 37),
					  InputB => data_out,
					  InputC => ex_mem_output(68 downto 37),
					  InputD => (others => '0'),
					  Selector => forward_beta,
					  MuxOut => mux_rfb_out		
					);

--	ex_mem_input(72 downto 71) <= id_ex_output(108 downto 107);					--Transfer wb signals
--	ex_mem_input(70 downto 69) <= id_ex_output(106 downto 105);					--Transfer mem signals
--	ex_mem_input(68 downto 37) <= alu_out_signal;									--Alu_Out
--	ex_mem_input(36 downto 5) <= id_ex_output(68 downto 37);						--RF_B
--	ex_mem_input(4 downto 0) <= id_ex_output(4 downto 0);							--Transfer Rd

	EX_MEM_Register : GenericRegister
		generic map ( Size => 73)
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => '1',
					  Datain(72) => id_ex_output(108),
					  Datain(71) => id_ex_output(107),
					  Datain(70) => id_ex_output(106),
					  Datain(69) => id_ex_output(105),
					  Datain(68 downto 37) => alu_out_signal,
					  Datain(36 downto 5) => mux_rfb_out,
					  Datain(4 downto 0) => id_ex_output(4 downto 0),
					  Dataout => ex_mem_output
					);		


	Mem_Stage : MEMSTAGE
		port map ( ByteOp => ex_mem_output(69),
					  Mem_WrEn => ex_mem_output(70),
					  ALU_MEM_Addr => ex_mem_output(68 downto 37),
					  MEM_DataIn => ex_mem_output(36 downto 5),
					  MEM_DataOut => mem_dataOut_signal,
					  MM_WrEn => D_MM_WrEn,
					  MM_Addr => D_MM_Addr,
					  MM_WrData => D_MM_WrData,
					  MM_RdData => D_MM_ReadData
					);
	
	
--	mem_wb_input(70 downto 69) <= ex_mem_output(72 downto 71);					--Transfer wb signals
--	mem_wb_input(68 downto 37) <= mem_dataOut_signal;								--MEM_OUT
--	mem_wb_input(36 downto 5) <= ex_mem_output(68 downto 37);					--ALU_OUT
--	mem_wb_input(4 downto 0) <= ex_mem_output(4 downto 0);						--Transfer Rd
		
	MEM_WB_Register : GenericRegister
		generic map ( Size => 71)
		port map ( CLK => D_CLK,
					  RST => D_Reset,
					  WE => '1',
					  Datain(70) => ex_mem_output(72),
					  Datain(69) => ex_mem_output(71),
					  Datain(68 downto 37) => mem_dataOut_signal,
					  Datain(36 downto 5) => ex_mem_output(68 downto 37),
					  Datain(4 downto 0) => ex_mem_output(4 downto 0),  
					  Dataout => mem_wb_output
					);	

end Behavioral;


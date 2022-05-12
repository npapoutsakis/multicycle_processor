----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:08:29 05/10/2022 
-- Design Name: 
-- Module Name:    CONTROL_MC - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CONTROL_MC is
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
			
end CONTROL_MC;

architecture Behavioral of CONTROL_MC is

--Declaring the states of execution
type state is (reset, fetch, decode, execute, memory, wb);

--Declaring 2 state variables
signal current_state, next_state : state;

begin
	--Our fsm is a mealy fms -> depends on the previous state and the opcode input
	Control_FSM : process(C_Reset, C_Clk, current_state, Opcode, Zero)
	begin
		
		--Check if Reset is enabled, then set the next state as the reset state
		if C_Reset = '1' then
			next_state <= reset;
		elsif rising_edge(C_Clk) then
			current_state <= next_state;
		end if;
		
		---README!!!
		--	Note that, in every state we change the control signals of the datapath unit. The changes are made AFTER the clock!
		--	So in each state we set the control signals that we want to take place in the next cycle!
		case current_state is
				--In reset state just disable all signals
				when reset =>
							PC_Selection <= '0';
							PC_LoadEnable <= '0';
							
							RF_B_Selection <= '0';
							RF_WriteEn <= '0';
							RF_WriteData_Selection <= '0';
							
							ALU_Bin_Selection <= '0';
							ALU_Operation <= "111";
							
							Byte_Operation <= '0';
							MEM_Enable <= '0';
							
							A_Enable <= '0';
							B_Enable <= '0';
							InstrReg_Enable <= '0';
							MemReg_Enable <= '0';
							AluReg_Enable <= '0';	
							
							--Everytime reset is down, the next state should be the fetch.
							next_state <= fetch;
				
				--In this state, the instruction is fetched
				when fetch =>							
							--After hours of debugging, realized that we have to set to 0 the below signals
							--This change help us keep our data in the registers until the next state
							
							PC_Selection <= '0';				-- PC + 4
							PC_LoadEnable <= '0';			-- Dont write, wait for the instruction to finish
							RF_B_Selection <= '0';			-- Set to zero, avoid problem choosing the wrong input after a branch or store instruction
							RF_WriteEn <= '0';				-- Reset
							MEM_Enable <= '0';				-- Reset					
							
							InstrReg_Enable <= '1';			-- ENABLED -> Instruction will be saved in the next cycle 
							
							--At the rising edge of the clock, the above signals will take place.
							--So the pc register will not change its value until the instruction is finished.
								
							--Move to decode state to decode the type of instruction
							next_state <= decode;
				
				--In this state, the instruction is decoded				
				when decode =>
							--	li, lui, addi, nandi, ori						
							if Opcode = "111000" or Opcode = "111001" or Opcode = "110000" or Opcode = "110010" or Opcode = "110011" then
								A_Enable <= '1';		--Enabled, we need its value
								B_Enable <= '0';		--Dont care, Immed will be taken
								
								--Then execute
								next_state <= execute;
							
							-- R-type instructions
							elsif Opcode = "100000" then					
								--Both regs are needed
								A_Enable <= '1';
								B_Enable <= '1';
								
								next_state <= execute;
							
							-- b, bne, beq
							elsif Opcode = "111111" or Opcode = "000000" or Opcode = "000001" then
								--Need them to check 
								A_Enable <= '1';
								B_Enable <= '1';
								
								--Select the rd register
								RF_B_Selection <= '1';
		
								next_state <= execute;						
							
							--sw, sb
							elsif Opcode = "000111" or Opcode = "011111" then
								--Select the rd register
								RF_B_Selection <= '1';
								
								--Enable register to store the outpout of Rs and Rd of the instruction
								A_Enable <= '1';
								B_Enable <= '1';
								
								next_state <= execute;
							
							--lw, lb
							elsif Opcode = "000011" or Opcode = "001111" then
								A_Enable <= '1';
								B_Enable <= '1';

								next_state <= execute;
							end if;
				
				--In this state the execution is made
				when execute => 
							
							--Check for all i-type instructions
							if Opcode = "111000" or Opcode = "111001" or Opcode = "110000" or Opcode = "110010" or Opcode = "110011" then
								ALU_Bin_Selection <= '1';	--Immed choosen
								AluReg_Enable <= '1';		--Enabled, we need to store the result of ALU.
								
								--li, lui, addi -> need addition
								if Opcode = "111000" or Opcode = "111001" or Opcode = "110000" then 
									ALU_Operation <= "001";
								
								--nandi -> need nand
								elsif Opcode = "110010" then 
									ALU_Operation <= "011";
								
								--ori -> need or
								elsif Opcode = "110011" then
									ALU_Operation <= "010";
								
								end if;
								
								--Next state write_back -> used to finally write data on register file after instructions
								next_state <= wb;							
							
							
							--R-type
							 elsif Opcode = "100000" then 
								ALU_Bin_Selection <= '0';	--rf_b selected
								ALU_Operation <= "000";		--r funct
								AluReg_Enable <= '1';		--Store the output in alu register so that in the next state we have our data
								
								next_state <= wb;
							
							
							--Branch Instructions, b, beq, bne
							 elsif Opcode = "111111" or Opcode = "000000" or Opcode = "000001" then
								--No need to write the result, just compute and check if it is zero.
								AluReg_Enable <= '0';
								
								ALU_Bin_Selection <= '0';		--rf_b selected to compute the subtraction
								ALU_Operation <= "100";			--Subtraction
								
								--Why enabling pc_lden? -> In the next positive edge the result of alu will have been written and the pc will have taken the new address
								PC_LoadEnable <= '1';
								
								--Checking beq, true or false and choose the next address
								if Opcode = "000000" and Zero = '1' then
									PC_Selection <= '1';								--PC + 4 + SignExt(Immed)<<2
								else 
									PC_Selection <= '0';								--PC + 4
								end if;
								
								--Checking bne, true or false and choose the next address
								if Opcode = "000001" and Zero = '1' then
									PC_Selection <= '0';								--PC + 4
								else 
									PC_Selection <= '1';								--PC + 4 + SignExt(Immed)<<2
								end if;
								
								--b -> just jump
								if Opcode = "111111" then
									PC_Selection <= '1';								--PC + 4 + SignExt(Immed)<<2
								end if;
								
								--Done, now time to fetch the next instruction
								next_state <= fetch;						
							 
							 
							 --sw, sb
							 elsif Opcode = "000111" or Opcode = "011111" then
								ALU_Bin_Selection <= '1';			--Immed -> to calculate address
								ALU_Operation <= "001";				--Addition
								AluReg_Enable <= '1';				--Store the output -> address of mem
								
								next_state <= memory;	
							
					
							--lw, lb
							elsif Opcode = "000011" or Opcode = "001111" then 
								ALU_Bin_Selection <= '1';			--Immed -> to calculate address
								ALU_Operation <= "001";				--Addition
								AluReg_Enable <= '1';				--Store the output -> address of mem
								MemReg_Enable <= '1';				--Store the mem_data in the register -> Destination: Register File
								
								next_state <= memory;
							end if;
							
				--This state is for lw, lb, sw and sb. Here we access the memory
				when memory =>
							--For store instructions
							if Opcode = "000111" or Opcode = "011111" then
								
								MEM_Enable <= '1';				--Enable to write
								PC_LoadEnable <= '1';			--Calculate next address for next instruction -> PC + 4 
								
								if Opcode = "000111" then
									Byte_Operation <= '1';		--Store a byte
								else	
									Byte_Operation <= '0';		--Store a word
								end if;
								
								--Access done! move on
								next_state <= fetch;
							
							--For load instructions 
							else	
								if Opcode = "000011" then 
									Byte_Operation <= '1';		--Load a byte
								else
									Byte_Operation <= '0';		--Load a word
								end if;
								
								--go to wb, write data in RF
								next_state <= wb;
							
							end if;
						
				when wb => 
							--Enable RF -> in the next positive edge the results are written in RF
							--Enable PC -> in the next positive edge the new instruction is fetched (PC + 4 or PC + 4 + SignExt(Immed)<<2)
								RF_WriteEn <= '1';
								PC_LoadEnable <= '1';							
							
							--I-type and R-type
							if Opcode = "111000" or Opcode = "111001" or Opcode = "110000" or Opcode = "110010" or Opcode = "110011" or Opcode = "100000" then
								--ALU_Out is taken as input
								RF_WriteData_Selection <= '0';

								next_state <= fetch;
							
							--In case of lw/lb
							elsif Opcode = "000011" or Opcode = "001111" then
								--MEM_Out is taken as input (data from mem)
								RF_WriteData_Selection <= '1';
								
								next_state <= fetch;
							end if;					
				
			end case;

	end process;

end Behavioral;


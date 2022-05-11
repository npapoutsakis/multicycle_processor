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
			 PC_Selection : out STD_LOGIC;									--nPC_sel
			 PC_LoadEnable : out STD_LOGIC;									--PC Register Enable
				
			 --Decstage
			 RF_B_Selection : out STD_LOGIC;									--RegDst
			 RF_WriteEn : out STD_LOGIC;										--RegWr
			 RF_WriteData_Selection : out STD_LOGIC;						--MemToReg
			 
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

signal current_state, next_state : state;

begin
	
	Control_FSM : process(C_Reset, C_Clk, current_state, Opcode, Zero)
	begin
		
		if C_Reset = '1' then
			current_state <= reset;
		elsif rising_edge(C_Clk) then
			current_state <= next_state;
		end if;
	
		case current_state is
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
							
						
							next_state <= fetch;
						
				when fetch =>							
							PC_Selection <= '0';				-- PC + 4
							PC_LoadEnable <= '0';			-- Dont write, wait for the instruction to finish
							
							InstrReg_Enable <= '1';
							
							next_state <= decode;
							
				when decode =>
							RF_B_Selection <= '0';
							RF_WriteEn <= '0';
							MEM_Enable <= '0';
							
							if Opcode = "111000" or Opcode = "111001" or Opcode = "110000" or Opcode = "110010" or Opcode = "110011" then
								A_Enable <= '1';
								B_Enable <= '0';
								AluReg_Enable <= '1';
								
								next_state <= execute;
							
							elsif Opcode = "100000" then
								A_Enable <= '1';
								B_Enable <= '1';
								AluReg_Enable <= '1';							
								
								next_state <= execute;
							
							elsif Opcode = "111111" or Opcode = "000000" or Opcode = "000001" then
								A_Enable <= '1';
								B_Enable <= '1';
								AluReg_Enable <= '0';							
								RF_B_Selection <= '1';
								next_state <= execute;						
							
							elsif Opcode = "000111" or Opcode = "011111" then
								RF_B_Selection <= '1';
								MemReg_Enable <= '1';
								A_Enable <= '1';
								B_Enable <= '1';
								AluReg_Enable <= '1';
								next_state <= execute;
							
							elsif Opcode = "000011" or Opcode = "001111" then 
								MemReg_Enable <= '1';
								A_Enable <= '1';
								B_Enable <= '1';
								AluReg_Enable <= '1';
								next_state <= execute;
							end if;
					
				when execute => 
							if Opcode = "111000" or Opcode = "111001" or Opcode = "110000" or Opcode = "110010" or Opcode = "110011" then
								ALU_Bin_Selection <= '1';
								
								if Opcode = "111000" or Opcode = "111001" or Opcode = "110000" then 
									ALU_Operation <= "001";
								
								elsif Opcode = "110010" then 
									ALU_Operation <= "011";
								
								elsif Opcode = "110011" then
									ALU_Operation <= "010";
								
								end if;
								
								next_state <= wb;							
							
							 elsif Opcode = "100000" then 
								ALU_Bin_Selection <= '0';
								ALU_Operation <= "000";
								next_state <= wb;
							
							 elsif Opcode = "111111" or Opcode = "000000" or Opcode = "000001" then
								ALU_Bin_Selection <= '1';
								ALU_Operation <= "100";
								PC_LoadEnable <= '1';
								
								if Opcode = "000000" and Zero = '1' then
									PC_Selection <= '1';
								else 
									PC_Selection <= '0';
								end if;
								
								if Opcode = "000001" and Zero = '1' then
									PC_Selection <= '0';
								else 
									PC_Selection <= '1';
								end if;
								
								if Opcode = "111111" then
									PC_Selection <= '1';
								end if;
								
								next_state <= fetch;						
							 
							 elsif Opcode = "000111" or Opcode = "011111" then
								ALU_Bin_Selection <= '1';
								ALU_Operation <= "001";

								next_state <= memory;	
							 
							elsif Opcode = "000011" or Opcode = "001111" then 
								ALU_Bin_Selection <= '1';
								ALU_Operation <= "001";

								next_state <= memory;
							end if;
							
	
				when memory =>
							if Opcode = "000111" or Opcode = "011111" then
							
								MEM_Enable <= '1';
								PC_LoadEnable <= '1';
								
								if Opcode = "000111" then
									Byte_Operation <= '1';
								else
									Byte_Operation <= '0';
								end if;
								
								next_state <= fetch;
							
							else
								
								if Opcode = "000011" then 
									Byte_Operation <= '1';
								else
									Byte_Operation <= '0';
								end if;
								
								next_state <= wb;
							
							end if;
						
				when wb => 
							if Opcode = "111000" or Opcode = "111001" or Opcode = "110000" or Opcode = "110010" or Opcode = "110011" or Opcode = "100000" then
								RF_WriteData_Selection <= '0';
								RF_WriteEn <= '1';
								PC_LoadEnable <= '1';
								
								next_state <= fetch;
							
							elsif Opcode = "000011" or Opcode = "001111" then
								RF_WriteData_Selection <= '1';
								RF_WriteEn <= '1';
								PC_LoadEnable <= '1';
								
								next_state <= fetch;
							end if;					
				
			end case;

	end process;

end Behavioral;


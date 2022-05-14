----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:59:34 05/14/2022 
-- Design Name: 
-- Module Name:    CONTROL_PIPELINE - Behavioral 
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

entity CONTROL_PIPELINE is
    Port ( PC_Selection : out  STD_LOGIC;								--nPC_sel
           PC_LoadEnable : out  STD_LOGIC;							--Register Enable
           Opcode : in  STD_LOGIC_VECTOR (5 downto 0);			--Opcode of Instruction									--Input
			  RF_B_Selection : out  STD_LOGIC;							--RegDst														--WB
           RF_WriteEn : out  STD_LOGIC;								--RegWr														--WB
           RF_WriteData_Selection : out  STD_LOGIC;				--MemToReg													--WB
           ALU_Control : out  STD_LOGIC_VECTOR (3 downto 0);	--ALU_Opcode												--EX
			  ALU_Source : out  STD_LOGIC;								--ALUSrc --> ALU_Bin_Sel								--EX
			  Rtype_Funct : in  STD_LOGIC_VECTOR (5 downto 0);		--Funct														
           Zero : in  STD_LOGIC;											--ALU_Zero													
           Byte_Op : out  STD_LOGIC;									--word/byte													--MEM
           MEM_Enable : out  STD_LOGIC);								--MemWr														--MEM
end CONTROL_PIPELINE;

architecture Behavioral of CONTROL_PIPELINE is

begin
	CHARIS_Implementation : process (Opcode, Rtype_Funct, Zero) 
		begin
			--R-TYPE
			if Opcode = "100000"	then  									
				PC_LoadEnable <= '1'; 										--Enabled!
					
				PC_Selection <= '0';  										--nPC_sel = PC + 4
				RF_WriteEn <= '1';											--RegWr Enabled
				RF_WriteData_Selection <= '0';							--MemToReg is ALU_Out
				RF_B_Selection <= '0';										--RegDst is 0 , so to select the Rt(15 downto 11)
				ALU_Control <= Rtype_Funct(3 downto 0);				--ALUctr is funct(3 donwto 0)
				ALU_Source <= '0';											--ALU_Source or ALU_Bin_Sel is 0 -> RF_B
				Byte_Op <= '0'; 												--Dont care in Rtype instructions
				MEM_Enable <= '0';											--Dont care in Rtype instructions
			
			--I-TYPE
			elsif Opcode = "111000"	or Opcode = "111001" or Opcode = "110000" or Opcode = "110010" or Opcode = "110011" then 					
				PC_LoadEnable <= '1'; 										--Enabled!
				
				PC_Selection <= '0';  										--nPC_sel = PC + 4
				RF_WriteEn <= '1';											--RegWr Enabled
				RF_WriteData_Selection <= '0';							--MemToReg is ALU_Out
				RF_B_Selection <= '1';										--RegDst is 1 , so to select the Rd(20 downto 16)
				ALU_Source <= '1';											--ALU_Source or ALU_Bin_Sel is 1 -> Immed
				Byte_Op <= '0'; 												--Dont care in Itype instructions
				MEM_Enable <= '0';											--Dont care in Itype instructions	
				
				if Opcode = "111000"	or Opcode = "111001" or Opcode = "110000" then	-- li, lui, addi				
					ALU_Control <= "0000"; 									-- We need ALU to make an addition in order to implement the istructions
				
				elsif Opcode = "110010" then														-- nandi
					ALU_Control <= "0101"; 									-- We need ALU to make a nand operation in order to implement nandi
				
				elsif Opcode = "110011" then														-- ori
					ALU_Control <= "0011"; 									-- We need ALU to make an or operation in order to implement ori
				
				end if;
			
			--I-TYPE, Branch Instructions
			elsif Opcode = "111111"	or Opcode = "000000" or Opcode = "000001" then  -- b, bne, beq
				PC_LoadEnable <= '1'; 										--Enabled!
			
				RF_WriteEn <= '0';											--RegWr Disabled
				RF_WriteData_Selection <= '0';							--MemToReg is ALU_Out, but DONT CARE
				RF_B_Selection <= '1';										--RegDst is DONT CARE
				Byte_Op <= '0'; 												--Dont care in Itype instructions
				MEM_Enable <= '0';											--Dont care in Itype instructions
				ALU_Source <= '0';											--ALU_Source or ALU_Bin_Sel is 0 -> RF_B so that ALU makes the operation
				
				if Opcode = "111111" then			-- b											
					PC_Selection <= '1';  									--nPC_sel = PC + 4 + SignExt(Immed)<<2

					ALU_Control <= Rtype_Funct(3 downto 0);			--ALUctr is DONTCARE
				
				elsif Opcode = "000000" then		-- beq
					ALU_Control <= "0001";									--We need ALU to make an subtraction in order to implement the istruction	
				
					if Zero = '1' then
						PC_Selection <= '1';  								--nPC_sel = PC + 4 + SignExt(Immed)<<2
					else
						PC_Selection <= '0';  								--nPC_sel = PC + 4
					end if;
				
				elsif Opcode = "000001" then		-- bne
					ALU_Control <= "0001";									--We need ALU to make an subtraction in order to implement the istruction	
				
					if Zero = '1' then
						PC_Selection <= '0';  								--nPC_sel = PC + 4 
					else
						PC_Selection <= '1';  								--nPC_sel = PC + 4 + SignExt(Immed)<<2
					end if;				
				
				end if;
			
			--Load Byte/Load Word Instructions
			elsif Opcode = "000011"	or Opcode = "001111" then								-- lb, lw
				PC_LoadEnable <= '1'; 										--Enabled!
					
				PC_Selection <= '0';  										--nPC_sel = PC + 4
				RF_WriteEn <= '1';											--RegWr Enabled
				RF_WriteData_Selection <= '1';							--MemToReg is Mem_Out
				RF_B_Selection <= '1';										--RegDst is 1 , so to select the Rt(15 downto 11)
				ALU_Control <= "0000";										--ALUctr is add	
				ALU_Source <= '1';											--ALU_Source or ALU_Bin_Sel is 1 -> Immed
				MEM_Enable <= '0';											--0, we dont use mem in load				
			
				if Opcode = "000011" then
					Byte_Op <= '1'; 											--Load A Byte
				else
					Byte_Op <= '0'; 											--Load A Word	
				end if;
			
			--Store Byte/Store Word Instructions
			elsif Opcode = "000111"	or Opcode = "011111" then								-- sb, sw
				PC_LoadEnable <= '1'; 										--Enabled!
					
				PC_Selection <= '0';  										--nPC_sel = PC + 4
				RF_WriteEn <= '0';											--RegWr Disabled
				RF_WriteData_Selection <= '1';							--MemToReg is but dont care
				RF_B_Selection <= '1';										--RegDst is 1 , but dont care
				ALU_Control <= "0000";										--ALUctr is add	
				ALU_Source <= '1';											--ALU_Source or ALU_Bin_Sel is 1 -> Immed
				MEM_Enable <= '1';											--1, we need to store the value			
			
				if Opcode = "000111" then
					Byte_Op <= '1'; 											--Store A Byte
				else
					Byte_Op <= '0'; 											--Store A Word	
				end if;			
			
			end if;

	end process;

end Behavioral;


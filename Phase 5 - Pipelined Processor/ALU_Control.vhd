----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:49:35 05/10/2022 
-- Design Name: 
-- Module Name:    ALU_Control - Behavioral 
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

entity ALU_Control is
    Port ( instr_funct : in  STD_LOGIC_VECTOR (5 downto 0);
           op : in  STD_LOGIC_VECTOR (2 downto 0);
           alu_funct : out  STD_LOGIC_VECTOR (3 downto 0));
end ALU_Control;

architecture Behavioral of ALU_Control is

begin

	ALU_Func_Sel : process(instr_funct, op)
	begin
	
		--R-type so get the instr_funct
		if op = "000" then
			alu_funct <= instr_funct(3 downto 0);
		end if;
		
		-- li, lui, addi, lb, lw, sb, sw
		if op = "001" then
			alu_funct <= "0000";		--add
		end if;	
		
		--ori 
		if op = "010" then 
			alu_funct <= "0011";		--or
		end if;
		
		--nandi 
		if op = "011" then 
			alu_funct <= "0101";		--nand
		end if;
		
		--beq, bne 
		if op = "100" then 
			alu_funct <= "0001";		--sub
		end if;
	
	end process;

end Behavioral;


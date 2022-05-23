----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:16:44 03/31/2022 
-- Design Name: 
-- Module Name:    cloud - Behavioral 
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

entity cloud is
    Port ( Instr15to0 : in  STD_LOGIC_VECTOR (15 downto 0);
           ImExt : in  STD_LOGIC_VECTOR (1 downto 0);
           CloudResult : out  STD_LOGIC_VECTOR (31 downto 0));
end cloud;

architecture Behavioral of cloud is

begin
	
	process (Instr15to0, ImExt)
	
	begin
		-- 00 is for sign ext
		if ImExt = "00" then
			CloudResult(15 downto 0) <= Instr15to0;
			CloudResult(31 downto 16) <= (others => Instr15to0(15));
		
		-- 01 for zero fill
		elsif ImExt = "01" then
			CloudResult(15 downto 0) <= Instr15to0;
			CloudResult(31 downto 16) <= (others => '0');
		
		-- 10 for sign ext + shift << 2
		elsif ImExt = "10" then
			CloudResult(31 downto 18) <= (others => Instr15to0(15));
			CloudResult(17 downto 2) <= Instr15to0;
			CloudResult(1 downto 0) <= "00";
		
		-- 11 for shift <<16 and zeroFill
		elsif ImExt = "11" then
			CloudResult(15 downto 0) <= (others => '0');
			CloudResult(31 downto 16) <= Instr15to0;
		
		-- just in case it fails
		else
			CloudResult <= (others => '0');
		
		end if;
	
	end process;

end Behavioral;


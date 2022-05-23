----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:18:58 03/27/2022 
-- Design Name: 
-- Module Name:    Register32Bit - Behavioral 
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

entity Register32Bit is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           WE : in  STD_LOGIC;
           Datain : in  STD_LOGIC_VECTOR (31 downto 0);
           Dataout : out  STD_LOGIC_VECTOR (31 downto 0));
end Register32Bit;

architecture Behavioral of Register32Bit is

begin
	process (CLK) is 
	begin 		
		if rising_edge(CLK) then
			if RST = '1' then
				Dataout <= (others => '0') after 10ns;
			elsif WE = '1' then
				Dataout <= Datain after 10ns;
			end if;
		end if;
	end process;
	
end Behavioral;

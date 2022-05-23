----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:17:04 03/31/2022 
-- Design Name: 
-- Module Name:    addition_module - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity addition_module is
    Port ( PCImmed : in  STD_LOGIC_VECTOR (31 downto 0);
           pc_plus4 : in  STD_LOGIC_VECTOR (31 downto 0);
           result : out  STD_LOGIC_VECTOR (31 downto 0));
end addition_module;

architecture Behavioral of addition_module is

begin
	result <= pc_plus4 + STD_LOGIC_VECTOR(shift_left(signed(PCImmed), 2));  --PC = PC + 4 + PCImmed; -> sll 2
	--TO PcImmed exei ginei hdh signExt kai <<2 apo to endoder toy DECSTAGE
	
end Behavioral;


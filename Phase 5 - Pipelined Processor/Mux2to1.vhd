----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:48:49 03/31/2022 
-- Design Name: 
-- Module Name:    Mux2to1 - Behavioral 
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

entity Mux2to1 is
    Port ( InputA : in  STD_LOGIC_VECTOR (31 downto 0);
           InputB : in  STD_LOGIC_VECTOR (31 downto 0);
           Selection : in  STD_LOGIC;
           mux2to1_output : out  STD_LOGIC_VECTOR (31 downto 0));
end Mux2to1;

architecture Behavioral of Mux2to1 is

begin
	
	with Selection select
		mux2to1_output <= InputA when '0',
								InputB when '1',
								(others => '0') when others;
	
end Behavioral;


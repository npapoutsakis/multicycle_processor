----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:54:33 03/27/2022 
-- Design Name: 
-- Module Name:    Mux32to1 - Behavioral 
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
use work.Array_Variable.all;
	
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Mux32to1 is
    Port ( Input : in number_of_32_bits;
           Sel : in  STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
           Dout : out  STD_LOGIC_VECTOR (31 downto 0) := (others => '0'));
end Mux32to1;

architecture Behavioral of Mux32to1 is

signal mux_early_output: STD_LOGIC_VECTOR(31 downto 0);

begin

  mux_early_output <= Input(0) when Sel = "00000" else 
							 Input(1) when Sel = "00001" else
							 Input(2) when Sel = "00010" else
							 Input(3) when Sel = "00011" else
							 Input(4) when Sel = "00100" else
							 Input(5) when Sel = "00101" else
							 Input(6) when Sel = "00110" else
							 Input(7) when Sel = "00111" else
							 Input(8)  when Sel = "01000" else
							 Input(9)  when Sel = "01001" else
							 Input(10) when Sel = "01010" else
							 Input(11) when Sel = "01011" else
							 Input(12) when Sel = "01100" else
							 Input(13) when Sel = "01101" else
							 Input(14) when Sel = "01110" else
							 Input(15) when Sel = "01111" else
							 Input(16) when Sel = "10000" else
							 Input(17) when Sel = "10001" else
							 Input(18) when Sel = "10010" else
							 Input(19) when Sel = "10011" else
							 Input(20) when Sel = "10100" else
							 Input(21) when Sel = "10101" else
							 Input(22) when Sel = "10110" else
							 Input(23) when Sel = "10111" else
							 Input(24) when Sel = "11000" else
							 Input(25) when Sel = "11001" else
							 Input(26) when Sel = "11010" else
							 Input(27) when Sel = "11011" else
							 Input(28) when Sel = "11100" else
							 Input(29) when Sel = "11101" else
							 Input(30) when Sel = "11110" else
							 Input(31) when Sel = "11111";
					 
	Dout <= mux_early_output after 10ns;

end Behavioral;


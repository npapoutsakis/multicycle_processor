----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:29:55 05/21/2022 
-- Design Name: 
-- Module Name:    SignalMux - Behavioral 
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

entity SignalMux is
    Port ( inputA : in  STD_LOGIC_VECTOR (7 downto 0);
           chooser : in  STD_LOGIC;
			  control_signal_out : out  STD_LOGIC_VECTOR (7 downto 0)
			 );
end SignalMux;

architecture Behavioral of SignalMux is

begin
	with chooser select
		control_signal_out <= InputA when '0',
									 (others => '0') when others;
									  
end Behavioral;


--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package Array_Variable is

 type number_of_32_bits is array(31 downto 0) of std_logic_vector(31 downto 0);
 
end Array_Variable;

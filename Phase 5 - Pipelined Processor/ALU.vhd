----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:47:15 03/20/2022 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( A : in  STD_LOGIC_VECTOR (31 downto 0);
           B : in  STD_LOGIC_VECTOR (31 downto 0);
           Op : in  STD_LOGIC_VECTOR (3 downto 0);
           Output : out  STD_LOGIC_VECTOR (31 downto 0);
           Zero : out  STD_LOGIC;
           Cout : out  STD_LOGIC;
           Ovf : out  STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

signal early_output : STD_LOGIC_VECTOR (31 downto 0);
signal early_zero : STD_LOGIC;
signal early_cout : STD_LOGIC;
signal early_ovf : STD_LOGIC;

signal addALU: STD_LOGIC_VECTOR (32 downto 0) := (others=> '0');
signal subALU: STD_LOGIC_VECTOR (32 downto 0) := (others=> '0');

signal inputA : STD_LOGIC_VECTOR (32 downto 0) := (others=> '0');
signal inputB : STD_LOGIC_VECTOR (32 downto 0) := (others=> '0');

begin
	
	inputA(31 downto 0) <= A(31 downto 0);
	inputB(31 downto 0) <= B(31 downto 0);	
	
	addALU <= inputA + inputB; 
	subALU <= inputA - inputB;
	
	process (A, B, Op) is
	begin 
		if Op = "0010" then
			early_output <= A and B;
			
		elsif Op = "0011" then 
			early_output <= A or B;

		elsif Op = "0100" then 
			early_output <= not A;

		elsif Op = "0101" then 
			early_output <= A nand B;
		
		elsif Op = "0110" then 
			early_output <= A nor B;

		elsif Op = "1000" then 
			early_output <= std_logic_vector(shift_right(signed(A), 1));

		elsif Op = "1001" then 
			early_output <= std_logic_vector(shift_right(unsigned(A), 1));

		elsif Op = "1010" then 
			early_output <= std_logic_vector(shift_left(unsigned(A), 1));

		elsif Op = "1100" then 
			early_output <= std_logic_vector(rotate_left(unsigned(A), 1));

		elsif Op = "1101" then 
			early_output <= std_logic_vector(rotate_right(unsigned(A), 1));
		
		end if;
	end process;
	
	Output <= addALU(31 downto 0) after 10ns when Op = "0000" else
				 subALU(31 downto 0) after 10ns when Op = "0001" else
				 early_output  after 10ns;	
	
	early_ovf <= '1' when ((inputA(31) = inputB(31)) and (addALU(31) /= inputA(31)) and (Op = "0000")) else 
					 '1' when ((inputA(31) /= inputB(31)) and (subALU(31) = inputB(31)) and (Op = "0001")) else
					 '0';
	Ovf <= early_ovf after 10ns;
	
	early_cout <= addALU(32) when Op = "0000" and early_ovf /= '1' else
			        subALU(32) when Op = "0001" and early_ovf /= '1' else
			        '0';
	Cout <= early_cout after 10ns;
	
	early_zero <= '1' when addALU(31 downto 0)= 0 and Op = "0000" else
					  '1' when subALU(31 downto 0)= 0 and Op = "0001" else
					  '1' when early_output = 0 and Op /= "0000" and Op /= "0001" else
					  '0';
	
	Zero <= early_zero after 10ns;	
	
end Behavioral;
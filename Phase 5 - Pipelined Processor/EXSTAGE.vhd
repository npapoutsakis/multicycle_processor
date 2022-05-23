----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:00:11 04/01/2022 
-- Design Name: 
-- Module Name:    EXSTAGE - Behavioral 
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

entity EXSTAGE is
    Port ( RF_A : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_B : in  STD_LOGIC_VECTOR (31 downto 0);
           Immed : in  STD_LOGIC_VECTOR (31 downto 0);
           ALU_Bin_sel : in  STD_LOGIC;
           ALU_func : in  STD_LOGIC_VECTOR (3 downto 0);
           ALU_out : out  STD_LOGIC_VECTOR (31 downto 0);
           ALU_zero : out  STD_LOGIC);
end EXSTAGE;

architecture Behavioral of EXSTAGE is

component ALU is
    Port ( A : in  STD_LOGIC_VECTOR (31 downto 0);
           B : in  STD_LOGIC_VECTOR (31 downto 0);
           Op : in  STD_LOGIC_VECTOR (3 downto 0);
           Output : out  STD_LOGIC_VECTOR (31 downto 0);
           Zero : out  STD_LOGIC;
           Cout : out  STD_LOGIC;
           Ovf : out  STD_LOGIC);
end component;

component Mux2to1 is
    Port ( InputA : in  STD_LOGIC_VECTOR (31 downto 0);
           InputB : in  STD_LOGIC_VECTOR (31 downto 0);
           Selection : in  STD_LOGIC;
           mux2to1_output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

signal mux_output : STD_LOGIC_VECTOR (31 downto 0);

begin
	
	ALU_Module : ALU 
		Port map ( A => RF_A,
					  B => mux_output,
					  Op => ALU_func,
					  Output => ALU_out,
					  Zero => ALU_zero,
					  Cout => open,
					  Ovf => open
				   );
	

	Mux2x1 : Mux2to1
		port map ( InputA => RF_B,
					  InputB => Immed,
					  Selection => ALU_Bin_sel,
					  mux2to1_output => mux_output
					);

end Behavioral;


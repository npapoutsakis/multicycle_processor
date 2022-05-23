----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:51:46 03/31/2022 
-- Design Name: 
-- Module Name:    IFSTAGE - Behavioral 
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

entity IFSTAGE is
    Port ( PC_Immed : in  STD_LOGIC_VECTOR (31 downto 0);
           PC_Sel : in  STD_LOGIC;
           PC_LdEn : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           PC : out  STD_LOGIC_VECTOR (31 downto 0));
end IFSTAGE;

architecture Behavioral of IFSTAGE is

component Register32Bit is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           WE : in  STD_LOGIC;
           Datain : in  STD_LOGIC_VECTOR (31 downto 0);
           Dataout : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component addition_module is
    Port ( PCImmed : in  STD_LOGIC_VECTOR (31 downto 0);
           pc_plus4 : in  STD_LOGIC_VECTOR (31 downto 0);
           result : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component plus4module is
    Port ( input : in  STD_LOGIC_VECTOR (31 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component Mux2to1 is
    Port ( InputA : in  STD_LOGIC_VECTOR (31 downto 0);
           InputB : in  STD_LOGIC_VECTOR (31 downto 0);
           Selection : in  STD_LOGIC;
           mux2to1_output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

signal register_out : STD_LOGIC_VECTOR (31 downto 0);
signal plus4_out : STD_LOGIC_VECTOR (31 downto 0);
signal immed_add_out : STD_LOGIC_VECTOR (31 downto 0);
signal mux_out : STD_LOGIC_VECTOR (31 downto 0);

begin
	
	PC_Register : Register32Bit
		    port map( CLK => Clk,
						  RST => Reset,
						  WE => PC_LdEn,
						  Datain => mux_out,
						  Dataout => register_out
						 );	
	
	Increment4: plus4module
		    port map( input => register_out,
						  output => plus4_out
						 );

	Imm_Addition : addition_module 
		    port map( PCImmed => PC_Immed,
						  pc_plus4 => plus4_out,
						  result => immed_add_out
						 );
	
	Mux2x1 : Mux2to1 
		    port map( InputA => plus4_out,
						  InputB => immed_add_out,
						  Selection => PC_Sel,
						  mux2to1_output => mux_out
						 );	
	
	PC <= register_out;

	
end Behavioral;


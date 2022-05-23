----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:14:27 04/01/2022 
-- Design Name: 
-- Module Name:    DECSTAGE - Behavioral 
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

entity DECSTAGE is
    Port ( Instr : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_WrEn : in  STD_LOGIC;
           ALU_out : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_out : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_Address_Write : in  STD_LOGIC_VECTOR (4 downto 0);
			  RF_WrData_sel : in  STD_LOGIC;
           RF_B_sel : in  STD_LOGIC;
           FinalData : out STD_LOGIC_VECTOR (31 downto 0);
			  RST : in STD_LOGIC;
           Clk : in  STD_LOGIC;
           Immed : out  STD_LOGIC_VECTOR (31 downto 0);
           RF_A : out  STD_LOGIC_VECTOR (31 downto 0);
           RF_B : out  STD_LOGIC_VECTOR (31 downto 0));
end DECSTAGE;

architecture Behavioral of DECSTAGE is

component RF is
    Port ( Ard1 : in  STD_LOGIC_VECTOR (4 downto 0);
           Ard2 : in  STD_LOGIC_VECTOR (4 downto 0);
           Awr : in  STD_LOGIC_VECTOR (4 downto 0);
           Dout1 : out  STD_LOGIC_VECTOR (31 downto 0);
           Dout2 : out  STD_LOGIC_VECTOR (31 downto 0);
           Din : in  STD_LOGIC_VECTOR (31 downto 0);
           WrEn : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           Rst : in  STD_LOGIC);
end component;

component Mux2x1_5Bits is
    Port ( in0 : in  STD_LOGIC_VECTOR (4 downto 0);
           in1 : in  STD_LOGIC_VECTOR (4 downto 0);
           sel : in  STD_LOGIC;
           outt : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

component cloud is
    Port ( Instr15to0 : in  STD_LOGIC_VECTOR (15 downto 0);
           ImExt : in  STD_LOGIC_VECTOR (1 downto 0);
           CloudResult : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component Mux2to1 is
    Port ( InputA : in  STD_LOGIC_VECTOR (31 downto 0);
           InputB : in  STD_LOGIC_VECTOR (31 downto 0);
           Selection : in  STD_LOGIC;
           mux2to1_output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component dec_encoder is
    Port ( encoder_in : in  STD_LOGIC_VECTOR (5 downto 0);
           encoder_out : out  STD_LOGIC_VECTOR (1 downto 0));
end component;

signal dec_out : STD_LOGIC_VECTOR (1 downto 0);
signal small_mux_out : STD_LOGIC_VECTOR (4 downto 0);
signal big_32bit_mux_out : STD_LOGIC_VECTOR (31 downto 0);

begin

	Register_File : RF
		port map ( Ard1 => Instr(25 downto 21),
					  Ard2 => small_mux_out,
					  Awr => RF_Address_Write,
					  Dout1 => RF_A,
					  Dout2 => RF_B,
					  Din => big_32bit_mux_out	,
					  WrEn => RF_WrEn,
					  Clk => Clk,
					  Rst => RST
					);
	
	
	Mux5bit : Mux2x1_5Bits
		port map ( in0 => Instr(15 downto 11),
					  in1 => Instr(20 downto 16),
					  sel => RF_B_sel,
					  outt => small_mux_out
					);		
	
	Mux32Bit : Mux2to1 
		port map ( InputA => ALU_out,
					  InputB => MEM_out,
					  Selection => RF_WrData_sel,
					  mux2to1_output => big_32bit_mux_out
					);
	
	FinalData <= big_32bit_mux_out;
	
	ImmExt_Selector : dec_encoder
		port map ( encoder_in => Instr(31 downto 26),
					  encoder_out => dec_out
					);	
	
	Convertion : cloud
		port map ( Instr15to0 => Instr(15 downto 0),
					  ImExt => dec_out,
					  CloudResult => Immed
					);	

end Behavioral;

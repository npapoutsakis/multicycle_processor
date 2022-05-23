----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:09:12 03/28/2022 
-- Design Name: 
-- Module Name:    RF - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RF is
    Port ( Ard1 : in  STD_LOGIC_VECTOR (4 downto 0);
           Ard2 : in  STD_LOGIC_VECTOR (4 downto 0);
           Awr : in  STD_LOGIC_VECTOR (4 downto 0);
           Dout1 : out  STD_LOGIC_VECTOR (31 downto 0);
           Dout2 : out  STD_LOGIC_VECTOR (31 downto 0);
           Din : in  STD_LOGIC_VECTOR (31 downto 0);
           WrEn : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           Rst : in  STD_LOGIC);
end RF;

architecture Behavioral of RF is

signal regToMux : number_of_32_bits;
signal decoder_output: STD_LOGIC_VECTOR (31 downto 0);
signal and_gate_result: STD_LOGIC_VECTOR (31 downto 0);

component Decoder5to32 is
    Port ( DecoderInput : in  STD_LOGIC_VECTOR (4 downto 0);
           DecoderOutput : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component Mux32to1 is
    Port ( Input : in number_of_32_bits;
           Sel : in  STD_LOGIC_VECTOR(4 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component Register32Bit is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           WE : in  STD_LOGIC;
           Datain : in  STD_LOGIC_VECTOR (31 downto 0);
           Dataout : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

begin
	
	Decoder: Decoder5to32 port map( DecoderInput => Awr,
                                   DecoderOutput => decoder_output	
											 );
	
	
	Register_R0: Register32Bit port map( CLK => Clk,
													 RST => '1',
													 WE => '0',
													 Datain => Din,
													 Dataout => regToMux(0)
													);
													
	
	Register_Generation: 
				for i in 1 to 31 generate
					
					and_gate_result(i) <= (decoder_output(i) and WrEn) after 2 ns;
					
					Register_Ri: Register32Bit port map( CLK => Clk,
																	 RST => Rst,
																	 WE => and_gate_result(i),
																	 Datain => Din,
																	 Dataout => regToMux(i)
																   );
				
				end generate;
	
	
	Mux_No1: Mux32to1 port map( Input => regToMux,
                               Sel => Ard1,	
										 Dout => Dout1
										); 
	
	
	Mux_No2: Mux32to1 port map( Input => regToMux,
                               Sel => Ard2,	
										 Dout => Dout2
										); 
										

end Behavioral;


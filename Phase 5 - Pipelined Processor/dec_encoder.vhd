----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:54:40 04/04/2022 
-- Design Name: 
-- Module Name:    dec_encoder - Behavioral 
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

entity dec_encoder is
    Port ( encoder_in : in  STD_LOGIC_VECTOR (5 downto 0);
           encoder_out : out  STD_LOGIC_VECTOR (1 downto 0));
end dec_encoder;

architecture Behavioral of dec_encoder is

begin
	-- See CHARIS.
	ImmExtSelection : process(encoder_in)
	begin	
			-- Sign ext
			if encoder_in = "111000" or encoder_in = "110000" or encoder_in = "000011" or encoder_in = "000111" or encoder_in = "001111" or encoder_in = "011111" then
				encoder_out <= "00";
			
			-- Sign Ext, In this case we have a branch instruction, so we extend the sign because the shift will come from IFSTAGE by selecting PC_Sel = 1;
			-- Control Module makes everything work, by checking the ALU_Zero signal in case of a beq, bne, b.
			-- Otherwise the Immed is shifted 4 bits to the left.
			elsif encoder_in = "111111"  or encoder_in = "000000" or encoder_in = "000001" then
				encoder_out <= "00";	
			
			-- ZeroFill
			elsif encoder_in ="110010" or encoder_in = "110011" then
				encoder_out <= "01";
			
			-- Shift<<16 & ZeroFill
			elsif encoder_in = "111001" then
				encoder_out <= "11";
				
			end if;
	
	end process;

end Behavioral;


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:25:54 05/20/2022 
-- Design Name: 
-- Module Name:    ForwardingUnit - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ForwardingUnit is
	Port ( ID_EX_Rs :in STD_LOGIC_VECTOR(4 downto 0);
			 ID_EX_Rt :in STD_LOGIC_VECTOR(4 downto 0);
			 EX_MEM_Rd : in STD_LOGIC_VECTOR(4 downto 0);
			 MEM_WB_Rd : in STD_LOGIC_VECTOR(4 downto 0); 
			
		 	 EX_MEM_RF_WrEn : in STD_LOGIC;
			 MEM_WB_RF_WrEn : in STD_LOGIC;
			
			 FORWARD_A : out STD_LOGIC_VECTOR(1 downto 0);
			 FORWARD_B : out STD_LOGIC_VECTOR(1 downto 0)
		);
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is

begin
	--Combinational circuit
	forward_checker : process(ID_EX_Rs, ID_EX_Rt, EX_MEM_Rd, MEM_WB_Rd, EX_MEM_RF_WrEn, MEM_WB_RF_WrEn)
	begin 
		
		if (EX_MEM_RF_WrEn = '1' and (EX_MEM_Rd /= "00000") and (ID_EX_Rs = EX_MEM_Rd)) then
			FORWARD_A <= "10";
		elsif (MEM_WB_RF_WrEn = '1' and (MEM_WB_Rd /= "00000") and (MEM_WB_Rd = ID_EX_Rs)) then
			FORWARD_A <= "01";
		else
			FORWARD_A <= "00";
		end if;
		
		if (EX_MEM_RF_WrEn = '1' and (EX_MEM_Rd /= "00000") and (ID_EX_Rt = EX_MEM_Rd)) then
			FORWARD_B <= "10";
		elsif (MEM_WB_RF_WrEn = '1' and (MEM_WB_Rd /= "00000") and (MEM_WB_Rd = ID_EX_Rt)) then
			FORWARD_B <= "01";
		else
			FORWARD_B <= "00";
		end if;
	end process;

end Behavioral;


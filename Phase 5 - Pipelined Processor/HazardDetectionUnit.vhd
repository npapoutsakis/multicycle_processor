----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:52:31 05/21/2022 
-- Design Name: 
-- Module Name:    HazardDetectionUnit - Behavioral 
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

entity HazardDetectionUnit is
	Port ( IF_ID_Rs : in STD_LOGIC_VECTOR(4 downto 0);
			 IF_ID_Rt : in STD_LOGIC_VECTOR(4 downto 0);
			 ID_EX_RD : in STD_LOGIC_VECTOR(4 downto 0);
			 ID_EX_MemWrEn : in STD_LOGIC; 
			 ID_EX_Opcode : in STD_LOGIC_VECTOR(5 downto 0);
			 Control_Mux_Sel : out STD_LOGIC;
			 IF_ID_WrEn : out STD_LOGIC;
			 PC_LdEnable : out STD_LOGIC
			);
end HazardDetectionUnit;

architecture Behavioral of HazardDetectionUnit is

begin
	process (IF_ID_Rs, IF_ID_Rt, ID_EX_RD, ID_EX_Opcode)
	begin
		if (((ID_EX_Opcode = "001111") or (ID_EX_Opcode = "000011")) and ((ID_EX_RD = IF_ID_Rs) or (ID_EX_RD = IF_ID_Rt))) then --for load instructions
			IF_ID_WrEn <= '0';
			PC_LdEnable <= '0';
			Control_Mux_Sel <= '1';
		else 
			IF_ID_WrEn <= '1';
			PC_LdEnable <= '1';
			Control_Mux_Sel <= '0';	
		end if;
	end process;

end Behavioral;


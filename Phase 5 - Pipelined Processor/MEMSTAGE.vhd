----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:12:50 04/02/2022 
-- Design Name: 
-- Module Name:    MEMSTAGE - Behavioral 
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

entity MEMSTAGE is
    Port ( ByteOp : in  STD_LOGIC;
           Mem_WrEn : in  STD_LOGIC;
           ALU_MEM_Addr : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_DataIn : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_DataOut : out  STD_LOGIC_VECTOR (31 downto 0);
           MM_WrEn : out  STD_LOGIC;
           MM_Addr : out  STD_LOGIC_VECTOR (31 downto 0):= (others => '0');
           MM_WrData : out  STD_LOGIC_VECTOR (31 downto 0);
           MM_RdData : in  STD_LOGIC_VECTOR (31 downto 0));
end MEMSTAGE;

architecture Behavioral of MEMSTAGE is

signal load_data : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal store_data : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal early_mem : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal just_zeros : STD_LOGIC_VECTOR (23 downto 0) := (others => '0');

begin
	
	--nothing to change just pass the signal
	MM_WrEn <= Mem_WrEn;
	
	--Address in memory must has an offset (+0x400) -> 1024 -> 10000000000
	early_mem <= ALU_MEM_Addr + "00000000000000000000010000000000";
	
	MM_Addr(12 downto 2) <= early_mem(12 downto 2);
	
	load_data <= MM_RdData when ByteOp = '0' and Mem_WrEn = '0' else 										-- RF[rd] <- MEM[RF[rs] + SignExtend(Imm)] --> Load Word
					 just_zeros & MM_RdData(7 downto 0) when ByteOp = '1' and Mem_WrEn = '0';		   -- RF[rd] <- ZeroFill(31 downto 8) & MEM[RF[rs] + SignExtend(Imm)](7 downto 0) --> Load Byte
			
	
	MEM_DataOut <= load_data;
	
	store_data <= MEM_DataIn when ByteOp = '0' and Mem_WrEn = '1' else									-- MEM[RF[rs] + SignExtend(Imm)] <- RF[rd] --> Store Word
					  just_zeros & MEM_DataIn(7 downto 0) when ByteOp = '1' and Mem_WrEn = '1';		-- MEM[RF[rs] + SignExtend(Imm)] <- ZeroFill(31 downto 8) & RF[rd](7 downto 0) --> Store Byte				 
		
	MM_WrData <= store_data;

end Behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity LSFR_8 is 
	port(CLK : in STD_LOGIC;
			R_OUT : out STD_LOGIC_VECTOR(7 downto 0)
			);

end LSFR_8;

architecture A of LSFR_8 is 

signal CURR_STATE, NEXT_STATE : STD_LOGIC_VECTOR(7 downto 0) := X"01";
signal FEEDBACK : STD_LOGIC;

begin
	
	process(CLK)
	begin
			if rising_edge(CLK) then
			CURR_STATE <= NEXT_STATE;
			end if;
	end process;
	
	FEEDBACK <= CURR_STATE(4) XOR CURR_STATE(3) XOR CURR_STATE(2) XOR CURR_STATE(0);
	NEXT_STATE <= FEEDBACK & CURR_STATE(7 downto 1);
	R_OUT <= CURR_STATE;
	
end A;

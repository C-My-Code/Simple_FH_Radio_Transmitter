library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Modulator is 
port ( IDLE, DATA : in std_logic;
	CARRIER : in std_logic_vector(7 downto 0);
	DATA_OUT : out std_logic_vector(9 downto 0)
	);
end entity Modulator;

-- architecture declaration

architecture behavioral of Modulator is
	signal divide_out : std_logic_vector (7 downto 0) := "00000000";
begin
	divide_calc: process (CARRIER, IDLE)
	begin
	if IDLE = '0' then
		if DATA = '0' then
			DATA_OUT <= "00" & CARRIER(7 downto 2)& "00"; 
		else
			DATA_OUT <= CARRIER & "00";
		end if;
	end if;
	end process;

end architecture behavioral;

	



-- Created By: Kevin Miller
--	Last Edit: 4/14/22 Kevin
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity P_Generator is
	port(
		CLK : in STD_LOGIC;
		GEN_PACKET : in STD_LOGIC;
		RTS_OR_DATA : in STD_LOGIC;
		NEXT_FREQ : in STD_LOGIC_VECTOR(1 downto 0);
		DATA_IN : in STD_LOGIC_VECTOR(7 downto 0);
		SEND_COMPLETE : in STD_LOGIC;
		DATA_OUT : out STD_LOGIC_VECTOR(15 downto 0);
		PACKET_READY : out STD_LOGIC
	);

end P_Generator;


architecture A of P_Generator is
type STATE is (IDLE, SEND_RTS, SEND_DATA);
signal CURR_STATE : STATE := IDLE;
signal FREQ : STD_LOGIC_VECTOR(1 downto 0);
--signal COUNT : unsigned(15 downto 0) := X"0000";

begin

process(GEN_PACKET, SEND_COMPLETE)
begin

FREQ<=NEXT_FREQ;

if SEND_COMPLETE = '1' then
	CURR_STATE <= IDLE;
	
elsif GEN_PACKET = '1' then
	if RTS_OR_DATA = '1' then
		CURR_STATE <= SEND_DATA;
	else
		CURR_STATE <= SEND_RTS;
	end if;

end if;
end process;

process(CLK)
begin
	if rising_edge(CLK) then
		if CURR_STATE = SEND_RTS then
--			if COUNT > 0 then
				PACKET_READY <= '1';
				DATA_OUT <= "110000"&FREQ&"00000000";
--			else
--				COUNT <= COUNT + 1;
--			end if;
				
		elsif CURR_STATE = sEND_DATA then
		PACKET_READY <= '1';
			DATA_OUT <= "110010"&FREQ&DATA_IN;
		else
			PACKET_READY <= '0';
			DATA_OUT <= X"0000";
		end if;
	end if;
end process;
end A;
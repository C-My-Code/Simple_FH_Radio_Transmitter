-- Created By: Kevin Miller
--	Last Edit: 4/10/22 Kevin
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Send_Controller is
	port(CLK : in STD_LOGIC;
			RESET : in STD_LOGIC;
			PACKET_READY : in STD_LOGIC;
			PACKET : in STD_LOGIC_VECTOR(15 downto 0);
			SEND_COMPLETE : out STD_LOGIC;
			IDLE_O : out STD_LOGIC;
			DATA : out STD_LOGIC);

end Send_Controller;


architecture A of Send_Controller is

type STATE is (IDLE, SENDING);
signal CURR_STATE : STATE := IDLE;
signal CURR_OUT : STD_LOGIC := '0';

begin

process(CLK, CURR_STATE)
begin
	if CURR_STATE = SENDING then
		IDLE_O <= '0'; 
	else
		IDLE_O <= '1';-- Tells modulator to output no signal.
	end if;
end process;


process(CLK, RESET)
variable DR_COUNTER : unsigned(15 downto 0) := X"0000"; -- DATA RATE counter 
variable CURR_INDEX : integer := 15;
begin
		
		if RESET = '1' then
			CURR_STATE <= IDLE;
			
		elsif CLK = '1' then
			case CURR_STATE is
			
			when IDLE => 
				CURR_INDEX := 15;
				DR_COUNTER := X"0000";
				SEND_COMPLETE <= '0';
				if PACKET_READY = '1' then
					CURR_STATE <= SENDING;
				end if;
			when SENDING =>
				if DR_COUNTER >= X"61A7" then -- 24,999 .5ms @ 50mhz
					if CURR_INDEX = 0 then
						SEND_COMPLETE <= '1';
						CURR_STATE <= IDLE;
					else
						CURR_INDEX := CURR_INDEX - 1;
						DR_COUNTER := X"0000";
					end if;
				else
					CURR_OUT <= PACKET(CURR_INDEX);
					DR_COUNTER := DR_COUNTER + 1;
				end if;
				
			when others =>
				null;
			end case;
		end if;

end process;

DATA<=CURR_OUT; 
end A;
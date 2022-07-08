
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Receiver_Sim is
	port(
		CLK : in STD_LOGIC;
		ack : out STD_LOGIC;
		clr_ack : in STD_LOGIC;
		buffer_not_empty : out STD_LOGIC;
		increment_buffer : in STD_LOGIC;
		data_out : out STD_LOGIC_VECTOR(7 downto 0);
		send_complete : in STD_LOGIC
	);

end Receiver_Sim;

architecture A of Receiver_Sim is

constant WAIT_PERIOD : time := 100 ns;
constant TIMEOUT_PERIOD : time := 11 ms;

signal RAND_OUT : STD_LOGIC_VECTOR(7 downto 0);

component LSFR_8 
		port(CLK : in STD_LOGIC;
		R_OUT : out STD_LOGIC_VECTOR(7 downto 0)
		);
end component;

begin

LSFR_1 : LSFR_8 port map(CLK=>CLK,R_OUT=>RAND_OUT);

process
begin

--1st message - normal - buffer empty at end
wait for WAIT_PERIOD;
buffer_not_empty<='1';
data_out<=RAND_OUT;

wait until send_complete = '1';
ack<='1' after 100 ns;

wait until clr_ack = '1';
ack<='0';

wait until increment_buffer = '1';
buffer_not_empty<='0';

--2nd message - normal - buffer not empty at end
wait for WAIT_PERIOD;
buffer_not_empty<='1';
data_out<=RAND_OUT;

wait until send_complete = '1';
ack<='1' after 100 ns;

wait until clr_ack = '1';
ack<='0';

wait until increment_buffer = '1';

--3rd message - normal - buffer not empty at end
wait for WAIT_PERIOD;
buffer_not_empty<='1';
data_out<=RAND_OUT;

wait until send_complete = '1';
ack<='1' after 100 ns;

wait until clr_ack = '1';
ack<='0';

--4th message - 1 No RTS Ack(message will be sent on second attempt) - buffer not empty at end 
data_out<=RAND_OUT;

wait for 11 ms; -- Timeout is 10 ms - a resend of data will be attempted after first timeout
wait until send_complete = '1';
ack<='1' after 100 ns;

wait until clr_ack = '1';
ack<='0';


--5th Message - 2 No RTS ACK(message will not be sent on second attempt) - buffer not empty at end 
data_out<=RAND_OUT;
wait for 21 ms; -- This is long enough to cause 2 timeouts which will return controller back idle


--6th message - normal - buffer empty at end
wait until send_complete = '1';
ack<='1' after 100 ns;

wait until clr_ack = '1';
ack<='0';

wait until increment_buffer = '1';
buffer_not_empty<='0';

end process;
end A;
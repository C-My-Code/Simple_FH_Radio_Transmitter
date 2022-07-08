
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Top_Test is
	port(
		dac : out STD_LOGIC_VECTOR(9 downto 0)
	);


end Top_Test;

architecture A of Top_Test is

signal TEST_CLK_50 : STD_LOGIC := '0';

--Between Main and Receiver Sim
signal ACK_SIGNAL : STD_LOGIC:= '0';
signal BUFF_NOT_EMPTY_SIGNAL : STD_LOGIC:= '0';
signal CLR_ACK_SIGNAL : STD_LOGIC:= '0';
signal DATA_SENT_SIGNAL : STD_LOGIC:= '0'; -- Increment data buffer notification


--Between Send Controller, Main, and Packet Generator
signal SEND_COMPLETE_SIGNAL : STD_LOGIC:= '0';

--Between Main and Send Controller
signal SEND_CONTROLLER_RESET_SIGNAL : STD_LOGIC:= '0';

--Between Main and Packet Gen
signal RTS_OR_DATA_SIGNAL : STD_LOGIC:= '0';
signal GEN_PACKET_SIGNAL : STD_LOGIC:= '0';
signal NEXT_FREQ_SIGNAL : STD_LOGIC_VECTOR(1 downto 0) := "00";

--Between Main and Carrier
signal FREQ_SELECT_SIGNAL : STD_LOGIC_VECTOR(1 downto 0) := "00"; 

--Between Carrier and Modulator
signal CARRIER_SIGNAL : STD_LOGIC_VECTOR(7 downto 0);

--Between Send Controller and Modulator
signal DATA_TO_MOD_SIGNAL : STD_LOGIC := '0';
signal MOD_IDLE_SIGNAL : STD_LOGIC:= '0';

--Between Modulator and Dac
signal DAC_SIGNAL : STD_LOGIC_VECTOR(9 downto 0);

--Between Receiver and Packet Gen
signal DATA_SIGNAL : STD_LOGIC_VECTOR(7 downto 0);

--Between Packet Gen and Send Controller
signal PACKET_READY_SIGNAL : STD_LOGIC:= '0';
signal PACKET_SIGNAL : STD_LOGIC_VECTOR(15 downto 0);


component Main_Controller
	port(
		ACK : in STD_LOGIC;
		BUFF_NOT_EMPTY : in STD_LOGIC;
		SEND_COMPLETE : in STD_LOGIC;
		CLK : in STD_LOGIC;
		DATA_SENT : out STD_LOGIC; -- notifies buffer that data was sent
		CLR_ACK : out STD_LOGIC;
		SEND_CONTROLLER_RESET : out STD_LOGIC;
		RTS_OR_DATA : out STD_LOGIC;
		GEN_PACKET : out STD_LOGIC;
		FREQ_SELECT : out STD_LOGIC_VECTOR(1 downto 0); -- Current transmission freq/carrier control
		NEXT_FREQ : out STD_LOGIC_VECTOR(1 downto 0) -- Trasmission freq to send in packet for data transmission
	);
end component;

component Send_Controller 
		port(CLK : in STD_LOGIC;
			RESET : in STD_LOGIC;
			PACKET_READY : in STD_LOGIC;
			PACKET : in STD_LOGIC_VECTOR(15 downto 0);
			SEND_COMPLETE : out STD_LOGIC;
			IDLE_O : out STD_LOGIC;
			DATA : out STD_LOGIC);
end component;

component P_Generator
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

end component;

component Receiver_Sim
	port(
		CLK : in STD_LOGIC;
		ack : out STD_LOGIC;
		clr_ack : in STD_LOGIC;
		buffer_not_empty : out STD_LOGIC;
		increment_buffer : in STD_LOGIC;
		data_out : out STD_LOGIC_VECTOR(7 downto 0);
		send_complete : in STD_LOGIC
	);

end component;

component carrier_gen
port ( clk : in std_logic;
	sel : in std_logic_vector (1 downto 0);
	raw_out : out std_logic_vector (7 downto 0)
	);
end component;

component Modulator 
port ( IDLE, DATA : in std_logic;
	CARRIER : in std_logic_vector(7 downto 0);
	DATA_OUT : out std_logic_vector(9 downto 0)
	);
end component;

begin

Main : Main_Controller port map(
		ACK=>ACK_SIGNAL,
		BUFF_NOT_EMPTY=>BUFF_NOT_EMPTY_SIGNAL,
		SEND_COMPLETE=>SEND_COMPLETE_SIGNAL,
		CLK=>TEST_CLK_50,
		DATA_SENT=>DATA_SENT_SIGNAL, -- notifies buffer that data was sent
		CLR_ACK=>CLR_ACK_SIGNAL,
		SEND_CONTROLLER_RESET=>SEND_CONTROLLER_RESET_SIGNAL,
		RTS_OR_DATA=>RTS_OR_DATA_SIGNAL,
		GEN_PACKET=>GEN_PACKET_SIGNAL,
		FREQ_SELECT=>FREQ_SELECT_SIGNAL, -- Current transmission freq/carrier control
		NEXT_FREQ=>NEXT_FREQ_SIGNAL);
		
Send : Send_Controller port map(
			CLK=>TEST_CLK_50,
			RESET=>SEND_CONTROLLER_RESET_SIGNAL,
			PACKET_READY=>PACKET_READY_SIGNAL,
			PACKET=>PACKET_SIGNAL,
			SEND_COMPLETE=>SEND_COMPLETE_SIGNAL,
			IDLE_O=>MOD_IDLE_SIGNAL,
			DATA=>DATA_TO_MOD_SIGNAL);
			
Pack : P_Generator port map(
		CLK=>TEST_CLK_50,
		GEN_PACKET=>GEN_PACKET_SIGNAL,
		RTS_OR_DATA=>RTS_OR_DATA_SIGNAL,
		NEXT_FREQ=>NEXT_FREQ_SIGNAL,
		DATA_IN=>DATA_SIGNAL,
		SEND_COMPLETE=>SEND_COMPLETE_SIGNAL,
		DATA_OUT=>PACKET_SIGNAL,
		PACKET_READY=>PACKET_READY_SIGNAL);
		
R_Sim : Receiver_Sim port map(
		CLK=>TEST_CLK_50,
		ack=>ACK_SIGNAL,
		clr_ack=>CLR_ACK_SIGNAL,
		buffer_not_empty=>BUFF_NOT_EMPTY_SIGNAL,
		increment_buffer=>DATA_SENT_SIGNAL,
		data_out=>DATA_SIGNAL,
		send_complete=>SEND_COMPLETE_SIGNAL);
		
Carrier : carrier_gen port map(
	clk=>TEST_CLK_50,
	sel=>FREQ_SELECT_SIGNAL,
	raw_out=>CARRIER_SIGNAL);

Modul : Modulator port map(
	IDLE=>MOD_IDLE_SIGNAL,
	DATA=>DATA_TO_MOD_SIGNAL,
	CARRIER=>CARRIER_SIGNAL,
	DATA_OUT=>DAC_SIGNAL);

process(TEST_CLK_50 )
begin
TEST_CLK_50 <= not TEST_CLK_50 after 10 ns;
end process;



end A;
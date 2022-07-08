
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Main_Controller is
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
end Main_Controller;

architecture A of Main_Controller is 

	type STATE is (IDLE, SEND_RTS, WAIT_ACK, SEND_DATA);
	signal CURR_STATE : STATE := IDLE;
	signal DATA_FREQ : STD_LOGIC_VECTOR(1 downto 0);
	signal RAND_OUT : STD_LOGIC_VECTOR(7 downto 0);
	
	component LSFR_8 
			port(CLK : in STD_LOGIC;
			R_OUT : out STD_LOGIC_VECTOR(7 downto 0)
			);
	end component;
	
	
	
	procedure Rand_Freq(LSFR_IN : in STD_LOGIC_VECTOR(7 downto 0); FREQ : out STD_LOGIC_VECTOR(1 downto 0)) is
	variable A : integer;
	begin
		A := (to_integer(unsigned(LSFR_IN)) mod 3) ; -- Returns value 1-3 for selecting DATA_FREQ
		FREQ := STD_LOGIC_VECTOR(to_unsigned(A + 1, 2));
		
	end procedure;
	
begin
	
	LSFR_1 : LSFR_8 port map(CLK=>CLK,R_OUT=>RAND_OUT);


	process(CLK)
	variable ACk_WAIT_COUNT : unsigned(23 downto 0) := X"000000";
	variable RESENT : STD_LOGIC := '0'; -- Whether a resend of an RTS was already attempted
	variable R_FREQ : STD_LOGIC_VECTOR(1 downto 0);
	begin
		if rising_edge(CLK) then
		
		case CURR_STATE is
		
		when IDLE =>
			GEN_PACKET <= '0';
			CLR_ACK <= '0';
			SEND_CONTROLLER_RESET <= '1';
			DATA_SENT <= '0';
			RESENT := '0';
			if BUFF_NOT_EMPTY = '1' then
				CURR_STATE <= SEND_RTS;
				Rand_Freq(RAND_OUT, R_FREQ); -- Generate Data Packet Freq
				DATA_FREQ <= R_FREQ;
			else
				null;
			end if;
		
		when SEND_RTS =>
			SEND_CONTROLLER_RESET <= '0';
			if SEND_COMPLETE = '1' then
				CURR_STATE <= WAIT_ACK;
				GEN_PACKET <= '0';
				RTS_OR_DATA <= '0';
			else
				FREQ_SELECT <= "00"; -- All RTS sent on FREQ(0)
				NEXT_FREQ <= DATA_FREQ; -- FREQ to be hopped to for data included in packet
				GEN_PACKET <= '1';
				RTS_OR_DATA <= '0'; -- '0' = RTS packet
			end if;
		
		
		when WAIT_ACK =>
			SEND_CONTROLLER_RESET <= '1';
			if ACK = '1' then
				ACK_WAIT_COUNT:= X"000000";
				CLR_ACK <= '1';
				CURR_STATE <= SEND_DATA;
				
			else
				if ACK_WAIT_COUNT >= X"07A11F" then -- timeout set for 500,000 cycles(10 ms)
					if RESENT = '1' then
						CURR_STATE <= IDLE; -- A resend attempt has already been made with no response, receiver is unreachable, returning to idle.
						ACK_WAIT_COUNT:= X"000000";
					else
						CURR_STATE <= SEND_RTS; -- Attempt Resend RTS
						ACK_WAIT_COUNT:= X"000000";
					end if;
				else
					ACK_WAIT_COUNT:= ACK_WAIT_COUNT + X"000001";
				end if;
			end if;
			
		
		when SEND_DATA =>
			CLR_ACK <= '0';
			SEND_CONTROLLER_RESET <= '0';
			if SEND_COMPLETE = '1' then
				CURR_STATE <= IDLE;
				DATA_SENT <= '1';
				GEN_PACKET <= '0';
			else
				FREQ_SELECT <= DATA_FREQ; -- Sets carrier to selected freq for data packet
				NEXT_FREQ <= "00"; -- Sets freq to be included in packet to RTS freq
				GEN_PACKET <= '1';
				RTS_OR_DATA <= '1'; -- Sets packet to be a data packet
			
			end if;
		when others =>
			null;
		
		end case;
		
		

	end if;
	end process;
	

end A;

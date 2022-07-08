library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity carrier_gen is
port ( clk : in std_logic;
	sel : in std_logic_vector (1 downto 0);
	raw_out : out std_logic_vector (7 downto 0)
	);
end entity carrier_gen;

architecture behavioral of carrier_gen is

	type states is (START, COUNT_UP, COUNT_DOWN);
	signal current_state : states := START;
	signal temp : std_logic := '0'; -- output clk
	signal current_out : std_logic_vector (7 downto 0) := "01111111";

begin

	clock_divider : process (clk, sel) 

	variable count_508 : integer range 0 to 49 := 0;
	variable count_1016 : integer range 0 to 24 := 0;
	variable count_1524 : integer range 0 to 16 := 0;
	variable count_2032 : integer range 0 to 12 := 0;

	begin
	if sel = "00" then
		if (clk'event and clk = '1') then
			if (count_508 = 49 ) then 
				temp <= not(temp);
				count_508 := 0;
			else
				count_508 := count_508 +1;
			end if;
		end if;
	
	elsif sel = "01" then 
		if (clk'event and clk = '1') then
			if (count_1016 = 24) then 
				temp <= not(temp);
				count_1016 := 0;
			else
				count_1016 := count_1016 + 1;
			end if;
		end if;

	elsif sel = "10" then 
		if (clk'event and clk = '1') then
			if (count_1524 = 16) then
				temp <= not(temp);
				count_1524 := 0;
			else
				count_1524 := count_1524 + 1;
			end if;
		end if;

	elsif sel = "11" then 
		if (clk'event and clk = '1') then
			if (count_2032 = 12) then
				temp <= not(temp);
				count_2032 := 0;
			else
				count_2032 := count_2032 + 1;
			end if;
		end if;
	else
		-- Do nothing
	end if;
	end process;

	generate_output : process (temp)
	begin

	case current_state is
		when START =>
			--current_out <= "01111111";
			current_state <= COUNT_UP;
		when COUNT_UP =>
			if current_out >= "11111111" then
				current_out <= std_logic_vector(unsigned(current_out) - 1);
				current_state <= COUNT_DOWN;
			else
				current_out <= std_logic_vector(unsigned(current_out) + 1);
			end if;
		when COUNT_DOWN =>
			if current_out <= "00000000" then
				current_out <= std_logic_vector(unsigned(current_out) + 1);
				current_state <= COUNT_UP;
			else
				current_out <= std_logic_vector(unsigned(current_out) - 1);
			end if;	
		end case;
	end process;
	
	-- set entity output to output signal value
	raw_out <= current_out;

end architecture behavioral;






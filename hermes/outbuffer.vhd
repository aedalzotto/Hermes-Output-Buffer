library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.HermesPackage.all;

entity outbuffer is
	port(
		clock:	in	std_logic;
		reset:	in	std_logic;

		-- Write to buffer
		clock_rx:	in	std_logic;
		rx:			in	std_logic;
		data_in:	in 	regflit;
		credit_o:	out	std_logic;

		-- Read from buffer
		data_out:	out regflit;
		data_av:	out std_logic;
		data_ack:	in	std_logic
	);
end entity;

architecture rtl of outbuffer is
	signal buf: buff := (others=>(others=>'0'));
	signal read_pointer, write_pointer: pointer;

begin
	-- If fifo isn't empty, credit is high. Else, low
	credit_o <= '1' when write_pointer /= read_pointer else '0';

	--! Buffer write process
	process(reset, clock)
	begin
		if reset='1' then
			write_pointer <= (others => '0');
		elsif rising_edge(clock) then
			-- if receiving data and fifo isn't empty, record data on fifo and increase write pointer
			if rx = '1' and write_pointer /= read_pointer then
				buf(CONV_INTEGER(write_pointer)) <= data_in;
				write_pointer <= write_pointer + 1;
			end if;
		end if;
	end process;


	data_out <= buf(CONV_INTEGER(read_pointer));
	data_av <= '1' when read_pointer /= write_pointer else '0';

	--! Buffer read process
	process(reset, clock)
	begin
		if reset = '1' then
			-- Initialize the read pointer with one position before the write pointer
			read_pointer <= (others => '1');
		elsif rising_edge(clock) then
			if data_ack = '1' then
				read_pointer <= read_pointer + 1;
			end if;
		end if;
	end process;
	
end architecture;
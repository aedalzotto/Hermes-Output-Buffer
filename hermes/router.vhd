--
--! @file router.vhd
--! @brief Hermes NoC input router block for output buffers
--! @details The router block is the block to interact with the input. It will
--! receive flits and route them to the appropriate output buffer with the 
--! standard Hermes input port signals using XY routing algorithm.
--! @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
--! @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
--! @date 2020/04
-- 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.HermesPackage.all;

entity router is
	generic(
		-- Routing Control
		address:	regmetadeflit	:= x"00"
	);
	port(
		clock:	in	std_logic;
		reset:	in	std_logic;
		
		-- To/from output port
		clock_rx:	in	std_logic;
		rx:			in	std_logic;
		data_in:	in	regflit;
		credit_o:	out	std_logic;

		-- To/from buffers
		credit_i:	in	regNport;
		tx:			out regNport
	);
end entity;

architecture rtl of router is

	type	state is (S_INIT, S_SENDHEADER, S_PKTSIZE, S_PAYLOAD);
	signal	active_state:	state;

	signal	target_x, target_y:	regquartoflit;

	signal	target:		integer;
	signal	target_set:	std_logic;

	-- Flow control
	signal	flit_counter:	regflit;

	-- Local address for routing
	constant	local_x:	regquartoflit	:=	address((METADEFLIT - 1) downto QUARTOFLIT);
	constant	local_y:	regquartoflit	:=	address((QUARTOFLIT - 1) downto 0);

begin

	-- Target address for routing
	target_x <= data_in((METADEFLIT - 1) downto QUARTOFLIT);
	target_y <= data_in((QUARTOFLIT - 1) downto 0);

	-- Output buffer muxing
	credit_o <= credit_i(target) when target_set = '1' else '1';
	tx(LOCAL) <= rx when target = LOCAL and target_set = '1' else '0';
	tx(NORTH) <= rx when target = NORTH and target_set = '1' else '0';
	tx(SOUTH) <= rx when target = SOUTH and target_set = '1' else '0';
	tx(EAST) <= rx when target = EAST and target_set = '1' else '0';
	tx(WEST) <= rx when target = WEST and target_set = '1' else '0';

	process(reset, clock)
	begin
		if reset = '1' then
			target_set <= '0';
			active_state <= S_INIT;
		elsif rising_edge(clock) then
			case active_state is
				when S_INIT =>
					-- Receiving data
					if(rx = '1') then
						-- Next state will be the header bufferization + payload size
						active_state <= S_SENDHEADER;

						-- Routing algorithm (XY)
						if local_x = target_x and local_y = target_y then -- Target is local, route to LOCAL
							target <= LOCAL;

						elsif local_x /= target_x then -- Need to route in X
							if target_x > local_x then
								target <= EAST;
							else
								target <= WEST;
							end if;

						elsif local_y /= target_y then -- Already in X, route in Y
							if target_y > local_y then
								target <= NORTH;
							else
								target <= SOUTH;
							end if;

						else
							-- Could not process header, stay in INIT state and retry receiving flit.
							active_state <= S_INIT;
						end if;

					end if;
				
				when S_SENDHEADER =>
					target_set <= '1';

					-- Only send if buffer is not full.
					if credit_i(target) = '1' then
						active_state <= S_PKTSIZE;
					end if;

				when S_PKTSIZE =>
					-- Load the payload size to the counter to know when to reroute
					if rx = '1' then
						flit_counter <= data_in;
						active_state <= S_PAYLOAD;
					end if;
				
				when S_PAYLOAD =>
					if flit_counter = x"0" then
						target_set <= '0';
						active_state <= S_INIT;
					elsif credit_i(target) = '1' then
						flit_counter <= flit_counter - 1;
					end if;

			end case;
		end if;
	end process;

end architecture;
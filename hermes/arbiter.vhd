--
--! @file arbiter.vhd
--! @brief Hermes NoC output arbiter block for output buffers
--! @details .
--! @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
--! @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
--! @date 2020/04
-- 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.HermesPackage.all;

entity arbiter is
	port(
		clock:	in	std_logic;
		reset:	in	std_logic;

		-- Next node interface
		data_out:	out	regflit;
		tx:			out	std_logic;
		credit_i:	in	std_logic;

		-- Buffers interface
		data_in:	in	arrayNport_regflit;
		data_av:	in	regNport;
		data_ack:	out	regNport
	);
end entity;

architecture rtl of arbiter is
	type state is (S_INIT, S_SENDHEADER, S_PKTSIZE, S_PAYLOAD);
	signal	active_state:	state;

	signal last:	integer;
	signal target:	integer;
	signal target_set:	std_logic;

	signal flit_counter:	regflit;
begin

	data_out <= (others => '0') when target_set = '0' else
				data_in(EAST) when target = EAST else
				data_in(WEST) when target = WEST else
				data_in(NORTH) when target = NORTH else
				data_in(SOUTH) when target = SOUTH else
				data_in(LOCAL) when target = LOCAL else
				(others => '0');

	tx <= 	'0' when target_set = '0' else
			data_av(EAST) when target = EAST else
			data_av(WEST) when target = WEST else
			data_av(NORTH) when target = NORTH else
			data_av(SOUTH) when target = SOUTH else
			data_av(LOCAL) when target = LOCAL else
			'0';

	data_ack(EAST) <= credit_i when target_set = '1' and target = EAST else '0';
	data_ack(WEST) <= credit_i when target_set = '1' and target = WEST else '0';
	data_ack(NORTH) <= credit_i when target_set = '1' and target = NORTH else '0';
	data_ack(SOUTH) <= credit_i when target_set = '1' and target = SOUTH else '0';
	data_ack(LOCAL) <= credit_i when target_set = '1' and target = LOCAL else '0';

	process(reset, clock)
	begin
		if reset = '1' then
			-- East starts with lowest priority
			last <= EAST;
			target_set <= '0';
			active_state <= S_INIT;
		elsif rising_edge(clock) then
			case active_state is
				when S_INIT =>
					-- Check if any buffer has data
					if	data_av(EAST) = '1' or data_av(WEST) = '1' or 
						data_av(NORTH) = '1' or	data_av(SOUTH) = '1' or 
													data_av(LOCAL) = '1' then

						-- Perform RR algorithm from output buffers
						case last is
							when EAST =>
								if data_av(WEST) = '1' then target <= WEST;
								elsif data_av(NORTH) = '1' then target <= NORTH;
								elsif data_av(SOUTH) = '1' then target <= SOUTH;
								elsif data_av(LOCAL) = '1' then target <= LOCAL;
								else target <= EAST;
								end if;
							when WEST =>
								if data_av(NORTH) = '1' then target <= NORTH;
								elsif data_av(SOUTH) = '1' then target <= SOUTH;
								elsif data_av(LOCAL) = '1' then target <= LOCAL;
								elsif data_av(EAST) = '1' then target <= EAST;
								else target <= WEST;
								end if;
							when NORTH =>
								if data_av(SOUTH) = '1' then target <= SOUTH;
								elsif data_av(LOCAL) = '1' then target <= LOCAL;
								elsif data_av(EAST) = '1' then target <= EAST;
								elsif data_av(WEST) = '1' then target <= WEST;
								else target <= NORTH;
								end if;
							when SOUTH =>
								if data_av(LOCAL) = '1' then target <= LOCAL;
								elsif data_av(EAST) = '1' then target <= EAST;
								elsif data_av(WEST) = '1' then target <= WEST;
								elsif data_av(NORTH) = '1' then target <= NORTH;
								else target <= SOUTH;
								end if;
							when others =>
								if data_av(EAST) = '1' then target <= EAST;
								elsif data_av(WEST) = '1' then target <= WEST;
								elsif data_av(NORTH) = '1' then target <= NORTH;
								elsif data_av(SOUTH) = '1' then target <= SOUTH;
								else target <= LOCAL;
								end if;
						end case;
						
						last <= target;
						target_set <= '1';
						active_state <= S_SENDHEADER;
					end if;

				when S_SENDHEADER =>
					-- Wait for first flit transmission (address)
					if credit_i = '1' and data_av(target) = '1' then
						active_state <= S_PKTSIZE;
					end if;

				when S_PKTSIZE =>
					-- Wait for segund flit transmission (flit count)
					-- Save for flow control
					if data_av(target) = '1' and credit_i = '1' then
						flit_counter <= data_in(target);
						active_state <= S_PAYLOAD;
					end if;

				when S_PAYLOAD =>
					if flit_counter = x"0" then
						-- End of packet
						target_set <= '0';
						active_state <= S_INIT;
					elsif credit_i = '1' and data_av(target) = '1' then
						flit_counter <= flit_counter - 1;
					end if;

			end case;
		end if;
	end process;
end architecture;
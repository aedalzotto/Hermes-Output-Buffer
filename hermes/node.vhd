library ieee;
use ieee.std_logic_1164.all;
use work.HermesPackage.all;

entity node is
	generic(
		address: regmetadeflit := x"00"
	);
	port(
		clock:	in	std_logic;
		reset:	in	std_logic;

		clock_rx:	in	regNport;
		rx:			in	regNport;
		data_in:	in	arrayNport_regflit;
		credit_o:	out	regNport;

		--! @todo These should be connected to arbiter
		data_out:	out array_buffer;
		data_ack:	in	port_buffer;
		data_av:	out	port_buffer
	);
end entity;

architecture rtl of node is
	signal tx_buffers:	port_buffer;
	signal credit_buffers: port_buffer;
begin
	
	E_router: entity work.router
	port map(
		clock => clock,
		reset => reset,
		
		-- Routing control
		address => address,

		-- To/from output port
		clock_rx => clock,
		rx => rx(EAST),
		data_in => data_in(EAST),
		credit_o => credit_o(EAST),

		-- To/from buffer
		credit_i => credit_buffers(EAST),
		tx => tx_buffers(EAST)
	);

	EE_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(EAST)(EAST),
		data_in => data_in(EAST),
		credit_o => credit_buffers(EAST)(EAST),

		data_out => data_out(EAST)(EAST),
		data_av => data_av(EAST)(EAST),
		data_ack => data_ack(EAST)(EAST)
	);

	EW_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(EAST)(WEST),
		data_in => data_in(EAST),
		credit_o => credit_buffers(EAST)(WEST),

		data_out => data_out(EAST)(WEST),
		data_av => data_av(EAST)(WEST),
		data_ack => data_ack(EAST)(WEST)
	);

	EN_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(EAST)(NORTH),
		data_in => data_in(EAST),
		credit_o => credit_buffers(EAST)(NORTH),

		data_out => data_out(EAST)(NORTH),
		data_av => data_av(EAST)(NORTH),
		data_ack => data_ack(EAST)(NORTH)
	);

	ES_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(EAST)(SOUTH),
		data_in => data_in(EAST),
		credit_o => credit_buffers(EAST)(SOUTH),

		data_out => data_out(EAST)(SOUTH),
		data_av => data_av(EAST)(SOUTH),
		data_ack => data_ack(EAST)(SOUTH)
	);

	EL_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(EAST)(LOCAL),
		data_in => data_in(EAST),
		credit_o => credit_buffers(EAST)(LOCAL),

		data_out => data_out(EAST)(LOCAL),
		data_av => data_av(EAST)(LOCAL),
		data_ack => data_ack(EAST)(LOCAL)
	);

	W_router: entity work.router
	port map(
		clock => clock,
		reset => reset,
		
		-- Routing control
		address => address,

		-- To/from output port
		clock_rx => clock,
		rx => rx(WEST),
		data_in => data_in(WEST),
		credit_o => credit_o(WEST),

		-- To/from buffer
		credit_i => credit_buffers(WEST),
		tx => tx_buffers(WEST)
	);

	WE_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(WEST)(EAST),
		data_in => data_in(WEST),
		credit_o => credit_buffers(WEST)(EAST),

		data_out => data_out(WEST)(EAST),
		data_av => data_av(WEST)(EAST),
		data_ack => data_ack(WEST)(EAST)
	);

	WW_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(WEST)(WEST),
		data_in => data_in(WEST),
		credit_o => credit_buffers(WEST)(WEST),

		data_out => data_out(WEST)(WEST),
		data_av => data_av(WEST)(WEST),
		data_ack => data_ack(WEST)(WEST)
	);

	WN_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(WEST)(NORTH),
		data_in => data_in(WEST),
		credit_o => credit_buffers(WEST)(NORTH),

		data_out => data_out(WEST)(NORTH),
		data_av => data_av(WEST)(NORTH),
		data_ack => data_ack(WEST)(NORTH)
	);

	WS_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(WEST)(SOUTH),
		data_in => data_in(WEST),
		credit_o => credit_buffers(WEST)(SOUTH),

		data_out => data_out(WEST)(SOUTH),
		data_av => data_av(WEST)(SOUTH),
		data_ack => data_ack(WEST)(SOUTH)
	);

	WL_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(WEST)(LOCAL),
		data_in => data_in(WEST),
		credit_o => credit_buffers(WEST)(LOCAL),

		data_out => data_out(WEST)(LOCAL),
		data_av => data_av(WEST)(LOCAL),
		data_ack => data_ack(WEST)(LOCAL)
	);

	N_router: entity work.router
	port map(
		clock => clock,
		reset => reset,
		
		-- Routing control
		address => address,

		-- To/from output port
		clock_rx => clock,
		rx => rx(NORTH),
		data_in => data_in(NORTH),
		credit_o => credit_o(NORTH),

		-- To/from buffer
		credit_i => credit_buffers(NORTH),
		tx => tx_buffers(NORTH)
	);

	NE_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(NORTH)(EAST),
		data_in => data_in(NORTH),
		credit_o => credit_buffers(NORTH)(EAST),

		data_out => data_out(NORTH)(EAST),
		data_av => data_av(NORTH)(EAST),
		data_ack => data_ack(NORTH)(EAST)
	);

	NW_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(NORTH)(WEST),
		data_in => data_in(NORTH),
		credit_o => credit_buffers(NORTH)(WEST),

		data_out => data_out(NORTH)(WEST),
		data_av => data_av(NORTH)(WEST),
		data_ack => data_ack(NORTH)(WEST)
	);

	NN_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(NORTH)(NORTH),
		data_in => data_in(NORTH),
		credit_o => credit_buffers(NORTH)(NORTH),

		data_out => data_out(NORTH)(NORTH),
		data_av => data_av(NORTH)(NORTH),
		data_ack => data_ack(NORTH)(NORTH)
	);

	NS_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(NORTH)(SOUTH),
		data_in => data_in(NORTH),
		credit_o => credit_buffers(NORTH)(SOUTH),

		data_out => data_out(NORTH)(SOUTH),
		data_av => data_av(NORTH)(SOUTH),
		data_ack => data_ack(NORTH)(SOUTH)
	);

	NL_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(NORTH)(LOCAL),
		data_in => data_in(NORTH),
		credit_o => credit_buffers(NORTH)(LOCAL),

		data_out => data_out(NORTH)(LOCAL),
		data_av => data_av(NORTH)(LOCAL),
		data_ack => data_ack(NORTH)(LOCAL)
	);

	S_router: entity work.router
	port map(
		clock => clock,
		reset => reset,
		
		-- Routing control
		address => address,

		-- To/from output port
		clock_rx => clock,
		rx => rx(SOUTH),
		data_in => data_in(SOUTH),
		credit_o => credit_o(SOUTH),

		-- To/from buffer
		credit_i => credit_buffers(SOUTH),
		tx => tx_buffers(SOUTH)
	);

	SE_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(SOUTH)(EAST),
		data_in => data_in(SOUTH),
		credit_o => credit_buffers(SOUTH)(EAST),

		data_out => data_out(SOUTH)(EAST),
		data_av => data_av(SOUTH)(EAST),
		data_ack => data_ack(SOUTH)(EAST)
	);

	SW_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(SOUTH)(WEST),
		data_in => data_in(SOUTH),
		credit_o => credit_buffers(SOUTH)(WEST),

		data_out => data_out(SOUTH)(WEST),
		data_av => data_av(SOUTH)(WEST),
		data_ack => data_ack(SOUTH)(WEST)
	);

	SN_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(SOUTH)(NORTH),
		data_in => data_in(SOUTH),
		credit_o => credit_buffers(SOUTH)(NORTH),

		data_out => data_out(SOUTH)(NORTH),
		data_av => data_av(SOUTH)(NORTH),
		data_ack => data_ack(SOUTH)(NORTH)
	);

	SS_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(SOUTH)(SOUTH),
		data_in => data_in(SOUTH),
		credit_o => credit_buffers(SOUTH)(SOUTH),

		data_out => data_out(SOUTH)(SOUTH),
		data_av => data_av(SOUTH)(SOUTH),
		data_ack => data_ack(SOUTH)(SOUTH)
	);

	SL_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(SOUTH)(LOCAL),
		data_in => data_in(SOUTH),
		credit_o => credit_buffers(SOUTH)(LOCAL),

		data_out => data_out(SOUTH)(LOCAL),
		data_av => data_av(SOUTH)(LOCAL),
		data_ack => data_ack(SOUTH)(LOCAL)
	);

	L_router: entity work.router
	port map(
		clock => clock,
		reset => reset,
		
		-- Routing control
		address => address,

		-- To/from output port
		clock_rx => clock,
		rx => rx(LOCAL),
		data_in => data_in(LOCAL),
		credit_o => credit_o(LOCAL),

		-- To/from buffer
		credit_i => credit_buffers(LOCAL),
		tx => tx_buffers(LOCAL)
	);

	LE_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(LOCAL)(EAST),
		data_in => data_in(LOCAL),
		credit_o => credit_buffers(LOCAL)(EAST),

		data_out => data_out(LOCAL)(EAST),
		data_av => data_av(LOCAL)(EAST),
		data_ack => data_ack(LOCAL)(EAST)
	);

	LW_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(LOCAL)(WEST),
		data_in => data_in(LOCAL),
		credit_o => credit_buffers(LOCAL)(WEST),

		data_out => data_out(LOCAL)(WEST),
		data_av => data_av(LOCAL)(WEST),
		data_ack => data_ack(LOCAL)(WEST)
	);

	LN_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(LOCAL)(NORTH),
		data_in => data_in(LOCAL),
		credit_o => credit_buffers(LOCAL)(NORTH),

		data_out => data_out(LOCAL)(NORTH),
		data_av => data_av(LOCAL)(NORTH),
		data_ack => data_ack(LOCAL)(NORTH)
	);

	LS_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(LOCAL)(SOUTH),
		data_in => data_in(LOCAL),
		credit_o => credit_buffers(LOCAL)(SOUTH),

		data_out => data_out(LOCAL)(SOUTH),
		data_av => data_av(LOCAL)(SOUTH),
		data_ack => data_ack(LOCAL)(SOUTH)
	);

	LL_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(LOCAL)(LOCAL),
		data_in => data_in(LOCAL),
		credit_o => credit_buffers(LOCAL)(LOCAL),

		data_out => data_out(LOCAL)(LOCAL),
		data_av => data_av(LOCAL)(LOCAL),
		data_ack => data_ack(LOCAL)(LOCAL)
	);

end architecture;
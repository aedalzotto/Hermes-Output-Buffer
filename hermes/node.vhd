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

		--! Input ports
		clock_rx:	in	regNport;
		rx:			in	regNport;
		data_in:	in	arrayNport_regflit;
		credit_o:	out	regNport;

		--! Output ports
		data_out:	out arrayNport_regflit;
		credit_i:	in	regNport;
		tx:			out	regNport
	);
end entity;

architecture rtl of node is
	type array_buffer is array((NPORT-1) downto 0) of arrayNport_regflit;
	type port_buffer is array((NPORT-1) downto 0) of regNport;

	signal tx_buffers:	port_buffer;
	signal credit_buffers: port_buffer;

	signal av_buffer:	port_buffer;
	signal ack_buffer: port_buffer;

	signal data_buffer:	array_buffer;

begin
	E_arbiter: entity work.arbiter
	port map(
		clock => clock,
		reset => reset, 

		-- Next node interface
		data_out => data_out(EAST),
		tx => tx(EAST),
		credit_i => credit_i(EAST),

		-- Buffers interface
		data_in => data_buffer(EAST),
		data_av => av_buffer(EAST),
		data_ack => ack_buffer(EAST)
	);
	
	E_router: entity work.router
	port map(
		clock => clock,
		reset => reset,

		-- Read from output port signals
		clock_rx => clock,
		rx => rx(EAST),
		data_in => data_in(EAST),
		credit_o => credit_o(EAST),

		-- Write to buffer signals
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

		data_out => data_buffer(EAST)(EAST),
		data_av => av_buffer(EAST)(EAST),
		data_ack => ack_buffer(EAST)(EAST)
	);

	EW_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(EAST)(WEST),
		data_in => data_in(EAST),
		credit_o => credit_buffers(EAST)(WEST),

		data_out => data_buffer(WEST)(EAST),
		data_av => av_buffer(WEST)(EAST),
		data_ack => ack_buffer(WEST)(EAST)
	);

	EN_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(EAST)(NORTH),
		data_in => data_in(EAST),
		credit_o => credit_buffers(EAST)(NORTH),

		data_out => data_buffer(NORTH)(EAST),
		data_av => av_buffer(NORTH)(EAST),
		data_ack => ack_buffer(NORTH)(EAST)
	);

	ES_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(EAST)(SOUTH),
		data_in => data_in(EAST),
		credit_o => credit_buffers(EAST)(SOUTH),

		data_out => data_buffer(SOUTH)(EAST),
		data_av => av_buffer(SOUTH)(EAST),
		data_ack => ack_buffer(SOUTH)(EAST)
	);

	EL_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(EAST)(LOCAL),
		data_in => data_in(EAST),
		credit_o => credit_buffers(EAST)(LOCAL),

		data_out => data_buffer(LOCAL)(EAST),
		data_av => av_buffer(LOCAL)(EAST),
		data_ack => ack_buffer(LOCAL)(EAST)
	);

	W_arbiter: entity work.arbiter
	port map(
		clock => clock,
		reset => reset, 

		-- Next node interface
		data_out => data_out(WEST),
		tx => tx(WEST),
		credit_i => credit_i(WEST),

		-- Buffers interface
		data_in => data_buffer(WEST),
		data_av => av_buffer(WEST),
		data_ack => ack_buffer(WEST)
	);

	W_router: entity work.router
	port map(
		clock => clock,
		reset => reset,

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

		data_out => data_buffer(EAST)(WEST),
		data_av => av_buffer(EAST)(WEST),
		data_ack => ack_buffer(EAST)(WEST)
	);

	WW_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(WEST)(WEST),
		data_in => data_in(WEST),
		credit_o => credit_buffers(WEST)(WEST),

		data_out => data_buffer(WEST)(WEST),
		data_av => av_buffer(WEST)(WEST),
		data_ack => ack_buffer(WEST)(WEST)
	);

	WN_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(WEST)(NORTH),
		data_in => data_in(WEST),
		credit_o => credit_buffers(WEST)(NORTH),

		data_out => data_buffer(NORTH)(WEST),
		data_av => av_buffer(NORTH)(WEST),
		data_ack => ack_buffer(NORTH)(WEST)
	);

	WS_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(WEST)(SOUTH),
		data_in => data_in(WEST),
		credit_o => credit_buffers(WEST)(SOUTH),

		data_out => data_buffer(SOUTH)(WEST),
		data_av => av_buffer(SOUTH)(WEST),
		data_ack => ack_buffer(SOUTH)(WEST)
	);

	WL_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(WEST)(LOCAL),
		data_in => data_in(WEST),
		credit_o => credit_buffers(WEST)(LOCAL),

		data_out => data_buffer(LOCAL)(WEST),
		data_av => av_buffer(LOCAL)(WEST),
		data_ack => ack_buffer(LOCAL)(WEST)
	);

	N_arbiter: entity work.arbiter
	port map(
		clock => clock,
		reset => reset, 

		-- Next node interface
		data_out => data_out(NORTH),
		tx => tx(NORTH),
		credit_i => credit_i(NORTH),

		-- Buffers interface
		data_in => data_buffer(NORTH),
		data_av => av_buffer(NORTH),
		data_ack => ack_buffer(NORTH)
	);

	N_router: entity work.router
	port map(
		clock => clock,
		reset => reset,
		
		-- Routing control
		 

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

		data_out => data_buffer(EAST)(NORTH),
		data_av => av_buffer(EAST)(NORTH),
		data_ack => ack_buffer(EAST)(NORTH)
	);

	NW_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(NORTH)(WEST),
		data_in => data_in(NORTH),
		credit_o => credit_buffers(NORTH)(WEST),

		data_out => data_buffer(WEST)(NORTH),
		data_av => av_buffer(WEST)(NORTH),
		data_ack => ack_buffer(WEST)(NORTH)
	);

	NN_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(NORTH)(NORTH),
		data_in => data_in(NORTH),
		credit_o => credit_buffers(NORTH)(NORTH),

		data_out => data_buffer(NORTH)(NORTH),
		data_av => av_buffer(NORTH)(NORTH),
		data_ack => ack_buffer(NORTH)(NORTH)
	);

	NS_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(NORTH)(SOUTH),
		data_in => data_in(NORTH),
		credit_o => credit_buffers(NORTH)(SOUTH),

		data_out => data_buffer(SOUTH)(NORTH),
		data_av => av_buffer(SOUTH)(NORTH),
		data_ack => ack_buffer(SOUTH)(NORTH)
	);

	NL_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(NORTH)(LOCAL),
		data_in => data_in(NORTH),
		credit_o => credit_buffers(NORTH)(LOCAL),

		data_out => data_buffer(LOCAL)(NORTH),
		data_av => av_buffer(LOCAL)(NORTH),
		data_ack => ack_buffer(LOCAL)(NORTH)
	);

	S_arbiter: entity work.arbiter
	port map(
		clock => clock,
		reset => reset, 

		-- Next node interface
		data_out => data_out(SOUTH),
		tx => tx(SOUTH),
		credit_i => credit_i(SOUTH),

		-- Buffers interface
		data_in => data_buffer(SOUTH),
		data_av => av_buffer(SOUTH),
		data_ack => ack_buffer(SOUTH)
	);

	S_router: entity work.router
	port map(
		clock => clock,
		reset => reset,
		
		-- Routing control
		 

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

		data_out => data_buffer(EAST)(SOUTH),
		data_av => av_buffer(EAST)(SOUTH),
		data_ack => ack_buffer(EAST)(SOUTH)
	);

	SW_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(SOUTH)(WEST),
		data_in => data_in(SOUTH),
		credit_o => credit_buffers(SOUTH)(WEST),

		data_out => data_buffer(WEST)(SOUTH),
		data_av => av_buffer(WEST)(SOUTH),
		data_ack => ack_buffer(WEST)(SOUTH)
	);

	SN_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(SOUTH)(NORTH),
		data_in => data_in(SOUTH),
		credit_o => credit_buffers(SOUTH)(NORTH),

		data_out => data_buffer(NORTH)(SOUTH),
		data_av => av_buffer(NORTH)(SOUTH),
		data_ack => ack_buffer(NORTH)(SOUTH)
	);

	SS_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(SOUTH)(SOUTH),
		data_in => data_in(SOUTH),
		credit_o => credit_buffers(SOUTH)(SOUTH),

		data_out => data_buffer(SOUTH)(SOUTH),
		data_av => av_buffer(SOUTH)(SOUTH),
		data_ack => ack_buffer(SOUTH)(SOUTH)
	);

	SL_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(SOUTH)(LOCAL),
		data_in => data_in(SOUTH),
		credit_o => credit_buffers(SOUTH)(LOCAL),

		data_out => data_buffer(LOCAL)(SOUTH),
		data_av => av_buffer(LOCAL)(SOUTH),
		data_ack => ack_buffer(LOCAL)(SOUTH)
	);

	L_arbiter: entity work.arbiter
	port map(
		clock => clock,
		reset => reset, 

		-- Next node interface
		data_out => data_out(LOCAL),
		tx => tx(LOCAL),
		credit_i => credit_i(LOCAL),

		-- Buffers interface
		data_in => data_buffer(LOCAL),
		data_av => av_buffer(LOCAL),
		data_ack => ack_buffer(LOCAL)
	);

	L_router: entity work.router
	port map(
		clock => clock,
		reset => reset,
		
		-- Routing control
		 

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

		data_out => data_buffer(EAST)(LOCAL),
		data_av => av_buffer(EAST)(LOCAL),
		data_ack => ack_buffer(EAST)(LOCAL)
	);

	LW_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(LOCAL)(WEST),
		data_in => data_in(LOCAL),
		credit_o => credit_buffers(LOCAL)(WEST),

		data_out => data_buffer(WEST)(LOCAL),
		data_av => av_buffer(WEST)(LOCAL),
		data_ack => ack_buffer(WEST)(LOCAL)
	);

	LN_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(LOCAL)(NORTH),
		data_in => data_in(LOCAL),
		credit_o => credit_buffers(LOCAL)(NORTH),

		data_out => data_buffer(NORTH)(LOCAL),
		data_av => av_buffer(NORTH)(LOCAL),
		data_ack => ack_buffer(NORTH)(LOCAL)
	);

	LS_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(LOCAL)(SOUTH),
		data_in => data_in(LOCAL),
		credit_o => credit_buffers(LOCAL)(SOUTH),

		data_out => data_buffer(SOUTH)(LOCAL),
		data_av => av_buffer(SOUTH)(LOCAL),
		data_ack => ack_buffer(SOUTH)(LOCAL)
	);

	LL_buffer: entity work.outbuffer
	port map(
		clock => clock,
		reset => reset,

		clock_rx => clock,
		rx => tx_buffers(LOCAL)(LOCAL),
		data_in => data_in(LOCAL),
		credit_o => credit_buffers(LOCAL)(LOCAL),

		data_out => data_buffer(LOCAL)(LOCAL),
		data_av => av_buffer(LOCAL)(LOCAL),
		data_ack => ack_buffer(LOCAL)(LOCAL)
	);

end architecture;
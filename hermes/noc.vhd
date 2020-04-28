--
--! @file noc.vhd
--! @brief Hermes generic NoC.
--! @details Generates a NoC external interface that connects to the local ports.
--! Grounding occurs when there are no neighbor nodes.
--! @author ?
--! @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
--! @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
--! @date 2020/04
-- 

library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;
use work.standards.all;

entity noc is
	port(
		clock: in reg_node_no;
		reset: in std_logic;

		--! The external inputs are only for local ports
		clock_rx_local:	in	reg_node_no;
		rx_local:		in	reg_node_no;
		data_in_local:	in	node_no_reg_flit_size;
		credit_o_local: out	reg_node_no;

		--! The external outputs are only for local ports
		clock_tx_local:	out	reg_node_no;
		tx_local:		out	reg_node_no;
		data_out_local:	out	node_no_reg_flit_size;
		credit_i_local:	in	reg_node_no
	);
end entity;

architecture rtl of noc is
	--! Control and data signals for all ports from all nodes
	signal clock_tx: 	node_no_reg_port_no;
	signal tx:			node_no_reg_port_no;
	signal data_out:	node_no_port_no_reg_flit_size;
	signal credit_i:	node_no_reg_port_no;

	signal clock_rx:	node_no_reg_port_no;
	signal rx:			node_no_reg_port_no;
	signal data_in:		node_no_port_no_reg_flit_size;
	signal credit_o:	node_no_reg_port_no;

	signal sc_tx, sc_credit_i: sc_node_no_reg_port_no;
	signal sc_data_out:	sc_node_no_port_no_reg_flit_size;

begin

	nodes: for i in 0 to NODE_NO-1 generate

		node: entity work.node
		generic map(
			address => router_address(i)
		)
		port map(
			clock => clock(i),
			reset => reset,

			--! Input Ports
			clock_rx => clock_rx(i),
			rx => rx(i),
			data_in	=> data_in(i),
			credit_o => credit_o(i),

			--! Output ports
			clock_tx => clock_tx(i),
			tx => tx(i),
			data_out => data_out(i),
			credit_i => credit_i(i)
		);

		--! Local port connections
		--! Local input port
		clock_rx(i)(LOCAL) <= clock_rx_local(i);
		rx(i)(LOCAL) <= rx_local(i);
		data_in(i)(LOCAL) <= data_in_local(i);
		credit_o_local(i) <= credit_o(i)(LOCAL);
		--! Local output port
		clock_tx_local(i) <= clock_tx(i)(LOCAL);
		tx_local(i) <= tx(i)(LOCAL); 
		data_out_local(i) <= data_out(i)(LOCAL);						
		credit_i(i)(LOCAL) <= credit_i_local(i);

		--! Ground east port of easternmost nodes
		east_grounding: if ((i+1) mod X_SIZE) = 0 generate
			rx(i)(EAST) <= '0';
			clock_rx(i)(EAST) <= '0';
			credit_i(i)(EAST) <= '0';
			data_in(i)(EAST) <= (others => '0');
		end generate;

		--! Connect east port of not easternmost nodes
		east_connection: if ((i+1) mod X_SIZE) /= 0 generate
			rx(i)(EAST) <= tx(i+1)(WEST);
			clock_rx(i)(EAST) <= clock_tx(i+1)(WEST);
			credit_i(i)(EAST) <= credit_o(i+1)(WEST);
			data_in(i)(EAST) <= data_out(i+1)(WEST);
		end generate;

		--! Ground west port of westernmost nodes
		west_grounding: if (i mod X_SIZE) = 0 generate
			rx(i)(WEST) <= '0';
			clock_rx(i)(WEST) <= '0';
			credit_i(i)(WEST) <= '0';
			data_in(i)(WEST) <= (others => '0');
		end generate;

		--! Connect west port of not westernmost nodes
		west_connection: if (i mod X_SIZE) /= 0 generate
			rx(i)(WEST) <= tx(i-1)(EAST);
			clock_rx(i)(WEST) <= clock_tx(i-1)(EAST);
			credit_i(i)(WEST) <= credit_o(i-1)(EAST);
			data_in(i)(WEST) <= data_out(i-1)(EAST);
		end generate;

		--! Ground north port of northernmost nodes
		north_grounding: if i >= (NODE_NO-X_SIZE) generate
			rx(i)(NORTH) <= '0';
			clock_rx(i)(NORTH) <= '0';
			credit_i(i)(NORTH) <= '0';
			data_in(i)(NORTH) <= (others => '0');
		end generate;

		--! Connect north port of not northernmost nodes
		north_connection: if i < (NODE_NO-X_SIZE) generate
			rx(i)(NORTH) <= tx(i+X_SIZE)(SOUTH);
			clock_rx(i)(NORTH) <= clock_tx(i+X_SIZE)(SOUTH);
			credit_i(i)(NORTH) <= credit_o(i+X_SIZE)(SOUTH);
			data_in(i)(NORTH) <= data_out(i+X_SIZE)(SOUTH);
		end generate;

		--! Ground sourth port of southernmost nodes
		south_grounding: if i < X_SIZE generate
			rx(i)(SOUTH) <= '0';
			clock_rx(i)(SOUTH) <= '0';
			credit_i(i)(SOUTH) <= '0';
			data_in(i)(SOUTH) <= (others => '0');
		end generate;

		--! Connect south port of not southernmost nodes
		south_connection: if i >= X_SIZE generate
			rx(i)(SOUTH) <= tx(i-X_SIZE)(NORTH);
			clock_rx(i)(SOUTH) <= clock_tx(i-X_SIZE)(NORTH);
			credit_i(i)(SOUTH) <= credit_o(i-X_SIZE)(NORTH);
			data_in(i)(SOUTH) <= data_out(i-X_SIZE)(NORTH);
		end generate;

	end generate;

	--! SystemC router sniffer
	--! This binding is needed for co-simulation of array of std_logic_vector
	sc_bind: for node in 0 to NODE_NO-1 generate
		sc_bind: for router in 0 to PORT_NO-1 generate
			sc_data_out((node+router+1)*FLIT_SIZE-1 downto (node+router)*FLIT_SIZE) <= data_out(node)(router);
			sc_tx(node*PORT_NO + router) <= tx(node)(router);
			sc_credit_i(node*PORT_NO + router) <= credit_i(node)(router);
		end generate;
	end generate;

	outmodule: Entity work.RouterOutputModule
	port map(
		clock => clock(0),

		tx => sc_tx,
		data_out => sc_data_out,
		credit_i => sc_credit_i
	);

end architecture;

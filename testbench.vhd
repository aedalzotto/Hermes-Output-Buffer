--
--! @file testbench.vhd
--! @brief Hermes generic NoC testbench.
--! @details Interfaces the NoC with the packet sniffer and injector from
--! SystemC.
--! @author ?
--! @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
--! @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
--! @date 2020/04
-- 

library ieee;
use IEEE.std_logic_1164.all;
use work.standards.all;
use work.constants.all;

entity testbench is

end;

architecture behavioral of testbench is

	signal clock: reg_node_no := (others=>'1');
	signal reset: std_logic;

	--! Local input ports
	signal clock_rx: 	reg_node_no;
	signal rx:			reg_node_no;
	signal data_in:		node_no_reg_flit_size;
	signal credit_o:	reg_node_no;
	
	--! Local output ports
	signal clock_tx: 	reg_node_no;
	signal tx:			reg_node_no;
	signal data_out:	node_no_reg_flit_size;
	signal credit_i:	reg_node_no;

	signal finish:	std_logic;

	signal sc_data_out:	sc_node_no_reg_flit_size;
	signal sc_data_in:	sc_node_no_reg_flit_size;

begin
	reset <= '1', '0' after 15 ns;

	sc_bind: for i in 0 to NODE_NO-1 generate
		sc_data_out((i+1)*FLIT_SIZE-1 downto i*FLIT_SIZE) <= data_out(i);
		data_in(i) <= sc_data_in((i+1)*FLIT_SIZE-1 downto i*FLIT_SIZE);
	end generate;

	clocks: for i in 0 to NODE_NO-1 generate
		clock(i) <= not clock(i) after 10 ns;
	end generate;

	noc: Entity work.noc
	port map(
		clock => clock,
		reset => reset,

		clock_rx_local => clock_rx,
		rx_local => rx,
		data_in_local => data_in,
		credit_o_local => credit_o,

		clock_tx_local => clock_tx,
		tx_local => tx,
		data_out_local => data_out,
		credit_i_local => credit_i
	);

	outmodule: Entity work.OutputModule
	port map(
		clock => clock(0),
		finish => finish,

        tx_local => tx,
        data_in => sc_data_out,
		credit_o => credit_i
    );

	inputmodule: Entity work.InputModule
	port map(
		clock => clock(0),
		reset => reset,
		finish => finish,

		clock_tx => clock_rx,
		tx => rx,
		data_out => sc_data_in,
		credit_i => credit_o
	);

end architecture;

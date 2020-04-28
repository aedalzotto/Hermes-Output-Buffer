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

	subtype sc_node_no_reg_flit_size is std_logic_vector(NODE_NO*FLIT_SIZE - 1 downto 0);
	signal sc_data_out:	sc_node_no_reg_flit_size;

begin
	reset <= '1', '0' after 15 ns;

	sc_bind: for i in 0 to NODE_NO-1 generate
		sc_data_out((i+1)*FLIT_SIZE-1 downto i*FLIT_SIZE) <= data_out(i);
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
        clock    => clock(0),

        tx_local => tx,
        data_in => sc_data_out,
		credit_o => credit_i
    );

	inputmodule: Entity work.inputmodule
	port map(
		clock => clock(0),
		reset => reset,
		finish => finish,

		outclock0 => clock_rx(0),
		outtx0 => rx(0),
		outdata0 => data_in(0),
		incredit0 => credit_o(0),
				
		outclock1 => clock_rx(1),
		outtx1 => rx(1),
		outdata1 => data_in(1),
		incredit1 => credit_o(1),
				
		outclock2 => clock_rx(2),
		outtx2 => rx(2),
		outdata2 => data_in(2),
		incredit2 => credit_o(2),
				
		outclock3 => clock_rx(3),
		outtx3 => rx(3),
		outdata3 => data_in(3),
		incredit3 => credit_o(3),
				
		outclock4 => clock_rx(4),
		outtx4 => rx(4),
		outdata4 => data_in(4),
		incredit4 => credit_o(4),
				
		outclock5 => clock_rx(5),
		outtx5 => rx(5),
		outdata5 => data_in(5),
		incredit5 => credit_o(5),
				
		outclock6 => clock_rx(6),
		outtx6 => rx(6),
		outdata6 => data_in(6),
		incredit6 => credit_o(6),
				
		outclock7 => clock_rx(7),
		outtx7 => rx(7),
		outdata7 => data_in(7),
		incredit7 => credit_o(7),
				
		outclock8 => clock_rx(8),
		outtx8 => rx(8),
		outdata8 => data_in(8),
		incredit8 => credit_o(8)
	);

end architecture;

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use work.HermesPackage.all;
use work.standards.all;

entity testbench is
    generic(
        X_ROUTERS: integer := 3;
        Y_ROUTERS: integer := 3
    );
end;

architecture testbench of testbench is

	signal clock : std_logic_vector( (X_ROUTERS*Y_ROUTERS-1) downto 0) := (others=>'1');
	signal reset : std_logic;
	signal clock_rx, rx, credit_o: std_logic_vector( (X_ROUTERS*Y_ROUTERS-1) downto 0);
	signal clock_tx, tx, credit_i: std_logic_vector( (X_ROUTERS*Y_ROUTERS-1) downto 0);
	signal data_in, data_out : arrayNrot_regflit( (X_ROUTERS*Y_ROUTERS-1) downto 0 );

	constant NB_ROUTERS : integer :=  X_ROUTERS * Y_ROUTERS;

    signal finish:  std_logic;

begin
	reset <= '1', '0' after 15 ns;

    clocks_router: for i in 0 to NB_ROUTERS-1 generate
        clock(i) <= not clock(i) after 10 ns;
    end generate clocks_router;

	noc1: Entity work.NOC
	generic map(
        X_ROUTERS => X_ROUTERS,
        Y_ROUTERS => Y_ROUTERS
    )
	port map(
		clock         => clock,
		reset         => reset,
		clock_rxLocal => clock_rx,
		rxLocal       => rx,
		data_inLocal  => data_in,
		credit_oLocal => credit_o,
		clock_txLocal => clock_tx,
		txLocal       => tx,
		data_outLocal => data_out,
        credit_iLocal => credit_i
    );

    com00: Entity work.outmodule
	port map(
		clock       => clock(0),
		reset       => reset,
		finish      => finish,
        
        inClock0    => clock_tx(0),
		inTx0       => tx(0),
		inData0     => data_out(0),
        outCredit0  => credit_i(0),
        
		inClock1    => clock_tx(1),
		inTx1       => tx(1),
		inData1     => data_out(1),
        outCredit1  => credit_i(1),
        
		inClock2    => clock_tx(2),
		inTx2       => tx(2),
		inData2     => data_out(2),
        outCredit2  => credit_i(2),
        
		inClock3    => clock_tx(3),
		inTx3       => tx(3),
		inData3     => data_out(3),
        outCredit3  => credit_i(3),
        
		inClock4    => clock_tx(4),
		inTx4       => tx(4),
		inData4     => data_out(4),
        outCredit4  => credit_i(4),
        
		inClock5    => clock_tx(5),
		inTx5       => tx(5),
		inData5     => data_out(5),
        outCredit5  => credit_i(5),
        
		inClock6    => clock_tx(6),
		inTx6       => tx(6),
		inData6     => data_out(6),
		outCredit6  => credit_i(6),
		inClock7    => clock_tx(7),
		inTx7       => tx(7),
		inData7     => data_out(7),
		outCredit7  => credit_i(7),
		inClock8    => clock_tx(8),
		inTx8       => tx(8),
		inData8     => data_out(8),
        outCredit8  => credit_i(8)
    );

    cim00: Entity work.inputmodule
	port map(
		clock       => clock(0),
		reset       => reset,
		finish      => finish,
		outclock0   => clock_rx(0),
		outtx0      => rx(0),
		outdata0    => data_in(0),
        incredit0   => credit_o(0),
        
		outclock1   => clock_rx(1),
		outtx1      => rx(1),
		outdata1    => data_in(1),
        incredit1   => credit_o(1),
        
		outclock2   => clock_rx(2),
		outtx2      => rx(2),
		outdata2    => data_in(2),
        incredit2   => credit_o(2),
        
		outclock3   => clock_rx(3),
		outtx3      => rx(3),
		outdata3    => data_in(3),
        incredit3   => credit_o(3),
        
		outclock4   => clock_rx(4),
		outtx4      => rx(4),
		outdata4    => data_in(4),
        incredit4   => credit_o(4),
        
		outclock5   => clock_rx(5),
		outtx5      => rx(5),
		outdata5    => data_in(5),
        incredit5   => credit_o(5),
        
		outclock6   => clock_rx(6),
		outtx6      => rx(6),
		outdata6    => data_in(6),
        incredit6   => credit_o(6),
        
		outclock7   => clock_rx(7),
		outtx7      => rx(7),
		outdata7    => data_in(7),
        incredit7   => credit_o(7),
        
		outclock8   => clock_rx(8),
		outtx8      => rx(8),
		outdata8    => data_in(8),
        incredit8   => credit_o(8)
    );

end testbench;

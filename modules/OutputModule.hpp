#pragma once

#include "standards.hpp"
#include <systemc.h>

SC_MODULE(OutputModule){
public:
	SC_HAS_PROCESS(OutputModule);
	OutputModule(sc_module_name _name);

	sc_in_clk clock;
	sc_in<hermes::reg_node_no> tx_local;
	sc_in<hermes::sc_node_no_reg_flit_size> data_in;
	sc_out<hermes::reg_node_no> credit_o;

private:
	void sniffer();

};

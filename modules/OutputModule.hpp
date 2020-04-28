#pragma once

#include <systemc.h>

SC_MODULE(OutputModule){
public:
	static const uint16_t FLIT_SIZE = 16;
	static const uint16_t NODE_NO = 9;

	SC_HAS_PROCESS(OutputModule);
	OutputModule(sc_module_name _name);

	sc_in_clk clock;
	sc_in<sc_lv<NODE_NO> > tx_local;
	sc_in<sc_lv<FLIT_SIZE> > data_in0;
	sc_in<sc_lv<FLIT_SIZE> > data_in1;
	sc_in<sc_lv<FLIT_SIZE> > data_in2;
	sc_in<sc_lv<FLIT_SIZE> > data_in3;
	sc_in<sc_lv<FLIT_SIZE> > data_in4;
	sc_in<sc_lv<FLIT_SIZE> > data_in5;
	sc_in<sc_lv<FLIT_SIZE> > data_in6;
	sc_in<sc_lv<FLIT_SIZE> > data_in7;
	sc_in<sc_lv<FLIT_SIZE> > data_in8;
	sc_out<sc_lv<NODE_NO > > credit_o; 

private:
	void sniffer();

	uint32_t current_flit[NODE_NO];
	uint32_t flit_count[NODE_NO];
	uint64_t timestamp_core[NODE_NO];
	uint64_t timestamp_net[NODE_NO];
	uint64_t cycle;

	uint16_t data_in(int idx);
};

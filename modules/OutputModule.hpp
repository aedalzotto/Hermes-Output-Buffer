/*
 * @file OutputModule.hpp
 * @brief Output module for VHDL simulation of generic Hermes NoC.
 * @detail This sniffs the network and generates a text file with the local
 * ports output informations.
 * @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
 * @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
 * @date 2020/04
 */

#pragma once

#include "standards.hpp"
#include <systemc.h>

SC_MODULE(OutputModule){
public:
	SC_HAS_PROCESS(OutputModule);
	OutputModule(sc_module_name _name);

	sc_in_clk clock;
	sc_in<sc_logic> finish;
	sc_in<hermes::reg_node_no> tx_local;
	sc_in<hermes::sc_node_no_reg_flit_size> data_in;

private:
	/**
	 * @brief Network sniffing process.
	 * @detail Sensitive to clock rising edge. Reads all local output ports and
	 * log them to text.
	 */
	void sniffer();

};

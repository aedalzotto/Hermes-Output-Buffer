/*
 * @file RouterOutputModule.hpp
 * @brief Output ports logger for Hermes NoC.
 * @detail This sniffs the network and generates a text file with the router
 * ports information.
 * @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
 * @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
 * @date 2020/04
 */

#pragma once

#include <systemc.h>
#include "standards.hpp"

SC_MODULE(RouterOutputModule){
public:
	SC_HAS_PROCESS(RouterOutputModule);
	RouterOutputModule(sc_module_name _name);

	sc_in_clk clock;
	
	sc_in<hermes::node_no_reg_port_no> tx;
	sc_in<hermes::sc_node_no_port_no_reg_flit_size> data_out;
	sc_in<hermes::node_no_reg_port_no> credit_i;

private:
	/**
	 * @brief Network sniffing process.
	 * @detail Sensitive to clock rising edge. Reads all ports and log them to
	 * text.
	 */
	void sniffer();
};
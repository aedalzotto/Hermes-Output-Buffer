/*
 * @file InputModule.hpp
 * @brief Input module for VHDL simulation of generic Hermes NoC.
 * @detail This reads an input scenario and injects to the NoC.
 * @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
 * @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
 * @date 2020/04
 */

#pragma once

#include "standards.hpp"
#include <systemc.h>

SC_MODULE(InputModule){
public:
	SC_HAS_PROCESS(InputModule);
	InputModule(sc_module_name _name);

	sc_in_clk clock;
	sc_in<sc_logic> reset;
	sc_out<sc_logic> finish;

	sc_out<hermes::reg_node_no> clock_tx;
	sc_out<hermes::reg_node_no> tx;
	sc_out<hermes::sc_node_no_reg_flit_size> data_out;
	sc_in<hermes::reg_node_no> credit_i;

private:
	/**
	 * @brief Network injection process.
	 * @detail Sensitive to clock rising edge.
	 */
	void injector();

	/**
	 * @brief Generates clock for local input ports.
	 */
	void clock_generator();

};
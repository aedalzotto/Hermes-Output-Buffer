/*
 * @file standards.hpp
 * @brief Constants and types generation for Hermes generic NoC with output buffers.
 * @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
 * @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
 * @date 2020/04
 */

#include "constants.hpp"
#include <systemc.h>

namespace hermes {
	/* Number of NoC nodes */
	const unsigned int NODE_NO = X_SIZE*Y_SIZE;

	/* Vector for node number control */
	typedef sc_lv<NODE_NO> reg_node_no;

	/* Data bus for all nodes local port (SystemC bind) */
	typedef sc_lv<NODE_NO*FLIT_SIZE> sc_node_no_reg_flit_size;

	/* Vector for flit size register */
	typedef sc_lv<FLIT_SIZE> reg_flit_size;

	/* Unsigned vector for flit size register */
	typedef sc_uint<FLIT_SIZE> sc_reg_flit_size;

	/* Unsigned ector for node number control */
	typedef sc_uint<NODE_NO> sc_reg_node_no;
};
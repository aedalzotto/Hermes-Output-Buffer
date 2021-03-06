/**
 * @file constants.hpp
 * @brief Hermes generic NoC constants for SystemC input and output modules.
 * @detail This **should** be automatic generated by Atlas.
 * @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
 * @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
 * @date 2020/04
 */

#pragma once

namespace hermes {
	/* NoC Size */
	const unsigned int X_SIZE = 3;
	const unsigned int Y_SIZE = 3;

	/* Channel width, also the flit width */
	const unsigned int FLIT_SIZE = 16;
};
/*
 * @file OutputModule.cpp
 * @brief Output module for VHDL simulation of generic Hermes NoC.
 * @detail This sniffs the network and generates a text file with the local
 * ports output informations.
 * @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
 * @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
 * @date 2020/04
 */

#include "OutputModule.hpp"

#include <cstdio>
#include <iomanip>
#include <chrono>

SC_MODULE_EXPORT(OutputModule);

using namespace hermes;
using namespace std;
using namespace chrono;
using namespace chrono::_V2;

OutputModule::OutputModule(sc_module_name _name) : sc_module(_name)
{
	/* Non-initializable process with only 1 sensitive signal */
	SC_CTHREAD(sniffer, clock.pos());
}

/**
 * Output Format:
 * target	size	source	timestamp node exit		sequence no.	timestamp net enter		payload
 *  00XX	XXXX	 00XX 	XXXX XXXX XXXX XXXX		 XXXX XXXX		XXXX XXXX XXXX XXXX		XXXX...
 * 
 * Packet end:
 * timestamp netw exit		timestamp node exit		timestamp net in	timestamp net exit	delay	simulation time (ms)
 * XXXX XXXX XXXX XXXX				dec					  dec				   dec			 dec		   dec
 */
void OutputModule::sniffer() 
{
	/* Output files. One for each local port output. */
	FILE* output[NODE_NO];

	/* Flow control */
	sc_reg_flit_size current_flit[NODE_NO];
	sc_reg_flit_size flit_count[NODE_NO];
	credit_o.write(__UINT64_MAX__);

	/* Open all files and set all output credits as high */
	for(int i = 0; i < NODE_NO; i++){
		char name[255];
		sprintf(name, "out%d.txt", i);
		output[i] = fopen(name,"w");
		flit_count[i] = 0;
		current_flit[i] = 0;
	}

	/* Statistics */
	uint64_t timestamp_core[NODE_NO];
	uint64_t timestamp_net[NODE_NO];
	uint64_t cycle = 0;

	/* All statistics starts zeroed */
	memset(timestamp_core, NODE_NO, sizeof(uint64_t));
	memset(timestamp_net, NODE_NO, sizeof(uint64_t));

	/* Simulation start time */
	system_clock::time_point then = high_resolution_clock().now();

	/* Simulation stop control */
	uint64_t transmitting = 0;
	uint64_t timeout = 0;

	while(true){
		cycle++;
		for(int i = 0; i < NODE_NO; i++){
			/* Receiving data */
			if(tx_local.read().bit(i) == SC_LOGIC_1){
				// First flit: TARGET
				sc_reg_flit_size incoming= data_in.read().range((i+1)*FLIT_SIZE-1, i*FLIT_SIZE).to_ulong();

				if(!current_flit[i]){
					transmitting++;
					fprintf(output[i], "%0*X", FLIT_SIZE/4, incoming.value());
					current_flit[i]++;
				} else if(current_flit[i] == 1){
					fprintf(output[i], " %0*X", FLIT_SIZE/4, incoming.value());

					flit_count[i] = incoming.value();
					current_flit[i]++;
				} else if(current_flit[i] == 2){	// SOURCE
					fprintf(output[i], " %0*X", FLIT_SIZE/4, incoming.value());

					flit_count[i]--;
					current_flit[i]++;
				} else if(current_flit[i] < 7){	// Flits 3, 4, 5 and 6: timestamp node out
					fprintf(output[i], " %0*X", FLIT_SIZE/4, incoming.value());

					timestamp_core[i] += (uint64_t)(incoming.value() * pow(2,((6 - current_flit[i])*FLIT_SIZE)));

					flit_count[i]--;
					current_flit[i]++;
				} else if(current_flit[i] < 9){	// Flits 7 and 8: sequence number
					fprintf(output[i], " %0*X", FLIT_SIZE/4, incoming.value());

					flit_count[i]--;
					current_flit[i]++;
				} else if(current_flit[i] < 13){	// Flits 9, 10, 11 and 12: timestamp network in 
					fprintf(output[i], " %0*X", FLIT_SIZE/4, incoming.value());

					timestamp_net[i] += (unsigned long int)(incoming.value() * pow(2,((12 - current_flit[i])*FLIT_SIZE)));

					flit_count[i]--;
					current_flit[i]++;
				} else { // Payload
					fprintf(output[i], " %0*X", FLIT_SIZE/4, incoming.value());

					flit_count[i]--;
					current_flit[i]++;

					if(!flit_count[i]){
						system_clock::time_point now = high_resolution_clock().now();

						int64_t duration = duration_cast<milliseconds>(now - then).count();

						ostringstream oss;
						oss << setw(FLIT_SIZE) << setfill('0') << hex << uppercase << cycle;

						for(int j = 0; j < oss.str().length(); j += FLIT_SIZE/4){
							fprintf(output[i], " %s", oss.str().substr(j, FLIT_SIZE/4).c_str());
						}

						fprintf(output[i], " %d", timestamp_core[i]);
						fprintf(output[i], " %d", timestamp_net[i]);
						fprintf(output[i], " %d", cycle);
						fprintf(output[i], " %d", cycle - timestamp_core[i]);
						fprintf(output[i], " %ld\n", duration);

						current_flit[i] = 0;
						transmitting--;
						timestamp_core[i] = 0;
						timestamp_net[i] = 0;
					}
				}
			}
			fflush(output[i]);
		}
		if(finish == SC_LOGIC_1){
			if(transmitting)
				timeout=0;
			else {
				timeout++;
				if(timeout>1000)
					sc_stop();
			}
		}
		wait();
	}
	
}

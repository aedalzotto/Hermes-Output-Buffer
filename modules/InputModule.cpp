/*
 * @file InputModule.cpp
 * @brief Input module for VHDL simulation of generic Hermes NoC.
 * @detail This reads an input scenario and injects to the NoC.
 * @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
 * @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
 * @date 2020/04
 */

#include "InputModule.hpp"

#include <cstdio>
#include <vector>
#include <iomanip>

SC_MODULE_EXPORT(InputModule);

using namespace hermes;
using namespace std;

InputModule::InputModule(sc_module_name _name) : sc_module(_name)
{
	
	SC_CTHREAD(injector, clock.pos());

	SC_METHOD(clock_generator);
	sensitive << clock;
}

/**
 * Input Format:
 * start time	target	size	source	timestamp node exit		sequence no.	timestamp net enter		payload
 * 	  XXXX		 00XX	XXXX	 00XX 	XXXX XXXX XXXX XXXX		 XXXX XXXX		XXXX XXXX XXXX XXXX		XXXX...
 */
void InputModule::injector()
{
	/* Input files. One for each local port input. */
	FILE* input[NODE_NO];

	bool active[NODE_NO];
	uint64_t active_cnt = 0;

	uint64_t start_time[NODE_NO];

	vector<uint64_t> packet[NODE_NO];

	for(int i = 0; i < NODE_NO; i++){
		char aux[255];
		sprintf(aux, "in%d.txt", i);

		/* Try to open. Not all nodes will have inputs */
		input[i] = fopen(aux, "r");
		if(input[i]){
			active[i] = true;
			active_cnt++;

			/* Build first packet */
			fscanf(input[i], "%X", &start_time[i]);
			
			/* Get header */
			uint64_t flit;
			fscanf(input[i], "%X", &flit);
			packet[i].push_back(flit);
			
			/* Get payload size */
			fscanf(input[i], "%X", &flit);
			packet[i].push_back(flit);

			/* Timestamp Insertion at the end */
			packet[i][1] += 4;

			/* Get a portion of the packet */
			for(int j = 0; j < 7; j++){
				fscanf(input[i], "%X", &flit);
				packet[i].push_back(flit);
			}

			/* Placeholder for timestamp */
			// packet[i].reserve(4); Maybe this works
			for(int j = 7; j < 11; j++){
				packet[i].push_back(0);
			}

			/* Finally get the payload */
			for(int j = 11; j < packet[i][1]; j++){
				fscanf(input[i], "%X", &flit);
				packet[i].push_back(flit);
			}

		} else {
			active[i] = false;
		}

	}

	/* Temporary signals for attribution */
	sc_node_no_reg_flit_size data_bus;
	reg_node_no	tx_bus;

	tx_bus = 0;
	data_bus = 0;

	// tx.write(0);
	// data_out.write(0);

	/* Flow Control */
	uint64_t current_flit[NODE_NO];
	memset(current_flit, 0, NODE_NO*sizeof(uint64_t));

	/* Statistics */
	uint64_t cycle = 0;

	while(true){
		cycle++;
		/* Initialize signals */
		for(int i = 0; i < NODE_NO; i++){
			/* Check if can inject and has input file */
			if(active[i] && reset.read() != SC_LOGIC_1){
				if(!current_flit[i]) {
					if(cycle >= start_time[i]){
						/* Wait for injection time */
						if(credit_i.read().bit(i) == 1){
							/* Inject header */
							tx_bus[i] = 1;
							data_bus.range((i+1)*FLIT_SIZE-1, i*FLIT_SIZE) = packet[i][current_flit[i]++];

							/* Generate the network enter timestamp */
							char aux[255];
							sprintf(aux, "%0*X", FLIT_SIZE, cycle);

							ostringstream oss;
							oss << setw(FLIT_SIZE) << setfill('0') << hex << uppercase << cycle;

							int k = 9;
							for(int j = 0; j < FLIT_SIZE; j += FLIT_SIZE/4){
								uint64_t flit;
								sscanf(oss.str().substr(j, FLIT_SIZE/4).c_str(), "%X", &flit);
								packet[i][k++] = flit;
							}

						}
					}
				} else if(current_flit[i] < packet[i][1]+2){
					/* Send the payload size + payload */
					if(credit_i.read().bit(i) == 1){
						data_bus.range((i+1)*FLIT_SIZE-1, i*FLIT_SIZE) = packet[i][current_flit[i]++];
					}
				} else {
					if(credit_i.read().bit(i) == 1){

						/* Packet sent. Clear resources and check if we have another packet for this node. */
						packet[i].clear();
						tx_bus[i] = 0;
						data_bus.range((i+1)*FLIT_SIZE-1, i*FLIT_SIZE) = 0;

						/* Reached end of file */
						if(feof(input[i])){
							fclose(input[i]);
							active[i] = false;
							active_cnt--;
						} else {
							current_flit[i] = 0;

							/* Next packet! */
							fscanf(input[i], "%X", &start_time[i]);
							
							/* Get header */
							uint64_t flit;
							fscanf(input[i], "%X", &flit);
							packet[i].push_back(flit);
							
							/* Get payload size */
							fscanf(input[i], "%X", &flit);
							packet[i].push_back(flit);

							/* Timestamp Insertion at the end */
							packet[i][1] += 4;

							/* Get a portion of the packet */
							for(int j = 0; j < 7; j++){
								fscanf(input[i], "%X", &flit);
								packet[i].push_back(flit);
							}

							/* Placeholder for timestamp */
							// packet[i].reserve(4); Maybe this works
							for(int j = 7; j < 11; j++){
								packet[i].push_back(0);
							}

							/* Finally get the payload */
							for(int j = 11; j < packet[i][1]; j++){
								fscanf(input[i], "%X", &flit);
								packet[i].push_back(flit);
							}
						}
					}
				}
			}
		}
		tx.write(tx_bus);
		data_out.write(data_bus);
		wait();
	}

}

void InputModule::clock_generator()
{
	clock_tx.write(__UINT64_MAX__*clock.read());
}

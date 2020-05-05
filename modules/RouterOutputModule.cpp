/*
 * @file RouterOutputModule.cpp
 * @brief Output ports logger for Hermes NoC.
 * @detail This sniffs the network and generates a text file with the router
 * ports information.
 * @author Angelo Elias Dalzotto (angelo.dalzotto@edu.pucrs.br)
 * @author Nicolas Lodea (nicolas.lodea@edu.pucrs.br)
 * @date 2020/04
 */

#include "RouterOutputModule.hpp"

#include <cstdio>
#include <vector>

SC_MODULE_EXPORT(RouterOutputModule);

using namespace hermes;
using namespace std;

RouterOutputModule::RouterOutputModule(sc_module_name _name) : sc_module(_name)
{
	/* Non-initializable process with only 1 sensitive signal */
	SC_CTHREAD(sniffer, clock.pos());
}

void RouterOutputModule::sniffer()
{
	/* Statistic */
	uint64_t cycle = 0;

	/* Output files. One for each port of each node minus the local port. */
	FILE* output[NODE_NO][PORT_NO-1];

	/* Flow control */
	sc_reg_flit_size current_flit[NODE_NO][PORT_NO-1];
	sc_reg_flit_size flit_count[NODE_NO][PORT_NO-1];

	for(int node = 0; node < NODE_NO; node++){
		char aux[255];

		/* Not easternmost. Has east ports */
		if((node+1) % X_SIZE){
			sprintf(aux, "r%dp%d.txt", node, EAST);
			output[node][EAST] = fopen(aux, "w");
			current_flit[node][EAST] = 0;
		}
		/* Not westernmost. Has west ports */
		if(node % X_SIZE){
			sprintf(aux, "r%dp%d.txt", node, WEST);
			output[node][WEST] = fopen(aux, "w");
			current_flit[node][WEST] = 0;
		}
		/* Not northernmost. Has north ports */
		if(node < NODE_NO-X_SIZE){
			sprintf(aux, "r%dp%d.txt", node, NORTH);
			output[node][NORTH] = fopen(aux, "w");
			current_flit[node][NORTH] = 0;
		}
		/* Not southernmost. Has south ports */
		if(node >= X_SIZE){
			sprintf(aux, "r%dp%d.txt", node, SOUTH);
			output[node][SOUTH] = fopen(aux, "w");
			current_flit[node][SOUTH] = 0;
		}
	}

	vector<std::pair<uint64_t, uint64_t> > buffer[NODE_NO][PORT_NO];

	while(true){
		cycle++;
		for(int node = 0; node < NODE_NO; node++){
			/* Checks if a port is transmitting and is ack'd and logs the flit sent */
			/* Format: (XXXX dec) where XXXX -> hex flit, and dec is the decimal cycle */

			/* Not easternmost. Has east ports */
			if((node+1) % X_SIZE){
				if(tx.read().bit(node*PORT_NO + EAST) == 1 && credit_i.read().bit(node*PORT_NO + EAST) == 1){
					sc_reg_flit_size incoming = data_out.read().range((node*PORT_NO + EAST + 1)*FLIT_SIZE - 1, (node*PORT_NO + EAST)*FLIT_SIZE).to_uint64();
					buffer[node][EAST].push_back(std::pair(incoming.value(), cycle));
					current_flit[node][EAST]++;
					
					/* Flow control: payload size */
					if(current_flit[node][EAST] == 2){
						flit_count[node][EAST] = incoming.value();
					} else if(current_flit[node][EAST] > 2){
						if(!(--flit_count[node][EAST])){
							for(int i = 0; i < buffer[node][EAST].size(); i++){
								fprintf(output[node][EAST], "(%0*X %llu)", FLIT_SIZE/4, buffer[node][EAST][i].first, buffer[node][EAST][i].second);
							}
							fprintf(output[node][EAST], "\n");
							fflush(output[node][EAST]);
							current_flit[node][EAST] = 0;
							buffer[node][EAST].clear();
						}
					}
				}
			}
			/* Not westernmost. Has west ports */
			if(node % X_SIZE){
				if(tx.read().bit(node*PORT_NO + WEST) == 1 && credit_i.read().bit(node*PORT_NO + WEST) == 1){
					sc_reg_flit_size incoming = data_out.read().range((node*PORT_NO + WEST + 1)*FLIT_SIZE - 1, (node*PORT_NO + WEST)*FLIT_SIZE).to_uint64();
					buffer[node][WEST].push_back(std::pair(incoming.value(), cycle));
					current_flit[node][WEST]++;
					
					/* Flow control: payload size */
					if(current_flit[node][WEST] == 2){
						flit_count[node][WEST] = incoming.value();
					} else if(current_flit[node][WEST] > 2){
						if(!(--flit_count[node][WEST])){
							for(int i = 0; i < buffer[node][WEST].size(); i++){
								fprintf(output[node][WEST], "(%0*X %llu)", FLIT_SIZE/4, buffer[node][WEST][i].first, buffer[node][WEST][i].second);
							}
							fprintf(output[node][WEST], "\n");
							fflush(output[node][WEST]);
							current_flit[node][WEST] = 0;
							buffer[node][WEST].clear();
						}
					}
				}
			}
			/* Not northernmost. Has north ports */
			if(node < NODE_NO-X_SIZE){
				if(tx.read().bit(node*PORT_NO + NORTH) == 1 && credit_i.read().bit(node*PORT_NO + NORTH) == 1){
					sc_reg_flit_size incoming = data_out.read().range((node*PORT_NO + NORTH + 1)*FLIT_SIZE - 1, (node*PORT_NO + NORTH)*FLIT_SIZE).to_uint64();
					buffer[node][NORTH].push_back(std::pair(incoming.value(), cycle));
					current_flit[node][NORTH]++;

					/* Flow control: payload size */
					if(current_flit[node][NORTH] == 2){
						flit_count[node][NORTH] = incoming.value();
					} else if(current_flit[node][NORTH] > 2){
						if(!(--flit_count[node][NORTH])){
							for(int i = 0; i < buffer[node][NORTH].size(); i++){
								fprintf(output[node][NORTH], "(%0*X %llu)", FLIT_SIZE/4, buffer[node][NORTH][i].first, buffer[node][NORTH][i].second);
							}
							fprintf(output[node][NORTH], "\n");
							fflush(output[node][NORTH]);
							current_flit[node][NORTH] = 0;
							buffer[node][NORTH].clear();
						}
					}	
				}
			}
			/* Not southernmost. Has south ports */
			if(node >= X_SIZE){
				if(tx.read().bit(node*PORT_NO + SOUTH) == 1 && credit_i.read().bit(node*PORT_NO + SOUTH) == 1){
					sc_reg_flit_size incoming = data_out.read().range((node*PORT_NO + SOUTH + 1)*FLIT_SIZE - 1, (node*PORT_NO + SOUTH)*FLIT_SIZE).to_uint64();
					buffer[node][SOUTH].push_back(std::pair(incoming.value(), cycle));
					current_flit[node][SOUTH]++;

					/* Flow control: payload size */
					if(current_flit[node][SOUTH] == 2){
						flit_count[node][SOUTH] = incoming.value();
					} else if(current_flit[node][SOUTH] > 2){
						if(!(--flit_count[node][SOUTH])){
							for(int i = 0; i < buffer[node][SOUTH].size(); i++){
								fprintf(output[node][SOUTH], "(%0*X %llu)", FLIT_SIZE/4, buffer[node][SOUTH][i].first, buffer[node][SOUTH][i].second);
							}
							fprintf(output[node][SOUTH], "\n");
							fflush(output[node][SOUTH]);
							current_flit[node][SOUTH] = 0;
							buffer[node][SOUTH].clear();
						}
					}
				}
			}
		}
		wait();
	}

}
#include "OutputModule.hpp"

#include <fstream>
#include <sstream>
#include <iomanip>
#include <chrono>

SC_MODULE_EXPORT(OutputModule);

OutputModule::OutputModule(sc_module_name _name) : sc_module(_name)
{
	SC_CTHREAD(sniffer, clock.pos());
}

void OutputModule::sniffer() 
{
	std::ofstream output[NODE_NO];

	std::chrono::_V2::steady_clock::time_point then = std::chrono::steady_clock().now();

	// Open all files
	sc_lv<NODE_NO> aux; 
	for(int i = 0; i < NODE_NO; i++){
		std::ostringstream name;
		name << "out" << i << ".txt";
		output[i].open(name.str().c_str());
		output[i] << std::uppercase;
		aux[i] = SC_LOGIC_1;
	}
	credit_o.write(aux);

	// Zero out the flit counter
	memset(current_flit, NODE_NO, sizeof(uint32_t));
	memset(flit_count, NODE_NO, sizeof(uint32_t));
	memset(timestamp_core, NODE_NO, sizeof(uint64_t));
	memset(timestamp_net, NODE_NO, sizeof(uint64_t));

	cycle = 0;

	while(true){
		cycle++;
		for(int i = 0; i < NODE_NO; i++){
			if(tx_local.read().bit(i) == SC_LOGIC_1){
				// First flit: TARGET
				if(!current_flit[i]){
					output[i] << std::setfill('0') << std::setw(4) << std::hex << data_in(i);
					current_flit[i]++;
				} else if(current_flit[i] == 1){
					output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
					output[i] << std::setfill('0') << std::setw(4) << std::hex << data_in(i);

					flit_count[i] = data_in(i);
					current_flit[i]++;
				} else if(current_flit[i] == 2){	// SOURCE
					output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
					output[i] << std::setfill('0') << std::setw(4) << std::hex << data_in(i);

					flit_count[i]--;
					current_flit[i]++;
				} else if(current_flit[i] < 7){	// Flits 3, 4, 5 and 6: timestamp node out
					output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
					output[i] << std::setfill('0') << std::setw(4) << std::hex << data_in(i);

					timestamp_core[i] += (unsigned long int)(data_in(i) * pow(2,((8 - current_flit[i])*FLIT_SIZE)));

					flit_count[i]--;
					current_flit[i]++;
				} else if(current_flit[i] < 9){	// Flits 7 and 8: sequence number
					output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
					output[i] << std::setfill('0') << std::setw(4) << std::hex << data_in(i);

					flit_count[i]--;
					current_flit[i]++;
				} else if(current_flit[i] < 13){	// Flits 9, 10, 11 and 12: timestamp network in 
					output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
					output[i] << std::setfill('0') << std::setw(4) << std::hex << data_in(i);

					timestamp_net[i] += (unsigned long int)(data_in(i) * pow(2,((12 - current_flit[i])*FLIT_SIZE)));

					flit_count[i]--;
					current_flit[i]++;
				} else { // Payload
					output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
					output[i] << std::setfill('0') << std::setw(4) << std::hex << data_in(i);;

					flit_count[i]--;
					current_flit[i]++;

					if(!flit_count[i]){
						std::chrono::_V2::steady_clock::time_point now = std::chrono::steady_clock().now();
						output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
						output[i] << std::setfill('0') << std::setw(16) << std::hex << cycle;
						output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
						output[i] << std::setfill('0') << std::setw(16) << std::hex << timestamp_core[i];
						output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
						output[i] << std::setfill('0') << std::setw(16) << std::hex << timestamp_net[i];
						output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
						output[i] << std::setfill('\0') << std::setw(0) << std::dec << cycle;
						output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
						output[i] << std::setfill('\0') << std::setw(0) << std::dec << cycle - timestamp_core[i];

						output[i] << std::setfill('\0') << std::setw(0) << std::dec << " ";
						output[i] << " " << std::chrono::duration_cast<std::chrono::milliseconds>(now - then).count(); // Total delay
						output[i] << std::endl;


						current_flit[i] = 0;
					}
				}
			}
			output[i].flush();
		}
		wait();
	}
	
}

uint16_t OutputModule::data_in(int idx)
{
	if(idx == 0) return data_in0.read().to_uint();
	else if(idx == 1) return (uint16_t)data_in1.read().to_uint();
	else if(idx == 2) return (uint16_t)data_in2.read().to_uint();
	else if(idx == 3) return (uint16_t)data_in3.read().to_uint();
	else if(idx == 4) return (uint16_t)data_in4.read().to_uint();
	else if(idx == 5) return (uint16_t)data_in5.read().to_uint();
	else if(idx == 6) return (uint16_t)data_in6.read().to_uint();
	else if(idx == 7) return (uint16_t)data_in7.read().to_uint();
	else return data_in8.read().to_uint();
}

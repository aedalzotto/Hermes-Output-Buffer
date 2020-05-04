# Hermes Output Buffered

The Hermes NoC is a parameterizable infrastructure used to implement low area overhead wormhole packet switching NoCs with 2D mesh topology. The original project consisted of a centralized switching logic with five bi-directional ports in each router.

The output buffered Hermes distributes the routing for each input port which has 4 buffers to where the packet will be routed following the XY algorithm. Each output port has its own arbiter which selects an output buffer to make available at it's output following the Round-Robin algorithm, then avoiding starvation.

This project is intended to be used alongside with Atlas, providing an ease generation of the parametrizable NoC and its evaluation. Power estimation for this model is still not available.

## About Atlas

The Atlas environment automates the various processes related to the design flow for some of NoCs proposed by the GAPH Group and eventually by other groups with which we collaborate. Currently, the design flow is composed by the following stages: NoC generation, traffic generation, simulation, performance and power evaluation. In the NoC generation, the NoC parameters (for example, channel bandwidth, buffer depth, number of virtual channels, flow control strategies) are configured. In the traffic generation, the traffic sceneries are generated to characterize the applications which execute on the NoC. In the simulation, the traffic data are injected in the NoC, occurring in this step the effective communication among the cores. In the performance evaluation, it is possible to generate graphics, tables, maps and reports to help in the analysis of obtained results.

## Prerequisites

The co-simulation (VHDL + SystemC) can be done with ModelSim. At least experimental C++11 is needed by the `sccom` compiler.

## Evaluating

Manual evaluation can be done placing the input files in the repository root following the name `in#.txt`, where `#` is the index of the node where the packet will be injected. This is the packet format:

| Cycle to inject (hex) | Target (hex) | Payload Size (hex) | Cycle to inject[3] (hex) | Cycle to inject[2] (hex) | Cycle to inject[1] (hex) | Cycle to inject[0] (hex) | Sequence no.[1] (hex) | Sequence no.[0] (hex) | Payload... |
|-----------------------|--------------|--------------------|--------------------------|--------------------------|--------------------------|--------------------------|----------------|-|-|

The NoC parameters can be set in the [VHDL](hermes/constants.vhd) and [SystemC](modules/constants.hpp) constants files. It is possible to change the NoC size (X and Y), the flit size and the number of buffer slots.

To run, simply execute the `simulate.do` script, commenting anything below the `run` line (including itself). A `wave.do` including some routers path for a 3x3 NoC and a `wave_input.do` including de packet injector signals are bundled with the project.

## Example

### Manual Simulation 3x3 NoC

1. The default NoC size is 3x3, but if you want to change, check [constants.vhd](/hermes/constants.vhd) and [constants.hpp](modules/constants.hpp).
2. Create a new file in the project root called in0.txt. This will be the input packets in local port 0 (Router 0x0). Populate it with ```1 0012 000B 0000 0000 0000 0001 0000 0001 BBBB CCCC DDDD EEEE FFFF```. This means a packet will be injected at cycle 1 targeting the node 1x2 with size 0xB flits. The final size will be 0xF, because the input module injects a few more information to the packet.
3. Create a new file in the project root called in2.txt. This will be the input packets in local port 2 (Router 2x0). Populate it with ```1 0012 000B 0000 0000 0000 0001 0000 0001 B00B C00C D00D E00E F00F```. This means a packet will be injected at cycle 1 targeting the node 1x2 with size 0xB flits. The final size will be 0xF, because the input module injects a few more information to the packet.
4. Comment anything below the "run" (line 25) of [simulate.do](simulate.do), including itself.
5. Compile and simulate using ModelSim and the [simulate.do](simulate.do) that was modified. A [wave.do](wave.do) is bundled to see this example signals.
6. You should be able to see the following:

<div align="center">
	<img src=docs/routing.png >
	<p>This shows the routing being done in 3 clock cycles. The first is the XY routing algorithm to pick the output buffer, the second is the buffer propagation and the third is the round-robin arbiter algorithm.</p>
</div>
<br/>
<div align="center">
	<img src=docs/arbiting.png >
	<p>This shows the arbiting being done in 1 clock cycle when the last flit of the previous packet has being sent.</p>
</div>

### Atlas Simulation with 8x8 NoC

1. Open Atlas, select Projects > New Project, and create a new project of type HermesOB. <br/><div align="center"><img src=docs/project.png ></div>
2. Select NoC Generation, and generate NoC with X and Y dimensions equal to 8, flit size of 16 and buffer depth of 4. The only routing algorithm supported is XY, and the only arbiting algorithm supported is Round-Robin. <br/><div align="center"><img src=docs/generate.png ></div>
3. Select Traffic Generation, Manage Scenery > New Scenery, and create a new scenery. Select Configuration > Standard Configuration, and generate a traffic with target 'Complement'. Choose 100 packets with 480 Mbps rate (60% of network capacity). Click Generate. <br/><div align="center"><img src=docs/traffic.png></div>
4. Select Simulation and simulate for 3ms.
5. Check the performance evaluation. Power evaluation is unsupported for Hermes OB.


## Credits

* **Contributors** of the [ATLAS environment](https://corfu.pucrs.br/redmine/projects/atlas)
